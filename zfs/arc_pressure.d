#!/usr/sbin/dtrace -s

/*
 * Author: Bayard Bell
 */

/* Default int type doesn't work for the math we need to do */
this int64_t arc_size;
this int64_t arc_c;
this int64_t arc_p;
this int64_t arc_meta_used;
this int64_t arc_mru_size;
this int64_t arc_mru_ldata;
this int64_t arc_mru_lmeta;
this int64_t arc_mfu_size;
this int64_t arc_mfu_ldata;
this int64_t arc_mfu_lmeta;

fbt:zfs:arc_reclaim_needed:entry
/caller >= (uintptr_t)`arc_reclaim_thread && caller <=
  (uintptr_t)&zfs`arc_reclaim_thread+sizeof(zfs`arc_reclaim_thread)/
{
	self->spec = speculation();
	self->rec = 1;
}

fbt:zfs:arc_reclaim_needed:return
/arg1 == 0 && self->spec/
{
	discard(self->spec);
	self->spec = 0;
}

fbt:zfs:arc_reclaim_needed:return
/arg1 != 0 && self->spec/
{
	commit(self->spec);
	self->spec = 0;
}

fbt:zfs:arc_reclaim_needed:return
/arg1 != 0 && self->rec/
{
	printf("%Y\n%s`%s+0x%x returned 0x%x\n", walltimestamp, probemod,
	    probefunc, arg0, arg1);
	printf("\tfreemem %d\n", `freemem);
	printf("\tavailrmem %d\n", `availrmem);
}

fbt:zfs:arc_reclaim_needed:return
/self->rec/
{
	self->rec = 0;
}

fbt::vmem_size:entry
/self->spec/
{
	self->vmemt = args[0];
	self->vmflags = args[1];
}

fbt::vmem_size:return
/self->spec/
{
	speculate(self->spec);
	/* Assume call with either one flag or the other */
	printf("\t%s`%s(%a, %s) returned %d\n", probemod, probefunc,
	    self->vmemt, self->vmflags & 1 ? "VMEM_ALLOC" :
	    self->vmflags & 2 ? "VMEM_FREE" : "UNKNOWN",
	    args[1]);

	self->vmemt = 0;
	self->vmflags = 0;
}

fbt:zfs:arc_kmem_reap_now:entry
{
	printf("\t%s`%s(%s)\n", probemod, probefunc,
	    arg0 == 0 ? "ARC_RECLAIM_AGGR" :
	    arg0 == 1 ? "ARC_RECLAIM_CONS" : "UNKNOWN" );

	self->trace = 1;
}

fbt:zfs:arc_kmem_reap_now:return
/self->trace/
{
	printf("%Y\n\tfreemem %d\n", walltimestamp, `freemem);
	printf("\tavailrmem %d\n", `availrmem);

	self->trace = 0;
}

fbt:zfs:arc_adjust:entry
/self->trace/
{
	self->arc_size = `arc_stats.arcstat_size.value.ui64;
	self->arc_c = `arc_stats.arcstat_c.value.ui64;
	self->arc_p = `arc_stats.arcstat_p.value.ui64;
	self->arc_meta_used = `arc_stats.arcstat_meta_used.value.ui64;
	self->arc_mru_size = `arc_mru->arcs_size;
	self->arc_mru_ldata = `arc_mru->arcs_lsize[0];
	self->arc_mru_lmeta = `arc_mru->arcs_lsize[1];
	self->arc_mfu_size = `arc_mfu->arcs_size;
	self->arc_mfu_ldata = `arc_mfu->arcs_lsize[0];
	self->arc_mfu_lmeta = `arc_mfu->arcs_lsize[1];
}

fbt:zfs:arc_adjust:return
/self->trace/
{
	this->arc_size =
		self->arc_size - `arc_stats.arcstat_size.value.ui64;
	this->arc_c = self->arc_c - `arc_stats.arcstat_c.value.ui64;
	this->arc_p = self->arc_p - `arc_stats.arcstat_p.value.ui64;
	this->arc_meta_used =
		self->arc_meta_used - `arc_stats.arcstat_meta_used.value.ui64;
	this->arc_mru_size =
		`arc_mru->arcs_size - self->arc_mru_size;
	this->arc_mru_ldata =
		`arc_mru->arcs_lsize[0] - self->arc_mru_ldata;
	this->arc_mru_lmeta =
		`arc_mru->arcs_lsize[1] - self->arc_mru_lmeta;
	this->arc_mfu_size =
		`arc_mfu->arcs_size - self->arc_mfu_size;
	this->arc_mfu_ldata =
		`arc_mfu->arcs_lsize[0] - self->arc_mfu_ldata;
	this->arc_mfu_lmeta =
		`arc_mfu->arcs_lsize[1] - self->arc_mfu_lmeta;

	printf("%Y\n\tarc size: %d (%d)\n", walltimestamp,
	    `arc_stats.arcstat_size.value.ui64, this->arc_size);
	printf("\tarc target size: %d (%d)\n", `arc_stats.arcstat_c.value.ui64,
	    this->arc_c);
	printf("\tarc MRU target size: %d (%d)\n",
	    `arc_stats.arcstat_p.value.ui64, this->arc_p);
	printf("\tarc meta used: %d (%d)\n",
	    `arc_stats.arcstat_meta_used.value.ui64, this->arc_meta_used);
	printf("\tarc_mru size: %d (%d)\n",
	    `arc_mru->arcs_size, this->arc_mru_size);
	printf("\tarc_mru data evictable size: %d (%d)\n",
	    `arc_mru->arcs_lsize[0], this->arc_mru_ldata);
	printf("\tarc_mru meta evictable size: %d (%d)\n",
	    `arc_mru->arcs_lsize[1], this->arc_mru_lmeta);
	printf("\tarc_mfu size: %d (%d)\n",
	    `arc_mfu->arcs_size, this->arc_mfu_size);
	printf("\tarc_mfu data evictable size: %d (%d)\n",
	    `arc_mfu->arcs_lsize[0], this->arc_mfu_ldata);
	printf("\tarc_mfu meta evictable size: %d (%d)\n",
	    `arc_mfu->arcs_lsize[1], this->arc_mfu_lmeta);
	printf("\tfreemem %d\n", `freemem);
	printf("\tavailrmem %d\n", `availrmem);

	self->trace = 0;
	self->arc_size = 0;
	self->arc_c = 0;
	self->arc_p = 0;
	self->arc_meta_used = 0;
	self->arc_mru_size = 0;
	self->arc_mru_ldata = 0;
	self->arc_mru_lmeta = 0;
	self->arc_mfu_size = 0;
	self->arc_mfu_ldata = 0;
	self->arc_mfu_lmeta = 0;
}

fbt:zfs:arc_evict:entry
/self->trace/
{
	printf("\t%s`%s called against %s %s for delta %d\n", probemod, probefunc,
	    args[0] == `arc_mru ? "arc_mru" : "arm_mfu",
	    arg4 == 0 ? "ARC_BUFC_DATA" : "ARC_BUFC_METADATA", arg2);
}

fbt:zfs:arc_evict_ghost:entry
/self->trace/
{
	printf("\t%s`%s called against %s for delta %d\n", probemod, probefunc,
	    args[0] == `arc_mru_ghost ? "arc_mru_ghost" : "arc_mfu_ghost",
	    arg2);
}
