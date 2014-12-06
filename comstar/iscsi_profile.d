#!/usr/sbin/dtrace -qs

fbt:stmf::entry
{
        @stmf[probefunc] = count();
}

fbt:iscsit::entry
{
        @iscsit[probefunc] = count();
}

profile:::tick-5s
{
        printf("\n==================");
        printa(@stmf);
        clear(@stmf);

        printa(@iscsit);
        clear(@iscsit);
}

