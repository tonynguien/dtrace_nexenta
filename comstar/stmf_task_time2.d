#!/usr/sbin/dtrace -qs

dtrace:::BEGIN
{
	r_iops = 1;
        rtask = 0;
        rqtime = 0;
        r_lu_xfer = 0;
        r_lport_xfer = 0;

	w_iops = 1;
        wtask = 0;
        wqtime = 0;
        w_lu_xfer = 0;
        w_lport_xfer = 0;
}

/*
 * read task completed
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x40/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->sl = (sbd_lu_t *) this->lu->lu_provider_private;

        @reads[stringof(this->sl->sl_name)] = count();
}

/*
 * write task completed
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x20/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->sl = (sbd_lu_t *) this->lu->lu_provider_private;

        @writes[stringof(this->sl->sl_name)] = count();
}

sdt:stmf:stmf_task_free:stmf-task-end
/!((scsi_task_t *) arg0)->task_flags & 0x20 && !((scsi_task_t *) arg0)->task_flags & 0x40/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->sl = (sbd_lu_t *) this->lu->lu_provider_private;

        @others[stringof(this->sl->sl_name)] = avg(arg1/1000);
}


profile:::tick-3sec
{
        printf("\n*****\n");
        printf("\nreads");
	normalize(@reads, 3);
	printa(@reads); trunc(@reads, 0);

        printf("\nwrites");
	normalize(@writes, 3);
	printa(@writes); trunc(@writes, 0);

        printf("\nother cmds");
	normalize(@others, 3);
	printa(@others); trunc(@others, 0);
}
