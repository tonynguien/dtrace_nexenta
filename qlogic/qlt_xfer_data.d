#!/usr/sbin/dtrace -s

fbt:stmf_sbd:sbd_do_sgl_read_xfer:entry
{ self->tr = 1; self->sgl_time = timestamp; @funcs[probefunc] = count(); }

fbt::qlt_xfer_scsi_data:entry
/self->tr/ { self->time = timestamp; @funcs[probefunc] = count(); }

fbt::qlt_xfer_scsi_data:return
/self->tr/
{
	@[probefunc] = quantize((timestamp - self->time)/1000); self->time = 0;
}

fbt:stmf_sbd:sbd_do_sgl_read_xfer:return
/self->tr/
{
	@[probefunc] = quantize((timestamp - self->sgl_time)/1000);
	self->sgl_time = 0; self->tr = 0;
}

profile:::tick-1sec { printa(@); trunc(@); printa(@funcs); trunc(@funcs); }
