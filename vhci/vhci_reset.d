#!/usr/sbin/dtrace -s

fbt:scsi_vhci:vhci_scsi_reset*:entry,
fbt:scsi_vhci:vhci_recovery_reset*:entry
{ @[stack()] = count(); stack(); }

fbt:sd:sd_reset_target:entry
{ @[stack()] = count(); stack(); }

fbt:scsi:scsi_reset:entry
{ @[stack()] = count(); stack(); }

fbt:mpt_sas:mptsas*reset:entry
{ @[stack()] = count(); stack(); }
