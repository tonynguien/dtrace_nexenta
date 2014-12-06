#!/usr/sbin/dtrace -s

fbt::qlt_dma_setup_dbuf:entry
{ self->dma_dbuf = 1; self->dma_dbuf_time = timestamp; }

fbt::qlt_dma_setup_dbuf:return
/self->dma_dbuf/
{
	@[probefunc] = quantize((timestamp - self->dma_dbuf_time)/1000);
	self->dma_dbuf_time = 0; self->dma_dbuf = 0;
}

fbt::qlt_xfer_scsi_data:entry
{ self->xfer = 1; self->xfer_time = timestamp; }

fbt::qlt_xfer_scsi_data:return
/self->xfer/
{
	@[probefunc] = quantize((timestamp - self->xfer_time)/1000);
	self->xfer_time = 0; self->xfer = 0;
}

fbt::qlt_dma_teardown_dbuf:entry
{ self->dma_teardown = 1; self->dma_teardown_time = timestamp; }

fbt::qlt_dma_teardown_dbuf:return
/self->dma_teardown/
{
	@[probefunc] = quantize((timestamp - self->dma_teardown_time)/1000);
	self->dma_teardown_time = 0; self->dma_teardown = 0;
}

fbt::qlt_handle_atio_queue_update:entry
{ self->dma_atio_q = 1; self->dma_atio_q_time = timestamp; }

fbt::qlt_handle_atio_queue_update:return
/self->dma_atio_q/
{
	@[probefunc] = quantize((timestamp - self->dma_atio_q_time)/1000);
	self->dma_atio_q_time = 0; self->dma_atio_q = 0;
}


profile:::tick-1sec { printa(@); trunc(@); }
