#!/usr/sbin/dtrace -s

stmf_sbd:sbd_handle_sgl_write_xfer_completion:entry
{ self->tr_compl = 1; self->time_compl = timestamp; }

zfs:zil_commit:entry
/self->tr_compl/ { self->zil_time = timestamp; }

zfs:zil_commit:return
/self->tr_compl && ((timestamp - self->zil_time)/1000) > 4000/
{
	@[probefunc] = quantize((timestamp - self->zil_time)/1000);
	self->zil_time = 0;
}

fbt:genunix:cv_wait:entry
/self->tr_compl/ { self->wait = timestamp; }

fbt:genunix:cv_wait:return
/self->tr_compl && ((timestamp - self->wait)/1000) > 4000/
{
	@[probefunc] = quantize((timestamp - self->wait)/1000);
	self->wait = 0;
}

zfs:zil_commit_writer:entry
/self->tr_compl/ { self->zil_writer = timestamp; }

zfs:zil_commit_writer:return
/self->tr_compl && ((timestamp - self->zil_writer)/1000) > 4000/
{
	@[probefunc] = quantize((timestamp - self->zil_writer)/1000);
	self->zil_writer = 0;
}

stmf_sbd:sbd_zvol_rele_write_bufs:entry
/self->tr_compl/ { self->sbd_write = timestamp; }

stmf_sbd:sbd_zvol_rele_write_bufs:return
/self->tr_compl && ((timestamp - self->sbd_write)/1000) > 4000/
{
	@[probefunc] = quantize((timestamp - self->sbd_write)/1000); self->sbd_write = 0;
}

stmf_sbd:sbd_handle_sgl_write_xfer_completion:return
/self->tr_compl && ((timestamp - self->time_compl)/1000) > 4000/
{
	@[probefunc] = quantize((timestamp - self->time_compl)/1000);
	self->tr_compl = 0; self->time_compl = 0;
}

profile:::tick-1sec
{ printa(@); }
