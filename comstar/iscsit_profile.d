#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

fbt:iscsit::entry
{
	@[probefunc] = count();
}

profile:::tick-10s
{
        printa(@);
	trunc(@, 0);
}

