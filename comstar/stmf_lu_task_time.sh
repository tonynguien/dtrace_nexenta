#!/usr/bin/sh
#

### Default variables
opt_lu=0; lu="";

### Process options
while getopts l: name
do
        case $name in
        l)      opt_lu=1; lu=$OPTARG ;;
        esac
done
shift `expr $OPTIND - 1`

### Option logic
[ $opt_lu -eq 0 ] && exit 1


#################################
# --- Main Program, DTrace ---
#

### Define D Script
/usr/sbin/dtrace -n '

#pragma D option quiet

 /*
  * Command line arguments
  */
inline string LU = "'$lu'";

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

	cmds = 1;
        ctask = 0;
        cqtime = 0;
        c_lu_xfer = 0;
        c_lport_xfer = 0;

        printf("\nreads/sec  Avg:lu_xfer/lport_xfer/qtime/task_total(usec)   ");
        printf("writes/sec   Avg:lu_xfer/lport_xfer/qtime/task_total(usec)");
}

/*
 * read task completed
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x40 &&
 ((sbd_lu_t *) ((stmf_lu_t *) ((scsi_task_t *)arg0)->task_lu)->lu_provider_private)->sl_name == LU/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;

	r_iops = r_iops + 1;

        rtask = rtask + (arg1 / 1000);
        rqtime = rqtime + (this->itask->itask_waitq_time / 1000);
        r_lu_xfer = r_lu_xfer + (this->itask->itask_lu_read_time / 1000);
        r_lport_xfer = r_lport_xfer + (this->itask->itask_lport_read_time / 1000);
}

/*
 * write task completed
 */
sdt:stmf:stmf_task_free:stmf-task-end
/((scsi_task_t *) arg0)->task_flags & 0x20 &&
 ((sbd_lu_t *) ((stmf_lu_t *) ((scsi_task_t *)arg0)->task_lu)->lu_provider_private)->sl_name == LU/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;

	w_iops = w_iops + 1;

        wtask = wtask + (arg1 / 1000);
        wqtime = wqtime + (this->itask->itask_waitq_time / 1000);
        w_lu_xfer = w_lu_xfer + (this->itask->itask_lu_write_time / 1000);
        w_lport_xfer = w_lport_xfer + (this->itask->itask_lport_write_time / 1000);
}

/*
 * other comnpleted tasks XXXX needs to fill out  
 */
sdt:stmf:stmf_task_free:stmf-task-end
/!((scsi_task_t *) arg0)->task_flags & 0x20 && !((scsi_task_t *) arg0)->task_flags & 0x40 &&
 ((sbd_lu_t *) ((stmf_lu_t *) ((scsi_task_t *)arg0)->task_lu)->lu_provider_private)->sl_name == LU/
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;

	cmds = cmds + 1;

        ctask = ctask + (arg1 / 1000);
        cqtime = cqtime + (this->itask->itask_waitq_time / 1000);
        c_lu_xfer = c_lu_xfer + (this->itask->itask_lu_write_time / 1000);
        c_lport_xfer = c_lport_xfer + (this->itask->itask_lport_write_time / 1000);
}

profile:::tick-3sec
/r_iops || w_iops/
{
        avg_task = rtask / r_iops;
        avg_qtime = rqtime / r_iops;
        avg_lu_xfer = r_lu_xfer / r_iops;
        avg_lport_xfer = r_lport_xfer / r_iops;
	r_iops = r_iops / 3;

        printf("\nreads/s: %d  (%d/%d/%d/%d)  ", r_iops,
	    avg_lu_xfer, avg_lport_xfer, avg_qtime, avg_task);

        avg_task = wtask / w_iops;
        avg_qtime = wqtime / w_iops;
        avg_lu_xfer = w_lu_xfer / w_iops;
        avg_lport_xfer = w_lport_xfer / w_iops;
	w_iops = w_iops / 3;

        printf("writes/s: %d  (%d/%d/%d/%d)  ", w_iops,
	    avg_lu_xfer, avg_lport_xfer, avg_qtime, avg_task);

        avg_task = ctask / cmds;
        avg_qtime = cqtime / cmds;
        avg_lu_xfer = c_lu_xfer / cmds;
        avg_lport_xfer = c_lport_xfer / cmds;
	cmds = cmds / 3;
        printf("non-iops/s: %d  (%d/%d/%d/%d)", cmds,
	    avg_lu_xfer, avg_lport_xfer, avg_qtime, avg_task);

	/* Resetting globals */
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

	cmds = 1;
        ctask = 0;
        cqtime = 0;
        c_lu_xfer = 0;
        c_lport_xfer = 0;
}
'
