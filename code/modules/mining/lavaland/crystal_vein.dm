/obj/structure/ore_vein
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

	var/vein_size = 0
	var/infinite_vein = FALSE

/obj/structure/ore_vein/supermatter_crystal_vein
	name = "Supermatter Crystal Vein"
	infinite_vein = TRUE

/obj/structure/vein_drill
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core_off"

/obj/structure/vein_drill/body
	density = TRUE

/obj/structure/vein_drill/body/core
	icon_state = "core_off"

/obj/structure/vein_drill/body/core/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/vein_drill/body/core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/vein_drill/corner
	icon_state = "corner_off"

/obj/structure/vein_drill/body/input
	icon_state = "fuel_input_off"

/obj/structure/vein_drill/body/output
	icon_state = "waste_output_off"

/obj/structure/vein_drill/body/wall
	icon_state = "moderator_input_off"

/obj/structure/vein_drill/body/interface
	icon_state = "interface_off"

/obj/item/drill_box
	name = "Drill box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "error"
	///What kind of box are we handling?
	var/box_type = "impossible"
	///What's the path of the machine we making
	var/part_path

/obj/item/drill_box/corner
	name = "Drill box corner"
	desc = "Place this as the corner of your 3x3 multiblock fusion reactor"
	icon_state = "box_corner"
	box_type = "corner"
	part_path = /obj/structure/vein_drill/corner

/obj/item/drill_box/body
	name = "Drill box body"
	desc = "Place this on the sides of the core box of your 3x3 multiblock fusion reactor"
	box_type = "body"
	icon_state = "box_body"

/obj/item/drill_box/body/input
	name = "Drill box fuel input"
	icon_state = "box_fuel"
	part_path = /obj/structure/vein_drill/body/input

/obj/item/drill_box/body/output
	name = "Drill box moderator input"
	icon_state = "box_moderator"
	part_path = /obj/structure/vein_drill/body/output

/obj/item/drill_box/body/wall
	name = "Drill box waste output"
	icon_state = "box_waste"
	part_path = /obj/structure/vein_drill/body/wall

/obj/item/drill_box/body/interface
	name = "Drill box interface"
	part_path = /obj/structure/vein_drill/body/interface

/obj/item/drill_box/core
	name = "Drill box core"
	desc = "Activate this with a multitool to deploy the full machine after setting up the other boxes"
	icon_state = "box_core"
	box_type = "core"
	part_path = /obj/structure/vein_drill/body/core

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

	var/found_vein = FALSE
	var/turf/box_loc = get_turf(src)
	for(var/obj/object in box_loc.contents)
		if(!istype(object, /obj/structure/ore_vein))
			continue
		found_vein = TRUE

	if(!found_vein)
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
			var/obj/structure/vein_drill/corner/corner = new box.part_path(box.loc)
			corner.dir = box.dir
			qdel(box)
			continue
		if(box.box_type == "body")
			var/obj/structure/vein_drill/body/part = new box.part_path(box.loc)
			part.dir = box.dir
			qdel(box)
			continue

	new/obj/structure/vein_drill/body/core(loc, TRUE)
	qdel(src)
