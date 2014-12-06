#!/usr/sbin/dtrace -s

/*
 * (struct scsi_task *task, struct stmf_data_buf *initial_dbuf)
 */
fbt::sbd_new_task:entry
{
	this->task = (scsi_task_t *) arg0;
	this->it = (sbd_it_data_t *) this->task->task_lu_itl_handle;

	this->task_lu = (stmf_lu_t *) this->task->task_lu;
        this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

	@[stringof(this->sl->sl_name), this->task->task_additional_flags == 0x10 ? "pppt" : "local",
	    this->task->task_cdb[0], this->it->sbd_it_ua_conditions] = count();
	@total[stringof(this->sl->sl_name), this->task->task_additional_flags == 0x10 ? "pppt" : "local",
	    this->task->task_cdb[0], this->it->sbd_it_ua_conditions] = count();
}

profile:::tick-1s
{
	printf("\n");
	printa("%s (%s) 0x%x  0x%x    %@10d\n", @); trunc(@,0);
}

END
{
	printf("\n");
	printa("%s (%s) 0x%x  0x%x  %@15d\n", @total);
}

