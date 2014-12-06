#!/usr/sbin/dtrace -s

/*
 * Tony Nguyen
 * A quick script to catch cmd failures that result in vhci_log.
 * Not a generic debug script.
 *
 */
fbt:scsi_vhci:vhci_intr:entry
{
	self->tr = 1;
	self->scsi_pkt = args[0];
	self->stat = self->scsi_pkt->pkt_statistics;
}

fbt:scsi_vhci:vhci_log:entry
/self->tr/
{
	self->cdbp0 = self->scsi_pkt->pkt_cdbp[0];
	self->cdbp1 = self->scsi_pkt->pkt_cdbp[1];
	self->reason = self->scsi_pkt->pkt_reason;
	self->time = self->scsi_pkt->pkt_time;
	self->flags = self->scsi_pkt->pkt_flags;
	self->start = self->scsi_pkt->pkt_start;
	self->stop = self->scsi_pkt->pkt_stop;

	printf("cdbp[0]:0x%x reason:0x%x flags:0x%x stat:0x%x time:%d start:%d stop:%d\n",
	    self->cdbp0, self->reason, self->flags, self->stat,
	    self->time, self->start, self->stop); 
}

fbt:scsi_vhci:vhci_intr:return
/self->tr/
{
	self->tr = 0; self->scsi_pkt = 0;
	self->cdbp0 = 0;
	self->cdbp1 = 0;
	self->reason = 0;
	self->flags = 0;
	self->stat = 0;
	self->time = 0;
	self->start = 0;
	self->stop = 0;
}
