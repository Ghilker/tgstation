/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	name = "bluespace atmos sender"
	desc = "Use the power of bluespace technology to send gases through the network."
	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"
	var/datum/gas_mixture/bluespace_network
	var/gas_transfer_rate = 10
	var/price_multiplier = 1
	var/list/base_prices = list(
		/datum/gas/oxygen = 1,
		/datum/gas/nitrogen = 1,
		/datum/gas/water_vapor = 3,
		/datum/gas/plasma = 3,
		/datum/gas/carbon_dioxide = 2,
		/datum/gas/nitrous_oxide = 4,
		/datum/gas/pluoxium = 4,
		/datum/gas/tritium = 5,
		/datum/gas/bz = 4,
		/datum/gas/freon = 6,
		/datum/gas/hydrogen = 4,
		/datum/gas/healium = 6,
		/datum/gas/proto_nitrate = 3,
		/datum/gas/zauker = 10,
		/datum/gas/miasma = 3
	)

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/Initialize()
	. = ..()
	initialize_directions = dir
	bluespace_network = new
	for(var/gas_id in GLOB.meta_gas_info)
		bluespace_network.assert_gas(gas_id)


/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(on && is_operational)
		icon_state = icon_state_on
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/update_overlays()
	. = ..()
	. += getpipeimage(icon, "pipe", dir, , piping_layer)

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/process_atmos()
	if(!is_operational || !on || !nodes[1])  //if it has no power or its switched off, dont process atmos
		return
	var/datum/gas_mixture/air_contents = airs[1]
	var/datum/gas_mixture/remove = air_contents.remove(gas_transfer_rate)
	bluespace_network.merge(remove)
	update_parents()

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceAtmosSender", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["gas_transfer_rate"] = gas_transfer_rate
	data["price_multiplier"] = price_multiplier
	var/list/bluespace_gasdata = list()
	if(bluespace_network.total_moles())
		for(var/gas_id in bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
			"name"= bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
			"amount" = round(bluespace_network.gases[gas_id][MOLES], 0.01),
			"price" = base_prices[gas_id] * price_multiplier
			)))
	else
		for(var/gas_id in bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
				"name"= bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
				"amount" = 0,
				"price" = 0
				)))
	data["bluespace_network_gases"] = bluespace_gasdata
	return data

/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE

/obj/machinery/bluespace_atmos_vendor
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	name = "bluespace atmos vendor"
	desc = "Gas vendor connected to the bluespace network."
	var/obj/machinery/atmospherics/components/unary/bluespace_atmos_sender
	var/tank_max = 10