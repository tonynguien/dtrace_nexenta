#!/usr/sbin/dtrace -qs

dtrace:::BEGIN
{
        printf("Tracing scsi_task_t in sbd_do_sgl_read_xfer... Hit Ctrl-C to end.\n");
        printf("expected_xfer/max_nbufs/cur_nbufs/cmd_xfer/max_xfern/1st_xfer/copy_threshold\n");
}
fbt::sbd_handle_read:entry
{
	@[args[0]->task_expected_xfer_length, args[0]->task_max_nbufs, args[0]->task_cur_nbufs,
	    args[0]->task_cmd_xfer_length, args[0]->task_max_xfer_len,
	    args[0]->task_1st_xfer_len, args[0]->task_copy_threshold] = count();
}

profile:::tick-1sec { printa("0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x %@-6d\n", @); }
