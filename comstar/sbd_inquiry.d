#!/usr/sbin/dtrace -s

fbt:stmf_sbd:sbd_handle_inquiry:entry
{
	self->tr = 1 ;

	this->task = (scsi_task_t *) arg0;
	this->lu = (stmf_lu_t *) this->task->task_lu;
	this->sl = (sbd_lu_t *) this->lu->lu_provider_private;
	printf("sbd_handle_inquiry: %d\n", this->sl->sl_serial_no_size);
}

fbt:stmf_sbd:sbd_handle_short_read_transfers:entry
/self->tr/
{	
	this->p = (char *) arg2;

	printf("\nbyte[0]: %d\n", this->p[0]);
	printf("byte[1]: %x\n", this->p[1]);
	printf("byte[3]: %d\n", this->p[3]);
	printf("byte[4]: %s\n", stringof(this->p));
}

fbt:stmf_sbd:sbd_handle_inquiry:return
/self->tr/
{
	self->tr = 0;
}

