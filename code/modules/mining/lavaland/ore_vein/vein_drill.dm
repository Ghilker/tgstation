/obj/machinery/vein_drill
	icon = 'icons/obj/machines/vein_drill.dmi'
	icon_state = "vein_drill_core_off"

	var/active = FALSE

/obj/machinery/vein_drill/body
	density = TRUE

/obj/machinery/vein_drill/body/core
	icon_state = "vein_drill_core_off"

	use_power = NO_POWER_USE

	var/list/corners = list()
	var/obj/machinery/vein_drill/body/input/linked_input
	var/obj/machinery/vein_drill/body/output/linked_output
	var/obj/machinery/vein_drill/body/wall/linked_wall
	var/obj/machinery/vein_drill/body/interface/linked_interface

	var/progress = 0
	var/obj/structure/ore_vein/supermatter_crystal_vein/our_vein

/obj/machinery/vein_drill/body/core/process(delta_time)

	if(!active)
		return

	if(!check_part_connectivity())
		return

	if(!check_fuel_remaining())
		return

	if(progress < 10 SECONDS)
		progress += 1 * delta_time
		consume_fuel(100)
		return

	new our_vein.dropped_ore(get_turf(linked_output))
	progress = 0

/obj/machinery/vein_drill/body/core/update_appearance(updates)
	. = ..()
	if(active)
		icon_state = "vein_drill_core_on"
	else
		icon_state = "vein_drill_core_off"

/obj/machinery/vein_drill/body/core/proc/activate()
	active = TRUE
	update_appearance()

	linked_interface.active = FALSE
	linked_interface.update_appearance()

	linked_input.active = FALSE
	linked_input.update_appearance()

	linked_output.active = FALSE
	linked_output.update_appearance()

	linked_wall.active = FALSE
	linked_wall.update_appearance()

/obj/machinery/vein_drill/body/core/proc/deactivate()
	if(!active)
		return
	active = FALSE
	update_appearance()
	if(linked_interface)
		linked_interface.active = FALSE
		linked_interface.update_appearance()
		linked_interface = null
	if(linked_input)
		linked_input.active = FALSE
		linked_input.update_appearance()
		linked_input = null
	if(linked_output)
		linked_output.active = FALSE
		linked_output.update_appearance()
		linked_output = null
	if(linked_wall)
		linked_wall.active = FALSE
		linked_wall.update_appearance()
		linked_wall = null
	if(corners.len)
		for(var/obj/machinery/vein_drill/corner/corner in corners)
			corner.active = FALSE
			corner.update_appearance()
		corners = list()

/obj/machinery/vein_drill/body/core/proc/check_fuel_remaining(remaining_to_check = 0)
	. = TRUE
	if(linked_input.fuel_remaining <= remaining_to_check)
		. = FALSE

/obj/machinery/vein_drill/body/core/proc/consume_fuel(amount_to_consume = 0)
	. = TRUE
	if(!check_fuel_remaining(amount_to_consume))
		return FALSE

	linked_input.fuel_remaining = max(linked_input.fuel_remaining - amount_to_consume, 0)

/obj/machinery/vein_drill/body/core/proc/check_part_connectivity()
	. = TRUE
	if(!anchored || panel_open)
		return FALSE

	for(var/obj/machinery/vein_drill/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(istype(object,/obj/machinery/vein_drill/corner))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. = FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. = FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. = FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. = FALSE
			corners |= object
			continue

		if(get_step(object,turn(object.dir,180)) != loc)
			. = FALSE

		if(istype(object,/obj/machinery/vein_drill/body/input))
			if(linked_input && linked_input != object)
				. = FALSE
			linked_input = object

		if(istype(object,/obj/machinery/vein_drill/body/output))
			if(linked_output && linked_output != object)
				. = FALSE
			linked_output = object

		if(istype(object,/obj/machinery/vein_drill/body/wall))
			if(linked_wall && linked_wall != object)
				. = FALSE
			linked_wall = object

		if(istype(object,/obj/machinery/vein_drill/body/interface))
			if(linked_interface && linked_interface != object)
				. = FALSE
			linked_interface = object

	if(!linked_interface || !linked_input || !linked_wall || !linked_output || corners.len != 4)
		. = FALSE


/obj/machinery/vein_drill/corner
	icon_state = "vein_drill_corner"

/obj/machinery/vein_drill/body/input
	icon_state = "vein_drill_input"
	var/fuel_remaining = 0

/obj/machinery/vein_drill/body/input/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stack/sheet/mineral/uranium))
		var/obj/item/stack/sheet/mineral/uranium/uranium_sheet = item
		var/uranium_amount = uranium_sheet.amount
		if(uranium_sheet.use(uranium_sheet.amount))
			fuel_remaining += uranium_amount * MINERAL_MATERIAL_AMOUNT
		return
	return ..()

/obj/machinery/vein_drill/body/output
	icon_state = "vein_drill_output"

/obj/machinery/vein_drill/body/wall
	icon_state = "vein_drill_wall"

/obj/machinery/vein_drill/body/interface
	icon_state = "interface_off"
	var/obj/machinery/vein_drill/body/core/connected_core

/obj/machinery/vein_drill/body/interface/Destroy()
	if(connected_core)
		connected_core = null
	return..()

/obj/machinery/vein_drill/body/interface/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/turf/center_turf = get_step(src,turn(dir,180))
	var/obj/machinery/vein_drill/body/core/centre = locate() in center_turf

	if(!centre || !centre.check_part_connectivity())
		to_chat(user, span_notice("Check all parts and then try again."))
		return TRUE
	connected_core = centre

	connected_core.activate()
	return TRUE

/obj/item/drill_box
	name = "Drill box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "error"
	///What kind of box are we handling?
	var/box_type = "impossible"
	///What's the path of the machinery we making
	var/part_path

/obj/item/drill_box/corner
	name = "Drill box corner"
	desc = "Place this as the corner of your 3x3 multiblock fusion reactor"
	icon_state = "box_corner"
	box_type = "corner"
	part_path = /obj/machinery/vein_drill/corner

/obj/item/drill_box/body
	name = "Drill box body"
	desc = "Place this on the sides of the core box of your 3x3 multiblock fusion reactor"
	box_type = "body"
	icon_state = "box_body"

/obj/item/drill_box/body/input
	name = "Drill box fuel input"
	icon_state = "box_fuel"
	part_path = /obj/machinery/vein_drill/body/input

/obj/item/drill_box/body/output
	name = "Drill box moderator input"
	icon_state = "box_moderator"
	part_path = /obj/machinery/vein_drill/body/output

/obj/item/drill_box/body/wall
	name = "Drill box waste output"
	icon_state = "box_waste"
	part_path = /obj/machinery/vein_drill/body/wall

/obj/item/drill_box/body/interface
	name = "Drill box interface"
	part_path = /obj/machinery/vein_drill/body/interface

/obj/item/drill_box/core
	name = "Drill box core"
	desc = "Activate this with a multitool to deploy the full machinery after setting up the other boxes"
	icon_state = "box_core"
	box_type = "core"
	part_path = /obj/machinery/vein_drill/body/core

/obj/item/drill_box/core/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/parts = list()
	for(var/obj/item/drill_box/box in orange(1,src))
		var/direction = get_dir(src, box)
		if(box.box_type == "corner")
			if(ISDIAGONALDIR(direction))
				switch(direction)
					if(NORTHEAST)
						direction = EAST
					if(SOUTHEAST)
						direction = SOUTH
					if(SOUTHWEST)
						direction = WEST
					if(NORTHWEST)
						direction = NORTH
				box.dir = direction
				parts |= box
			continue
		if(box.box_type == "body")
			if(direction in GLOB.cardinals)
				box.dir = direction
				parts |= box
			continue
	if(parts.len == 8)
		build_drill(parts)
	return

/obj/item/drill_box/core/proc/build_drill(list/parts)

	var/found_vein
	var/turf/box_loc = get_turf(src)
	for(var/obj/object in box_loc.contents)
		if(!istype(object, /obj/structure/ore_vein))
			continue
		found_vein = object

	if(isnull(found_vein))
		return

	var/blocked_turf = FALSE
	var/list/around_turfs = RANGE_TURFS(1, src)
	for(var/turf/turf in around_turfs)
		if(!isclosedturf(turf))
			continue
		blocked_turf = TRUE

	if(blocked_turf)
		return

	for(var/obj/item/drill_box/box in parts)
		if(box.box_type == "corner")
			var/obj/machinery/vein_drill/corner/corner = new box.part_path(box.loc)
			corner.dir = box.dir
			qdel(box)
			continue
		if(box.box_type == "body")
			var/obj/machinery/vein_drill/body/part = new box.part_path(box.loc)
			part.dir = box.dir
			qdel(box)
			continue

	var/obj/machinery/vein_drill/body/core/made_core = new(loc, TRUE)
	made_core.our_vein = found_vein
	qdel(src)
