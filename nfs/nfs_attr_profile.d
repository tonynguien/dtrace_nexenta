#!/usr/sbin/dtrace -qs

nfsv3:::op-getattr-start,
nfsv3:::op-access-start,
nfsv3:::op-readdir-start
{
	@file[args[1]->noi_curpath, args[0]->ci_remote] = count();
	@[probefunc] = count();
}

nfsv4:::op-getattr-start,
nfsv4:::op-access-start,
nfsv4:::op-readdir-start
{
	@file[args[1]->noi_curpath, args[0]->ci_remote] = count();
	@[probefunc] = count();
}

profile:::tick-10sec
{
	printf("%Y", walltimestamp);
	printa(@); trunc(@);
	printa(@file); trunc(@file);
}
