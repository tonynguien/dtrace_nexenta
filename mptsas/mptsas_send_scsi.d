#!/usr/sbin/dtrace -s

#
# Verify OS-91 fix by making sure pkt_time is set to 5 secs
#
mptsas_send_scsi_cmd:entry
{
	self->tr = 1;
	/* stack(); */
}

scsi_poll:entry
/self->tr/
{
	printf("pkt_time:%d\n", ((struct scsi_pkt *)arg0)->pkt_time);
}

mptsas_send_scsi_cmd:return /self->tr/ { self->tr = 0; }
