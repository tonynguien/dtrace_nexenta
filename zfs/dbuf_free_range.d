#!/usr/sbin/dtrace -qs

fbt::sbd_zvol_unmap:entry
{ self->unmap = 1; self->ts = walltimestamp; }

fbt::dmu_free_long_range_impl:entry
/self->unmap/
{
	self->dmu_ts = walltimestamp;
	printf("%Y %s offset:%d   length:%d\n",
	    walltimestamp, probefunc, args[2], args[3]);
}

fbt::dmu_tx_hold_free:entry
/self->dmu_ts/
{
	self->tx_hold_ts = timestamp;
}

fbt::dmu_tx_hold_free:return
/self->dmu_ts/
{
	printf("%s Duration:%d (msecs)\n",
	    probefunc, (timestamp - self->tx_hold_ts)/1000000);
	self->tx_hold_ts = 0;
}

fbt::dbuf_free_range:entry
/self->dmu_ts/
{
	self->dbuf_ts = timestamp;
	self->start  = args[1];
	self->end = args[2];
	@[probefunc] = count();
}

fbt:zfs:dbuf_add_ref:entry,
fbt:zfs:dbuf_will_dirty:entry,
fbt:zfs:dbuf_rele:entry,
fbt:zfs:dbuf_unoverride:entry,
fbt:zfs:dnode_rele:entry,
fbt:zfs:dbuf_fix_old_data:entry,
fbt:zfs:arc_release:entry,
fbt:zfs:arc_buf_freeze:entry,
fbt:zfs:dbuf_undirty:entry,
fbt:zfs:arc_buf_evict:entry,
fbt:zfs:zrl_add:entry,
fbt:zfs:zrl_remove:entry,
fbt:zfs:dbuf_clear:entry
/self->dbuf_ts/ { @[probefunc] = count(); }

fbt::dbuf_free_range:return
/self->dbuf_ts/
{
	printf("%s Duration:%d (msecs)  Start:%d   End:%d  Len:%d\n",
	    probefunc, (timestamp - self->dbuf_ts)/1000000,
	    self->start, self->end, self->end - self->start);
	self->dbuf_ts = 0; self->start  = 0; self->end = 0;
}

fbt::dmu_free_long_range_impl:return
/self->dmu_ts/
{
	printf("\n%s Start:%Y  End:%Y\n", probefunc, self->dmu_ts, walltimestamp);
	self->dmu_ts = 0;
}

fbt::sbd_zvol_unmap:return
/self->unmap/
{
	printf("\n%s Start:%Y  End:%Y\n", probefunc, self->ts, walltimestamp);
	printa(@);
	self->unmap = 0; self->ts = 0;
}

