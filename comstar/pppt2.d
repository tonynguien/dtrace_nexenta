#!/usr/sbin/dtrace -qs

fbt:pppt:pppt_msg_scsi_cmd:entry
{
	self->note = 1;
        @[probefunc] = count();
}

fbt:pppt::entry
/self->note && probefunc != "pppt_msg_scsi_cmd"/
{
        @[probefunc] = count();
}

fbt:pppt:pppt_msg_scsi_cmd:return
/self->note/
{
	self->note = 0;
}

profile:::tick-5s
{
        printa(@);
        trunc(@,0);
}

