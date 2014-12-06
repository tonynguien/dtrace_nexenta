#!/usr/sbin/dtrace -s

#pragma D option quiet

kmem_depot_ws_reap:entry
/args[0]->cache_name=="arc_buf_hdr_t"/
{
	self->ts[probefunc] = timestamp;
	self->cache = args[0];
	self->slabs_destroyed=0;
	printf("Entry %s: %s full reaplimit=%u min=%u total=%u; empty reaplimit=%u min=%u total=%u\n",
	    probefunc,
	    self->cache->cache_name,
	    self->cache->cache_full.ml_reaplimit,
	    self->cache->cache_full.ml_min,
	    self->cache->cache_full.ml_total,
	    self->cache->cache_empty.ml_reaplimit,
	    self->cache->cache_empty.ml_min,
	    self->cache->cache_empty.ml_total);
}

kmem_magazine_destroy:entry
/self->cache/ { self->mag = timestamp; }

kmem_slab_destroy:entry
/self->cache/ { self->slabs_destroyed++; }

kmem_slab_free:entry
/self->cache/ { self->slab = timestamp; }

kmem_slab_free:return
/self->cache && self->slab/
{
	@slab[probefunc] = quantize((timestamp/1000/1000) - (self->slab/1000/1000));
	self->slab= 0;
}

zfs:hdr_dest:entry
/self->cache/ {self->hdr_ts = timestamp; }

zfs:hdr_dest:return
/self->cache && self->hdr_ts/
{
	@hdr[probefunc] = quantize((timestamp/1000/1000) - (self->hdr_ts/1000/1000));
	self->hdr_ts = 0;
}

kmem_magazine_destroy:return
/self->cache && self->mag/
{
	@mag[probefunc] = quantize((timestamp/1000/1000) - (self->mag/1000/1000));
	self->mag = 0;
}

kmem_depot_ws_reap:return
/self->cache && (timestamp - self->ts[probefunc])/1000/1000 > 2/
{
	printf("spent %ums reaping %s, freed %uMB, (destroyed %u slabs of %uKB each)\n",
	    (timestamp - self->ts[probefunc])/1000/1000,
	    self->cache->cache_name,
	    self->slabs_destroyed * self->cache->cache_slabsize / 1024 / 1024,
	    self->slabs_destroyed,
	    self->cache->cache_slabsize / 1024);

	printf("Return %s: %s full reaplimit=%u min=%u total=%u; empty reaplimit=%u min=%u total=%u\n",
	    probefunc,
	    self->cache->cache_name,
	    self->cache->cache_full.ml_reaplimit,
	    self->cache->cache_full.ml_min,
	    self->cache->cache_full.ml_total,
	    self->cache->cache_empty.ml_reaplimit,
	    self->cache->cache_empty.ml_min,
	    self->cache->cache_empty.ml_total);

	printa(@hdr); clear(@hdr);
	printa(@slab); clear(@slab);
	printa(@mag); clear(@mag);
	self->cache = 0;
}

arc_kmem_reap_now:entry,
vmem_qcache_reap:entry
{
	self->ts[probefunc] = timestamp;
}

arc_kmem_reap_now:return,
vmem_qcache_reap:return
{
	printf("  %Y  spent %ums in %s\n\n",
	    walltimestamp, (timestamp - self->ts[probefunc])/1000/1000, probefunc);
}
