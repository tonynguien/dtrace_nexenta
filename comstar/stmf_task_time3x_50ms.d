#!/usr/sbin/dtrace -qs

dtrace:::BEGIN
{
	printf("Tracking reads and writes longer than > 50ms\n");
}

/*
 * read task completed > 100ms
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x40 && (arg1 / 1000) > 50000/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;
        this->session = (stmf_scsi_session_t *) this->task->task_session;
        this->irport= (fct_i_remote_port_t *) this->session->ss_port_private;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

	/* task total */
	rtask = (arg1 / 1000); /* slightly off since this is different accounting point */
        rqtime = (this->itask->itask_waitq_time / 1000);
        r_lu_xfer = (this->itask->itask_lu_read_time / 1000);
        r_lport_xfer = (this->itask->itask_lport_read_time / 1000);
        printf("read: %s rport_pwwn:%s  Time:%d/%d/%d/%d\n",
	    stringof(this->lu->lu_alias), stringof(this->rport->rp_pwwn_str),
	    r_lu_xfer, r_lport_xfer, rqtime, rtask);
	@[stringof(this->lu->lu_alias), stringof(this->rport->rp_pwwn_str)] = count();
}

/*
 * write task completed > 100ms
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x20 && (arg1 / 1000) > 50000/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;
        this->session = (stmf_scsi_session_t *) this->task->task_session;
        this->irport= (fct_i_remote_port_t *) this->session->ss_port_private;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

	/* Save total time in usecs */
        wtask = (arg1 / 1000); /* slightly off since this is different accounting point */
        wqtime = (this->itask->itask_waitq_time / 1000);
        w_lu_xfer = (this->itask->itask_lu_write_time / 1000);
        w_lport_xfer = (this->itask->itask_lport_write_time / 1000);
        printf("write: %s rport_pwwn:%s  Time:%d/%d/%d/%d\n",
	    stringof(this->lu->lu_alias), stringof(this->rport->rp_pwwn_str),
	    w_lu_xfer, w_lport_xfer, wqtime, wtask);
	@[stringof(this->lu->lu_alias), stringof(this->rport->rp_pwwn_str)] = count();
}
