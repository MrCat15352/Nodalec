/area/shuttle/nodalec
	requires_power = TRUE
	var/obj/docking_port/mobile/nodalec/shuttle_port

/area/shuttle/nodalec/connect_to_shuttle(mapload, obj/docking_port/mobile/voidcrew/port, obj/docking_port/stationary/dock)
	. = ..()
	if(!istype(port))
		stack_trace("nodalec shuttle area [type] is connecting to non-voidcrew shuttle port [port.type]")
	if(shuttle_port)
		UnregisterSignal(shuttle_port, COMSIG_PARENT_QDELETING)
	shuttle_port = port
	RegisterSignal(shuttle_port, COMSIG_PARENT_QDELETING, PROC_REF(on_shuttle_port_qdel))

/area/shuttle/nodalec/proc/on_shuttle_port_qdel()
	SIGNAL_HANDLER

	shuttle_port = null
