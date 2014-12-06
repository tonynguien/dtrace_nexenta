#!/usr/sbin/dtrace -qs

fbt:stmf::entry
{
        @stmf[probefunc] = count();
}

fbt:stmf_sbd::entry
{
        @sbd[probefunc] = count();
}

fbt:pppt::entry
{
        @pppt[probefunc] = count();
}

profile:::tick-1s
{
        printf("\n==================");
        printa(@stmf);
        trunc(@stmf);

        printa(@sbd);
        trunc(@sbd);

        printa(@pppt);
        trunc(@pppt);
}

