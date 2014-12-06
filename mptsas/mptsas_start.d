#!/usr/sbin/dtrace -Fs

fbt:mpt_sas:mptsas_scsi_start:entry
{
        self->name = probefunc;
        self->trace = 1;
}

fbt:mpt_sas::
/self->trace/ { }

fbt:mpt_sas:mptsas_scsi_start:return
/self->trace/ { self->trace = 0; }

