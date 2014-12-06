#!/usr/sbin/dtrace -s

fbt:stmf:stmf_ioctl:entry
{
	self->stmf = 1;
        @stmf[probefunc] = count();
        @stmf_cmds[arg1] = count();
}

fbt:stmf:stmf_load_ppd_ioctl:entry
/self->stmf/
{
        @stmf[probefunc] = count();
	printf("stmf_load_ppd_ioctl stack");
	ustack(50, 500);
	printf("===");
}

fbt:stmf_sbd:stmf_sbd_ioctl:entry
{
	self->sbd = 1;
        @sbd[probefunc] = count();
        @sbd_cmds[arg1] = count();
}

fbt:stmf_sbd:sbd_delete_lu:entry
/self->sbd/
{
	printf("sbd_delete_lu stack");
	ustack(50, 500);
	printf("===");
        @sbd[probefunc] = count();
}

fbt:stmf_sbd:stmf_sbd_ioctl:return
/self->sbd/
{
	self->sbd = 0;
}

profile:::tick-10s
{
        printf("\n==================");
        printa(@stmf); trunc(@stmf, 0);
        printa("%x %@20d\n",@stmf_cmds); trunc(@stmf_cmds, 0);

        printa(@sbd); trunc(@sbd, 0);
        printa("%x %@20d\n", @sbd_cmds); trunc(@sbd_cmds, 0);
}

