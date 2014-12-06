#!/usr/sbin/dtrace -s

fbt:stmf_sbd:cpmgr_run:entry
{
	self->flag = 1;
}

fbt:stmf_sbd:sbd_data_read:entry
/self->flag/
{
	self->rtime = timestamp;
	@rsize[ (uint64_t) arg3] = count();
}

fbt:stmf_sbd:sbd_data_read:return
/self->flag/
{
	@rlatency = quantize((timestamp - self->rtime) / 1000);
}

fbt:stmf_sbd:sbd_data_write:entry
/self->flag/
{
	self->wtime = timestamp;
	@wsize[ (uint64_t) arg3] = count();
}

fbt:stmf_sbd:sbd_data_write:return
/self->flag/
{
	@wlatency = quantize((timestamp - self->wtime) / 1000);
}

fbt:stmf_sbd:cpmgr_run:return
/self->flag/
{
	self->flag = 0;
}

profile:::tick-1sec
{
	printf("\nReads (usecs)\n");
	printa(@rsize); trunc(@rsize);
	printa(@rlatency); trunc(@rlatency);

	printf("Writes (usecs)\n");
	printa(@wsize); trunc(@wsize);
	printa(@wlatency); trunc(@wlatency);
}
