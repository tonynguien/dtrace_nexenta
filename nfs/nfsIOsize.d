#!/usr/sbin/dtrace -qs

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
        @rbytes_total = quantize(args[2]->count);
}

nfsv3:nfssrv::op-write-start
{
        @wbytes = quantize(args[2]->data.data_len);
        @wbytes_total = quantize(args[2]->data.data_len);
}

nfsv4:nfssrv::op-write-start
{
        @wbytes = quantize(args[2]->data_len);
        @wbytes_total = quantize(args[2]->data_len);
}

profile:::tick-5sec
{
        /* print header */

        /* print read/write stats */
        printf("\nReads\n");
        printa(@rbytes); trunc(@rbytes);

        printf("\nWrites\n");
        printa(@wbytes); trunc(@wbytes);
}

dtrace:::END
{
        printf("\nRead total\n");
        printa(@rbytes_total);

        printf("\nWrite total\n");
        printa(@wbytes_total);

}
