#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

/*fbt:stmf::entry*/
/* does stmf_dlun_dbuf_done get called from dlun_new_task? */
/*fbt::stmf_dlun0_new_task:entry*/

fbt:stmf:stmf_dlun0*:entry
{
	@[probefunc] = count();
}

profile:::tick-10s
{
        printa(@);
}

