#!/usr/sbin/dtrace -s

/* Quantized Read Latency */
fbt:stmf_sbd:sbd_handle_read:entry
{
	self->ts = timestamp;
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_handle_read:return
/self->ts/
{
	/* usec */
	@rq = quantize((timestamp - self->ts) / 1000);
	self->ts =0;
}

fbt:stmf_sbd:sbd_copy_rdwr:entry
/self->ts/
{
	self->rdwr = timestamp;
	@[probefunc] = count();

}

fbt:stmf_sbd:sbd_copy_rdwr:return
/self->rdwr/
{
	@copy_rdwr = quantize((timestamp - self->rdwr) / 1000);
	self->rdwr =0;
}

fbt:stmf_sbd:sbd_do_sgl_read_xfer:entry
/self->ts/
{
	self->sgl = timestamp;
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_do_sgl_read_xfer:return
/self->sgl/
{
	@sgl = quantize((timestamp - self->sgl) / 1000);
	self->sgl = 0;
}

fbt:stmf_sbd:sbd_data_read:entry
/self->ts/
{
	self->data_read = timestamp;
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_data_read:return
/self->data_read/
{
	@data_read = quantize((timestamp - self->data_read) / 1000);
	self->data_read = 0;
}

fbt:stmf_sbd:sbd_do_read_xfer:entry
/self->ts/
{
	self->read_xfer = timestamp;
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_do_read_xfer:return
/self->read_xfer/
{
	@read_xfer = quantize((timestamp - self->read_xfer) / 1000);
	self->read_xfer = 0;
}

profile:::tick-3s
{
	printf("\n\t\tsbd_handle_read latency (usec)\n");
	printa(@rq);

	printf("\n\t\tsbd_copy_rdwr latency (usec)\n");
	printa(@copy_rdwr);

	printf("\n\t\tsbd_do_sgl_read_xfer latency (usec)\n");
	printa(@sgl);

	printf("\n\t\tdata_read latency (usec)\n");
	printa(@data_read);

	printf("\n\t\tsbd_do_read_xfer latency (usec)\n");
	printa(@read_xfer);

	printf("\n\t\tCounts\n");
	printa(@);
}
