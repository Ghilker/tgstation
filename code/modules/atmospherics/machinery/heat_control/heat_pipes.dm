/datum/heat_conduit
	var/list/obj/machinery/heat_pipe/pipes = list()
	var/total_heat_capacity

/datum/heat_conduit/proc/add_conduit(obj/machinery/heat_pipe/pipe)
	pipes += pipe
	pipe.conduit = src

/datum/heat_conduit/proc/remove_conduit(obj/machinery/heat_pipe/pipe)
	pipes -= pipe

/datum/heat_conduit/proc/rebuild_conduit()
	total_heat_capacity = 0
	for(var/obj/machinery/heat_pipe/pipe in pipes)
		total_heat_capacity += pipe.heat_capacity


/obj/machinery/heat_pipe
	name = "heat pipe"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"
	var/datum/conduit
	var/heat_capacity = 500
