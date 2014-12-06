#!/usr/sbin/dtrace -s

/* Quantized Read Latency */
fbt:stmf_sbd:sbd_handle_read:entry
{
	self->ts = timestamp;
}

fbt:stmf_sbd:sbd_handle_read:return
/self->ts/
{
	/* usec */
	@rq = quantize((timestamp - self->ts) / 1000);
	self->ts =0;
}

fbt:stmf_sbd:sbd_copy_rdwr:entry
{ }

fbt:stmf_sbd:sbd_copy_rdwr:return
{ }

fbt:stmf_sbd:sbd_do_sgl_read_xfer:entry
{}

fbt:stmf_sbd:sbd_do_sgl_read_xfer:return
{}

fbt:stmf_sbd:sbd_data_read:entry
{}

fbt:stmf_sbd:sbd_data_read:return
{}

fbt:stmf_sbd:sbd_do_read_xfer:entry
{
}

fbt:stmf_sbd:sbd_do_read_xfer:return
{
}


/* Quantized Write Latency */
fbt:stmf_sbd:sbd_handle_write:entry
{
	self->ts = timestamp;
}

fbt:stmf_sbd:sbd_handle_write:return
/self->ts/
{
	@wq = quantize(timestamp - self->ts);
	self->ts =0;
}

profile:::tick-10s
{
	printf("\n\t\tRead values in usec\n");
	printa(@rq);
	printf("\t\tWrite values in usec\n");
	printa(@wq);
}
