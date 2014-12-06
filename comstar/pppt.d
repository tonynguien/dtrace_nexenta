#!/usr/sbin/dtrace -qs

/* fbt:pppt:pppt_msg_scsi_cmd:entry */
fbt:pppt:pppt_msg_rx:entry
{
	self->note = 1;
        @[probefunc] = count();
}

fbt:pppt::entry
/self->note && probefunc != "pppt_msg_rx"/
{
        @[probefunc] = count();
}

/* fbt:pppt:pppt_msg_scsi_cmd:return */
fbt:pppt:pppt_msg_rx:return
/self->note/
{
	self->note = 0;
}

profile:::tick-5s
{
        printa(@);
        trunc(@,0);
}

