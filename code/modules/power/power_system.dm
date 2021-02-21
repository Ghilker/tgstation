/datum/power_system
	var/number_of_bars = 0 //amount of power bars available
	var/maximum_bars = 0 //max power bars allowed per area (3/4)
	var/minimum_bars = 0 //min power bars allowed per area (0)
	var/old_power = 0 //power before new tick
	var/power = 0 //power now
	var/energy_per_bar = 10 //Amount of energy required to aquire a power bar (10 KW?)
	var/emergency_bars = 0 //Emergency system (lights, doors, firelocks)
	var/engineering_bars = 0 //Engineering system (Engi, atmos, air control)
	var/service_bars = 0 //Service system (public areas, bar, kitchen, botany, etc)
	var/science_bars = 0 //Science system
	var/medical_bars = 0 //Medical system
	var/command_bars = 0 //Command system
	var/cargo_bars = 0 //Cargo system
	var/security_bars = 0 //Security system

/datum/power_system/New()
	SSmachines.powernets += src

/datum/power_system/proc/add_bars(amount)
	if(amount > 0)
		number_of_bars += amount

/datum/power_system/proc/remove_bars(amount)
	if(amount < 0)
		number_of_bars = max(number_of_bars - amount, 0)

/datum/power_system/proc/create_bars()
	if(power % energy_per_bar)
		return
	if((power / energy_per_bar) > number_of_bars)
		add_bars((power_generated / energy_per_bar) - number_of_bars)
	if((power / energy_per_bar) < number_of_bars)
		remove_bars(number_of_bars - (power / energy_per_bar))

