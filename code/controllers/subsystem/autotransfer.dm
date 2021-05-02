SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/init_transfer
	var/start_time
	var/vote_interval
	var/max_votes
	var/current_votes = 0

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	var/init_time = 72000
	start_time = world.realtime
	init_transfer = start_time + init_time
	vote_interval = 18000
	max_votes = 4
	return ..()

/datum/controller/subsystem/autotransfer/fire()
	if(world.realtime < init_transfer)
		return
	if(max_votes > current_votes)
		SSvote.initiate_vote("transfer","server")
		init_transfer = init_transfer + vote_interval
		current_votes++
	else
		SSshuttle.autoEnd()

/datum/controller/subsystem/autotransfer/Recover()
	start_time = SSautotransfer.start_time
	vote_interval = SSautotransfer.vote_interval
	current_votes = SSautotransfer.current_votes

/datum/controller/subsystem/shuttle/proc/autoEnd()
	if(EMERGENCY_IDLE_OR_RECALLED)
		SSshuttle.emergency.request(silent = TRUE)
		priority_announce("The shift has come to an end and the shuttle called. It will arrive in [emergency.timeLeft(600)] minutes.", null, "shuttlecalled", "Priority")
		log_game("Round end vote passed. Shuttle has been auto-called.")
		message_admins("Round end vote passed. Shuttle has been auto-called.")
	emergencyNoRecall = TRUE
