#!/usr/sbin/dtrace -s

fbt::ql_done:entry
{
	self->sp = (ql_srb_t *) args[0]->base_address;
	self->ha = (ql_adapter_state_t *) self->sp->ha;
	self->pkt = (fc_packet_t *) self->sp->pkt;
	self->fcp_pkt = (struct fcp_pkt *) self->pkt->pkt_ulp_private;
	self->scsi_pkt = (struct scsi_pkt *) self->fcp_pkt->cmd_pkt;
	@[self->scsi_pkt->pkt_cdbp[0], self->sp->wdg_q_time, self->sp->init_wdg_q_time, self->sp->flags] = count(); 
	printa("0x%x 0x%x 0x%x 0x%x %@10d\n", @);
}

/*
profile:::tick-1sec
{ printa("0x%x 0x%x 0x%x 0x%x %@10d\n", @); }
*/
