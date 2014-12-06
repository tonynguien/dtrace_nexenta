#!/usr/sbin/dtrace -Fs

fbt:mpt_sas:mptsas_handle_event:entry
{ self->trace = 1; }

fbt:mpt_sas:mptsas_handle_event_sync:entry
{ self->trace = 1; }

fbt:mpt_sas::
/self->trace/ { }

fbt:mpt_sas:mptsas_handle_event:return
/self->trace/ { self->trace = 0; }

fbt:mpt_sas:mptsas_handle_event_sync:return
/self->trace/ { self->trace = 0; }
