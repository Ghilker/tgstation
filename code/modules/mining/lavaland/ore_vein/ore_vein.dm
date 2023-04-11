/obj/structure/ore_vein
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE

	var/vein_size = 0
	var/infinite_vein = FALSE
	var/dropped_ore

/obj/structure/ore_vein/supermatter_crystal_vein
	name = "Supermatter Crystal Vein"
	infinite_vein = TRUE
	dropped_ore = /obj/item/vein_ore/supermatter_ore_shard

/obj/item/vein_ore
	name = "Drill box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "error"

/obj/item/vein_ore/supermatter_ore_shard
