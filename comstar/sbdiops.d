#!/usr/sbin/dtrace -s

/*
 * Kfred's experiment with dtrace and FC 
 * 
 * key reference data is in https://wikis.oracle.com/display/DTrace/fibre+channel+Provider#
 */

#pragma D option quiet
#pragma D option defaultargs

inline int SCREEN = 21;

dtrace:::BEGIN
{
   printf("Tracing FC IO... Hit Ctrl-C to end.\n");
   lines = SCREEN +1;
   secs = $1 ? $1 : 10;
   interval = secs;
   counts = $2 ? $2 : -1; 
   readiops = readbytes = 0;
   writeiops = writebytes = 0;
   wmaxlatency = rmaxlatency = 0; 
   wminlatency = rminlatency = 999999999;
   first = 1;
}

profile:::tick-1sec
{
   secs--;
}

/*
 * Print header 
 */

fbt::sbd_handle_read:entry
/*fbt::stmf_itl_task_start:entry */
{
        start[ (uint64_t) args[0]] = timestamp;
}

fbt::sbd_handle_write:entry
/*fbt::stmf_itl_task_start:entry */
{
        start[ (uint64_t) args[0]] = timestamp;
}

/* read task completed */
/* stmf_task_free(struct scsi_task *task) */
fbt::stmf_task_free:entry
/start[ arg0] && args[0]->task_flags & 0x40/
{
   ++readiops;
   readbytes = readbytes + args[0]->task_cmd_xfer_length;
   this->latency = (timestamp - start[arg0])/1000;
   @rlatency = avg(this->latency);
   rmaxlatency = this->latency > rmaxlatency ? this->latency : rmaxlatency;
   rminlatency = this->latency < rminlatency ? this->latency : rminlatency;
}

/* write task completed */
/* stmf_task_free(struct scsi_task *task) */
fbt::stmf_task_free:entry
/start[ arg0] && args[0]->task_flags & 0x20/
{
   ++writeiops;
   writebytes = writebytes + args[0]->task_cmd_xfer_length;
   this->latency = (timestamp - start[arg0])/1000;
   @wlatency = avg(this->latency);
   wmaxlatency = this->latency > wmaxlatency ? this->latency : wmaxlatency;
   wminlatency = this->latency < wminlatency ? this->latency : wminlatency;
}

fc:::xfer-done
{
   start[arg0] = 0;
}


profile:::tick-1sec
/counts == 0/
{
   exit(0);
}

profile:::tick-1sec
/secs == 0/
{
   rmbps = readbytes / (1024 * 1024 * interval);
   wmbps = writebytes / (1024 * 1024 * interval);
   printf("R: %4d MB/s / %4d IOPS / ", rmbps, readiops/interval);
   printf("(%d/", rminlatency == 999999999 ? 0 : rminlatency );
   printa("%@u", @rlatency);
   printf("/%d) us     ", rmaxlatency);
   printf("W: %4d MB/s / %4d IOPS / ", wmbps, writeiops/interval);
   printf("(%d/", wminlatency == 999999999 ? 0 : wminlatency);
   printa("%@u", @wlatency);
   printf("/%d) us     ", wmaxlatency);
   printf("\n");
   readiops = readbytes = 0;
   writeiops = writebytes = rmaxlatency = wmaxlatency = 0;
   wminlatency = rminlatency = 999999999;
   trunc(@rlatency);
   trunc(@wlatency);
   secs = interval;
}
