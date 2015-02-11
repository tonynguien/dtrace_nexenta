#!/usr/sbin/dtrace -qs

/*
 *  args[] =
 *  fct_cmd_t, cmd,
 *  fct_local_port_t, port,
 *  fct_i_remote_port_t, irp,
 *  int, cmd_type);
 */
fc:::rport-login-start
{
        this->cmd = (fct_cmd_t *) arg0;
        this->lport = (fct_local_port_t *) arg1;
        this->ilport = (fct_i_local_port_t *) this->lport->port_fct_private; 
        this->irport = (fct_i_remote_port_t *) arg2;
        this->rport = this->irport->irp_rp;

	printf("%Y alias:%s cmd_type:0x%x irp_flags:0x%x rport_id:0x%x rport:%s\n",
	    walltimestamp, stringof(this->ilport->iport_alias),
	    this->cmd->cmd_type, this->irport->irp_flags,
	    this->cmd->cmd_rportid, stringof(this->rport->rp_nwwn_str));
}
