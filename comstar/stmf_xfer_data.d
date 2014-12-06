#!/usr/sbin/dtrace -s

stmf_xfer_data:entry
{ self->tr=1; self->ts=timestamp; self->buf_size = args[1]->db_buf_size; }

stmf_xfer_data:return
/self->tr/
{
	@avg[self->buf_size] = avg((timestamp - self->ts)/1000); 
	@[self->buf_size] = count(); 
	self->tr=0; self->ts=0; self->buf_size = 0;
}

profile:::tick-1sec { printa(@avg); }
