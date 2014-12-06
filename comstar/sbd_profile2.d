#!/usr/sbin/dtrace -qs

fbt:stmf_sbd::entry
{
        @sbd[probefunc] = count();
}

profile:::tick-5s
{
        printa(@sbd);
        clear(@sbd);
}

