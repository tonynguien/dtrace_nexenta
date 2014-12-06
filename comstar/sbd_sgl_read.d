#!/usr/sbin/dtrace -s

sbd_handle_read:entry { self->tr = 1; }

stmf_xfer_data:entry
/self->tr/ { @[stack(), args[1]->db_buf_size] = count(); }

sbd_handle_read:return
/self->tr/ {self->tr = 0; }
