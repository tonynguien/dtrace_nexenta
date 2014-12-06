#!/usr/sbin/dtrace -s

fbt:stmf:stmf_set_lu_access:entry
{
	@[probefunc, arg0] = count();
	stack();

	@stacks[stack()] = count();
}

fbt:stmf:stmf_abort:entry
{
	@[probefunc, arg0] = count();
	@stacks[stack()] = count();

	printf("abort cmd: %d\n", arg0);
}

profile:::tick-10s
{
        printa(@); trunc(@, 0);
        printa(@stacks);
}

