#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing STMF... Hit Ctrl-C to end.\n");
}

/* stmf_itl_task_start(stmf_i_scsi_task_t *itask) */
fbt::stmf_itl_task_start:entry
{
	/* use the pointer to the scsi task structure */
	start[args[0]->itask_task] = timestamp; 
        stmf_incount++;
}

/* data xfer start */
/* stmf_lu_xfer_start(scsi_task_t *task) */
fbt::stmf_lu_xfer_start:entry
/start[ (scsi_task_t *) arg0]/
{
	this->now = timestamp;
	setuptime[ (scsi_task_t *) arg0] = this->now - start[ (scsi_task_t *) arg0]; 
	xferstart[arg0] = this->now;
}

/* data xfer complete */
/* stmf_lu_xfer_done(scsi_task_t *task, boolean_t read, uint64_t xfer_bytes, hrtime_t elapsed_time) */
fbt::stmf_lu_xfer_done:entry
/start[ (scsi_task_t *) arg0]/
{
	xferdone[arg0] = timestamp;
	xfertime[arg0] = xferdone[arg0] - xferstart[arg0]; 
	xferdone[arg0] = xferdone[arg0];
}

/* read task completed */
/* sbd_task_free(struct scsi_task *task) */
fbt::stmf_task_free:entry
/start[ (scsi_task_t *) arg0] && args[0]->task_flags & 0x40/
{
	this->now = timestamp;
	this->elapsed = timestamp - start[ (scsi_task_t *) arg0];
	@op["Read Setup"] = quantize(setuptime[ (scsi_task_t *) arg0]/1000);
	@op["Read Xfer"] = quantize(xfertime[ arg0]/1000);
	@op["Read Status"] = quantize((this->now - xferdone[arg0])/1000);
        @op["Overall Reads"] = quantize(this->elapsed/1000);
        start[ (scsi_task_t *) arg0] = 0;
	xferdone[ arg0] = 0;
}

/* write task completed */
/* sbd_task_free(struct scsi_task *task) */
fbt::stmf_task_free:entry
/start[ (scsi_task_t *) arg0] && args[0]->task_flags & 0x20/
{
	this->now = timestamp;
	this->elapsed = this->now - start[ (scsi_task_t *) arg0];
	@op["Write Setup"] = quantize(setuptime[ (scsi_task_t *) arg0]/1000);
	@op["Write Xfer"] = quantize(xfertime[arg0]/1000);
	@op["Write Status"] = quantize((this->now - xferdone[arg0])/1000);
        @op["Overall Writes"] = quantize(this->elapsed/1000);
        start[ (scsi_task_t *) arg0] = 0;
	xferdone[arg0] = 0;
}
dtrace:::END
{
	printa(@op);
}
