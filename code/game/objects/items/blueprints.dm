///The area is a "Station" area, showing no special text.
#define AREA_STATION 1
///The area is in outdoors (lavaland/icemoon/jungle/space), therefore unclaimed territories.
#define AREA_OUTDOORS 2
///The area is special (shuttles/centcom), therefore can't be claimed.
#define AREA_SPECIAL 3

///The blueprints are currently reading the list of all wire datums.
#define LEGEND_VIEWING_LIST "watching_list"
///The blueprints are on the main page.
#define LEGEND_OFF "off"

#define BP_MAX_ROOM_SIZE 300

/**
 * Blueprints
 * Used to see the wires of machines on the station, the roundstart layout of pipes/cables/tubes,
 * as well as allowing you to rename existing areas and create new ones.
 * Used by the station, cyborgs, and golems.
 */
/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "blueprints"
	inhand_icon_state = "blueprints"
	attack_verb_continuous = list("attacks", "baps", "hits")
	attack_verb_simple = list("attack", "bap", "hit")
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION | INTERACT_ATOM_IGNORE_MOBILITY

	///A string of flavortext to be displayed at the top of the UI, related to the type of blueprints we are.
	var/fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	///Boolean on whether the blueprints are currently being used, which prevents double-using them to rename/create areas.
	var/in_use = FALSE
	///The type of area we'll create when we make a new area. This is a typepath.
	var/area/new_area_type = /area
	///The legend type the blueprints are currently looking at, which is either modularly
	///set by wires datums, the main page, or an overview of them all.
	var/legend_viewing = LEGEND_OFF

	///List of images that we're showing to a client, used for showing blueprint data.
	var/list/image/showing = list()
	///The client that is being shown the list of 'showing' images of blueprint data.
	var/client/viewing

/obj/item/blueprints/Destroy()
	clear_viewer()
	return ..()

/obj/item/blueprints/dropped(mob/user)
	. = ..()
	clear_viewer()
	legend_viewing = LEGEND_OFF

/obj/item/blueprints/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Blueprints", name)
		ui.open()

/obj/item/blueprints/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/blueprints/ui_data(mob/user)
	var/list/data = list()
	switch(get_area_type(user))
		if(AREA_OUTDOORS)
			data["area_notice"] = "You are in unclaimed territory."
		if(AREA_SPECIAL)
			data["area_notice"] = "This area has no notes."
		else
			var/area/current_area = get_area(user)
			data["area_notice"] = "You are now in \the [current_area.name]"
	var/area/area_inside_of = get_area(user)
	data["area_name"] = html_encode(area_inside_of.name)
	data["legend"] = legend_viewing
	data["viewing"] = !!viewing
	data["wire_data"] = list()
	if(legend_viewing != LEGEND_VIEWING_LIST && legend_viewing != LEGEND_OFF)
		for(var/device in GLOB.wire_color_directory)
			if("[device]" != legend_viewing)
				continue
			data["wires_name"] = GLOB.wire_name_directory[device]
			for(var/individual_color in GLOB.wire_color_directory[device])
				var/wire_name = GLOB.wire_color_directory[device][individual_color]
				if(findtext(wire_name, WIRE_DUD_PREFIX)) //don't show duds
					continue
				data["wire_data"] += list(list(
					"color" = individual_color,
					"message" = wire_name,
				))
	return data

/obj/item/blueprints/ui_static_data(mob/user)
	var/list/data = list()
	data["legend_viewing_list"] = LEGEND_VIEWING_LIST
	data["legend_off"] = LEGEND_OFF
	data["fluff_notice"] = fluffnotice
	data["station_name"] = station_name()
	data["wire_devices"] = list()
	for(var/wireset in GLOB.wire_color_directory)
		data["wire_devices"] += list(list(
			"name" = GLOB.wire_name_directory[wireset],
			"ref" = wireset,
		))
	return data

/obj/item/blueprints/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(!user.can_perform_action(src, NEED_LITERACY|NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING))
		return TRUE

	switch(action)
		if("create_area")
			if(in_use)
				return
			in_use = TRUE
			create_area(user, new_area_type)
			in_use = FALSE
		if("edit_area")
			if(get_area_type(user) != AREA_STATION)
				return
			if(in_use)
				return
			in_use = TRUE
			edit_area(user)
			in_use = FALSE
		if("exit_legend")
			legend_viewing = LEGEND_OFF
		if("view_legend")
			legend_viewing = LEGEND_VIEWING_LIST
		if("view_wireset")
			var/setting_wireset = params["view_wireset"]
			for(var/device in GLOB.wire_color_directory)
				if("[device]" == setting_wireset) //I know... don't change it...
					legend_viewing = setting_wireset
					return TRUE
		if("view_blueprints")
			playsound(src, 'sound/items/paper_flip.ogg', 40, TRUE)
			user.balloon_alert_to_viewers("flips blueprints over")
			set_viewer(user)
		if("hide_blueprints")
			playsound(src, 'sound/items/paper_flip.ogg', 40, TRUE)
			user.balloon_alert_to_viewers("flips blueprints over")
			clear_viewer()
		if("refresh")
			playsound(src, 'sound/items/paper_flip.ogg', 40, TRUE)
			clear_viewer()
			set_viewer(user)
	return TRUE

/**
 * Sets the user's client as the person viewing blueprint data, and builds blueprint data
 * around the user.
 * Args:
 * - user: The person who's client we're giving images to.
 */
/obj/item/blueprints/proc/set_viewer(mob/user)
	if(!user || !user.client)
		return
	if(viewing)
		clear_viewer()
	viewing = user.client
	showing = get_blueprint_data(get_turf(viewing.eye || user), viewing.view)
	viewing.images |= showing

/**
 * Clears the client we're showig images to and deletes the images of blueprint data
 * we made to show them.
 */
/obj/item/blueprints/proc/clear_viewer()
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()

/**
 * Gets the area type the user is currently standing in.
 * Returns: AREA_STATION, AREA_OUTDOORS, or AREA_SPECIAL
 * Args:
 * - user: The person we're getting the area of to check if it's a special area.
 */
/obj/item/blueprints/proc/get_area_type(mob/user)
	var/area/area_checking = get_area(user)
	if(area_checking.outdoors)
		return AREA_OUTDOORS
	var/static/list/special_areas = typecacheof(list(
		/area/shuttle,
		/area/centcom,
		/area/centcom/asteroid,
		/area/centcom/tdome,
		/area/centcom/wizard_station,
		/area/misc/hilbertshotel,
		/area/misc/hilbertshotelstorage,
	))
	if(area_checking.type in special_areas)
		return AREA_SPECIAL
	return AREA_STATION

/**
 * edit_area
 * Takes input from the player and renames the area the blueprints are currently in.
 */
/obj/item/blueprints/proc/edit_area(mob/user)
	var/area/area_editing = get_area(src)
	var/prevname = "[area_editing.name]"
	var/new_name = tgui_input_text(user, "New area name", "Area Creation", max_length = MAX_NAME_LEN)
	if(isnull(new_name) || !length(new_name) || new_name == prevname)
		return

	rename_area(area_editing, new_name)
	user.balloon_alert(user, "area renamed to [new_name]")
	user.log_message("has renamed [prevname] to [new_name]", LOG_GAME)
	return TRUE

///Cyborg blueprints - The same as regular but with a different fluff text.
/obj/item/blueprints/cyborg
	name = "station schematics"
	desc = "A digital copy of the station blueprints stored in your memory."
	fluffnotice = "Intellectual Property of Nanotrasen. For use in engineering cyborgs only. Wipe from memory upon departure from the station."

///Golem blueprints - Used to make golem areas that won't give the hazardous area debuffs.
/obj/item/blueprints/golem
	name = "land claim"
	desc = "Use it to build new structures in the wastes."
	fluffnotice = "In memory of the Liberator's brother, Delaminator, and his Scarlet Macaw-iathan, from which this artifact was stolen."
	new_area_type = /area/golem

///Slime blueprints - Makes areas colored and compatible with xenobiology camera consoles, one time use.
/obj/item/blueprints/slime
	name = "cerulean prints"
	desc = "A one use yet of blueprints made of jelly like organic material. Extends the reach of the management console."
	fluffnotice = "Copyright by Science Inc. Renaming areas will allow for management consoles to traverse them."
	color = "#2956B2"

/obj/item/blueprints/slime/edit_area(mob/user)
	. = ..()
	var/area/area = get_area(src)
	var/list/turf_matrix = color_transition_filter("#2956B2")
	for(var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			area_turf.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			area_turf.add_atom_colour(turf_matrix, FIXED_COLOUR_PRIORITY)
	area.area_flags |= XENOBIOLOGY_COMPATIBLE
	qdel(src)

#undef LEGEND_VIEWING_LIST
#undef LEGEND_OFF

#undef AREA_STATION
#undef AREA_OUTDOORS
#undef AREA_SPECIAL


/obj/item/areaeditor/shuttle
	name = "shuttle expansion permit"
	desc = "A set of paperwork which is used to expand flyable shuttles."
	color = COLOR_ASSEMBLY_WHITE
	fluffnotice = "Not to be used for non-sanctioned shuttle construction and maintenance."
	var/obj/docking_port/mobile/target_shuttle

/mob
	///Last time an area was created by a mob plus a short cooldown period
	var/create_area_cooldown

/obj/item/areaeditor/shuttle/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = target
		if(istype(H.current_ship, /obj/structure/overmap/ship))
			var/obj/structure/overmap/ship/S = H.current_ship
			target_shuttle = S.shuttle

/obj/item/areaeditor/shuttle/attack_self(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")

/obj/item/areaeditor/shuttle/Topic(href, href_list)
	if(!usr.can_perform_action(src) || usr != loc)
		usr << browse(null, "window=blueprints")
		return TRUE
	if(href_list["create_area"])
		if(in_use)
			return
		if(!target_shuttle)
			to_chat(usr, "<span class='warning'>You need to designate a shuttle to expand by linking the helm console to these plans.</span>")
			return
		var/area/A = get_area(usr)
		if(A.area_flags & NOTELEPORT)
			to_chat(usr, "<span class='warning'>You cannot edit restricted areas.</span>")
			return
		in_use = TRUE
		create_shuttle_area(usr)
		in_use = FALSE
	updateUsrDialog()

// Virtually a copy of create_area() with specialized behaviour
/obj/item/areaeditor/shuttle/proc/create_shuttle_area(mob/creator)
	// Passed into the above proc as list/break_if_found
	var/static/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/blacklisted_areas = typecacheof(list(
		/area/space,
		))

	if(creator)
		if(creator.create_area_cooldown >= world.time)
			to_chat(creator, "<span class='warning'>You're trying to create a new area a little too fast.</span>")
			return
		creator.create_area_cooldown = world.time + 10

	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BP_MAX_ROOM_SIZE*2)
	if(!turfs)
		to_chat(creator, "<span class='warning'>The new area must be completely airtight.</span>")
		return
	if(turfs.len > BP_MAX_ROOM_SIZE)
		to_chat(creator, "<span class='warning'>The room you're in is too big. It is [turfs.len >= BP_MAX_ROOM_SIZE *2 ? "more than 100" : ((turfs.len / BP_MAX_ROOM_SIZE)-1)*100]% larger than allowed.</span>")
		return
	var/list/apc_map = list()
	var/list/areas = list("New Area" = /area/shuttle/voidcrew)
	var/list/shuttle_coords = target_shuttle.return_coords()
	var/near_shuttle = FALSE
	for(var/i in 1 to turfs.len)
		var/turf/the_turf = turfs[i]
		var/area/place = get_area(the_turf)
		if(blacklisted_areas[place.type])
			continue
		if(!place.requires_power || (place.area_flags & NOTELEPORT) || (place.area_flags & HIDDEN_AREA))
			continue // No expanding powerless rooms etc
		if(!TURF_SHARES(the_turf)) // No expanding areas of walls/something blocking this turf because that defeats the whole point of them used to separate areas
			continue
		if(!isnull(place.apc))
			apc_map[place.name] = place.apc
		if(length(apc_map) > 1) // When merging 2 or more areas make sure we arent merging their apc into 1 area
			to_chat(creator, span_warning("Multiple APC's detected in the vicinity. only 1 is allowed."))
			return
		areas[place.name] = place

		// The following code checks to see if the tile is within one tile of the target shuttle
		if(near_shuttle)
			continue
		var/turf/T = turfs[i]
		if(T.z == target_shuttle.z)
			if(T.x >= (shuttle_coords[1] - 1) && T.x <= (shuttle_coords[3] + 1))
				if(T.y >= (shuttle_coords[2] - 1) && T.y <= (shuttle_coords[4] + 1))
					near_shuttle = TRUE
	if(!near_shuttle)
		to_chat(creator, "<span class='warning'>The new area must be next to the shuttle.</span>")
	var/area_choice = input(creator, "Choose an area to expand or make a new area.", "Area Expansion") as null|anything in areas
	area_choice = areas[area_choice]

	if(!area_choice)
		to_chat(creator, "<span class='warning'>No choice selected. The area remains undefined.</span>")
		return
	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = stripped_input(creator,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN)
		if(!str || !length(str)) //cancel
			return
		if(length(str) > 50)
			to_chat(creator, "<span class='warning'>The given name is too long. The area remains undefined.</span>")
			return
		newA = new area_choice
		newA.setup(str)
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	for(var/i in 1 to turfs.len)
		var/turf/thing = turfs[i]
		var/area/old_area = thing.loc
		newA.contents += thing
		thing.change_area(old_area, newA)

		if(istype(thing, /turf/open/space))
			continue
		if(length(thing.baseturfs) < 2)
			continue
		//Add the shuttle base shit to the shuttle
		if(!thing.baseturfs.Find(/turf/baseturf_skipover/shuttle))
			thing.baseturfs.Insert(3, /turf/baseturf_skipover/shuttle)

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	target_shuttle.shuttle_areas[newA] = TRUE

	newA.connect_to_shuttle(target_shuttle, target_shuttle.get_docked())
	for(var/atom/thing in newA)
		thing.connect_to_shuttle(target_shuttle, target_shuttle.get_docked())

	target_shuttle.recalculate_bounds()

	to_chat(creator, "<span class='notice'>You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered.</span>")
	return TRUE

// VERY EXPENSIVE (I think)
/obj/docking_port/mobile/proc/recalculate_bounds()
	if(!istype(src, /obj/docking_port/mobile))
		return FALSE
	//Heights is the distance away from the port
	//width is the distance perpendicular to the port
	var/minX = INFINITY
	var/maxX = 0
	var/minY = INFINITY
	var/maxY = 0
	for(var/area/A in shuttle_areas)
		for(var/turf/T in A)
			minX = min(T.x, minX)
			maxX = max(T.x, maxX)
			minY = min(T.y, minY)
			maxY = max(T.y, maxY)
	//Make sure shuttle was actually found.
	if(maxX == INFINITY || maxY == INFINITY)
		return FALSE
	minX--
	minY--
	var/new_width = maxX - minX
	var/new_height = maxY - minY
	var/offset_x = x - minX
	var/offset_y = y - minY
	switch(dir) //Source: code/datums/shuttles.dm line 77 (14/03/2020) :)
		if(NORTH)
			width = new_width
			height = new_height
			dwidth = offset_x - 1
			dheight = offset_y - 1
		if(EAST)
			width = new_height
			height = new_width
			dwidth = new_height - offset_y
			dheight = offset_x - 1
		if(SOUTH)
			width = new_width
			height = new_height
			dwidth = new_width - offset_x
			dheight = new_height - offset_y
		if(WEST)
			width = new_height
			height = new_width
			dwidth = offset_y - 1
			dheight = new_width - offset_x
