#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

fbt:stmf::entry,
fbt:stmf_sbd::entry,
fbt:fcp::entry,
fbt:qlt::entry,
fbt:fct::entry
{
	/* @[probefunc] = count(); */
}

fbt:stmf::return,
fbt:stmf_sbd::return,
fbt:fcp::return,
fbt:qlt::return,
fbt:fct::return
{
	/* @[probefunc] = count(); */
}

/*
profile:::tick-3s
{
        printa(@); trunc(@, 0);
}
*/

