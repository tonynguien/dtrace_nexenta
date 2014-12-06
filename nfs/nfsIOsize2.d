#!/usr/sbin/dtrace -s

dtrace:::BEGIN
{
        scriptstart = walltimestamp;
        timestart = timestamp;
}

nfsv3:nfssrv::op-read-start,
nfsv4:nfssrv::op-read-start
{
        /* time response */
        @rbytes = quantize(args[2]->count);
}

/*
nfsv3:nfssrv::op-read-done,
nfsv4:nfssrv::op-read-done
/self->start/
{
        self->start = 0;
}
*/

nfsv3:nfssrv::op-write-start
{
        @wbytes = quantize(args[2]->data.data_len);
}

nfsv4:nfssrv::op-write-start
{
        @wbytes = quantize(args[2]->data_len);
}

profile:::tick-1sec
{
        /* print header */

        /* print read/write stats */
        printf("\nReads\n");
        printa(@rbytes); trunc(@rbytes);

        printf("\nWrites\n");
        printa(@wbytes); trunc(@wbytes);
}
