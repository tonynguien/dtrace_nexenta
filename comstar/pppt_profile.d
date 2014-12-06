#!/usr/sbin/dtrace -s

fbt:pppt::entry
{
        @[probefunc] = count();
}

fbt:stmf:stmf_abort:entry,
fbt:stmf:stmf_set_lu_access:entry
{
	@[probefunc] = count();
	@stacks[stack()] = count();
	stack();
}

profile:::tick-1s
{
        printa(@); trunc(@, 0);
        printa(@stacks);
}

