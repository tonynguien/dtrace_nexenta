#!/usr/sbin/dtrace -qs

fbt::sbd_unmap:entry
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
	/* printf("%s Duration:%d (msecs)\n",
	    probefunc, (timestamp - self->tx_hold_ts)/1000000); */

	@ts[probefunc] = sum(timestamp - self->tx_hold_ts);
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

fbt:genunix:list_next:entry
/self->dbuf_ts/ { self->list_ts = timestamp;  @[probefunc] = count(); }

fbt:genunix:list_next:return
/self->list_ts/
{
	@ts[probefunc] = sum(timestamp - self->list_ts);
	self->list_ts = 0;
}

fbt::dbuf_free_range:return
/self->dbuf_ts/
{
	printf("%s Duration:%d (msecs)  Start:%d   End:%d  Len:%d\n",
	    probefunc, (timestamp - self->dbuf_ts)/1000000,
	    self->start, self->end, self->end - self->start);
	@ts[probefunc] = sum(timestamp - self->dbuf_ts);
	self->dbuf_ts = 0; self->start  = 0; self->end = 0;
	c++;
}

fbt::dmu_free_long_range_impl:return
/self->dmu_ts/
{
	printf("\n%s Start:%Y  End:%Y\n", probefunc, self->dmu_ts, walltimestamp);
	self->dmu_ts = 0;
}

fbt::sbd_unmap:return
/self->unmap/
{
	printf("\n%s Start:%Y  End:%Y\n", probefunc, self->ts, walltimestamp);
	self->unmap = 0; self->ts = 0;
	normalize(@ts, 1000);
	printf("\nfunctions probed"); printa(@);
	printf("\nTotal time"); printa(@ts);
}
