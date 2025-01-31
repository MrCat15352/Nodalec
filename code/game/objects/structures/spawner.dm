/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "hole"
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	faction = list(FACTION_HOSTILE)

	var/max_mobs = 5
	var/spawn_time = 30 SECONDS
	var/mob_types = list(/mob/living/basic/carp)
	var/spawn_text = "emerges from"
	var/spawner_type = /datum/component/spawner
	/// Is this spawner taggable with something?
	var/scanner_taggable = FALSE
	/// If this spawner's taggable, what can we tag it with?
	var/static/list/scanner_types = list(/obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner)
	/// If this spawner's taggable, what's the text we use to describe what we can tag it with?
	var/scanner_descriptor = "mining analyzer"
	/// Has this spawner been tagged/analyzed by a mining scanner?
	var/gps_tagged = FALSE
	/// A short identifier for the mob it spawns. Keep around 3 characters or less?
	var/mob_gps_id = "???"
	/// A short identifier for what kind of spawner it is, for use in putting together its GPS tag.
	var/spawner_gps_id = "Creature Nest"
	/// A complete identifier. Generated on tag (if tagged), used for its examine.
	var/assigned_tag

/obj/structure/spawner/examine(mob/user)
	. = ..()
	if(!scanner_taggable)
		return
	if(gps_tagged)
		. += span_notice("A holotag's been attached, projecting \"<b>[assigned_tag]</b>\".")
	else
		. += span_notice("It looks like you could probably scan and tag it with a <b>[scanner_descriptor]</b>.")

/obj/structure/spawner/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(.)
		return TRUE
	if(scanner_taggable && is_type_in_list(item, scanner_types))
		gps_tag(user)
		return TRUE

/// Tag the spawner, prefixing its GPS entry with an identifier - or giving it one, if nonexistent.
/obj/structure/spawner/proc/gps_tag(mob/user)
	if(gps_tagged)
		to_chat(user, span_warning("[src] already has a holotag attached!"))
		return
	to_chat(user, span_notice("You affix a holotag to [src]."))
	playsound(src, 'sound/machines/beep/twobeep.ogg', 100)
	gps_tagged = TRUE
	assigned_tag = "\[[mob_gps_id]-[rand(100,999)]\] " + spawner_gps_id
	var/datum/component/gps/our_gps = GetComponent(/datum/component/gps)
	if(our_gps)
		our_gps.gpstag = assigned_tag
		return
	AddComponent(/datum/component/gps, assigned_tag)

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(\
		spawner_type, \
		spawn_types = mob_types, \
		spawn_time = spawn_time, \
		max_spawned = max_mobs, \
		faction = faction, \
		spawn_text = spawn_text,\
		spawn_callback = CALLBACK(src, PROC_REF(on_mob_spawn)), \
		initial_spawn_delay = !mapload, \
	)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(faction_check(faction, user.faction, FALSE) && !user.client)
		return
	return ..()

/obj/structure/spawner/proc/on_mob_spawn(atom/created_atom)
	return

/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/machines/beacon.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/basic/trooper/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)
	mob_gps_id = "SYN" // syndicate
	spawner_gps_id = "Hostile Warp Beacon"

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon_state = "hole"
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 15 SECONDS
	mob_types = list(/mob/living/basic/skeleton)
	spawn_text = "climbs out of"
	faction = list(FACTION_SKELETON)
	mob_gps_id = "SKL" // skeletons
	spawner_gps_id = "Bone Pit"

/obj/structure/spawner/clown
	name = "Laughing Larry"
	desc = "A laughing, jovial figure. Something seems stuck in his throat."
	icon_state = "clownbeacon"
	icon = 'icons/obj/machines/beacon.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 15 SECONDS
	mob_types = list(
		/mob/living/basic/clown,
		/mob/living/basic/clown/banana,
		/mob/living/basic/clown/clownhulk,
		/mob/living/basic/clown/clownhulk/chlown,
		/mob/living/basic/clown/clownhulk/honkmunculus,
		/mob/living/basic/clown/fleshclown,
		/mob/living/basic/clown/mutant/glutton,
		/mob/living/basic/clown/honkling,
		/mob/living/basic/clown/longface,
		/mob/living/basic/clown/lube,
	)
	spawn_text = "climbs out of"
	faction = list(FACTION_CLOWN)
	mob_gps_id = "???" // clowns
	spawner_gps_id = "Clown Planet Distortion"

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(
		/mob/living/basic/mining/basilisk,
		/mob/living/basic/mining/goldgrub,
		/mob/living/basic/mining/goliath/ancient,
		/mob/living/basic/mining/hivelord,
		/mob/living/basic/wumborian_fugu,
	)
	faction = list(FACTION_MINING)

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/basic/mining/goldgrub)
	mob_gps_id = "GG"

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/basic/mining/goliath/ancient)
	mob_gps_id = "GL|A"

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/basic/mining/hivelord)
	mob_gps_id = "HL"

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/basic/mining/basilisk)
	mob_gps_id = "BK"

/obj/structure/spawner/mining/wumborian
	name = "wumborian fugu den"
	desc = "A den housing a nest of wumborian fugus, how do they all even fit in there?"
	mob_types = list(/mob/living/basic/wumborian_fugu)
	mob_gps_id = "WF"

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 60 SECONDS
	max_mobs = 15
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(
		/mob/living/basic/blankbody,
		/mob/living/basic/creature,
		/mob/living/basic/migo,
	)
	faction = list(FACTION_NETHER)
	scanner_taggable = TRUE
	mob_gps_id = "?!?"
	spawner_gps_id = "Netheric Distortion"

/obj/structure/spawner/nether/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		. += "A direct link to another dimension full of creatures very happy to see you. [span_nicegreen("You can see your house from here!")]"
	else
		. += "A direct link to another dimension full of creatures not very happy to see you. [span_warning("Entering the link would be a very bad idea.")]"

/obj/structure/spawner/nether/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, span_notice("You don't feel like going home yet..."))
	else
		user.visible_message(span_warning("[user] is violently pulled into the link!"), \
							span_userdanger("Touching the portal, you are quickly pulled through into a world of unimaginable horror!"))
		contents.Add(user)

/obj/structure/spawner/nether/process(seconds_per_tick)
	for(var/mob/living/living_mob in contents)
		if(living_mob)
			playsound(src, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
			living_mob.adjustBruteLoss(60 * seconds_per_tick)
			new /obj/effect/gibspawner/generic(get_turf(living_mob), living_mob)
			if(living_mob.stat == DEAD)
				var/mob/living/basic/blankbody/newmob = new(loc)
				newmob.name = "[living_mob]"
				newmob.desc = "It's [living_mob], but [living_mob.p_their()] flesh has an ashy texture, and [living_mob.p_their()] face is featureless save an eerie smile."
				src.visible_message(span_warning("[living_mob] reemerges from the link!"))
				qdel(living_mob)

/obj/structure/spawner/sentient
	var/role_name = "A sentient mob"
	var/assumed_control_message = "You are a sentient mob from a badly coded spawner"

/obj/structure/spawner/sentient/Initialize(mapload)
	. = ..()
	notify_ghosts(
		"A [name] has been created in \the [get_area(src)]!",
		source = src,
		header = "Sentient Spawner Created",
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)

/obj/structure/spawner/sentient/on_mob_spawn(atom/created_atom)
	created_atom.AddComponent(\
		/datum/component/ghost_direct_control,\
		role_name = src.role_name,\
		assumed_control_message = src.assumed_control_message,\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)

/obj/structure/spawner/sentient/proc/became_player_controlled(mob/proteon)
	return

/obj/structure/spawner/sentient/proteon_spawner
	name = "eldritch gateway"
	desc = "A dizzying structure that somehow links into Nar'Sie's own domain. The screams of the damned echo continously."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "hole"
	light_power = 2
	light_color = COLOR_CULT_RED
	max_integrity = 50
	density = FALSE
	max_mobs = 2
	spawn_time = 15 SECONDS
	mob_types = list(/mob/living/basic/construct/proteon/hostile)
	spawn_text = "arises from"
	faction = list(FACTION_CULT)
	role_name = "A proteon cult construct"
	assumed_control_message = null

/obj/structure/spawner/sentient/proteon_spawner/examine_status(mob/user)
	if(IS_CULTIST(user) || !isliving(user))
		return span_cult("It's at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/spawner/sentient/proteon_spawner/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) && isliving(user))
		var/mob/living/living_user = user
		living_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15)
		. += span_danger("The voices of the damned echo relentlessly in your mind, continously rebounding on the walls of your self the more you focus on [src]. Your head pounds, better keep away...")
	else
		. += span_cult("The gateway will create one weak proteon construct every [spawn_time * 0.1] seconds, up to a total of [max_mobs], that may be controlled by the spirits of the dead.")

/obj/structure/spawner/sentient/proteon_spawner/became_player_controlled(mob/living/basic/construct/proteon/proteon)
	proteon.mind.add_antag_datum(/datum/antagonist/cult)
	proteon.add_filter("awoken_proteon", 3, list("type" = "outline", "color" = COLOR_CULT_RED, "size" = 2))
	visible_message(span_cult_bold("[proteon] awakens, glowing an eerie red as it stirs from its stupor!"))
	playsound(proteon, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
	proteon.balloon_alert_to_viewers("awoken!")
	addtimer(CALLBACK(src, PROC_REF(remove_wake_outline), proteon), 8 SECONDS)

/obj/structure/spawner/sentient/proteon_spawner/proc/remove_wake_outline(mob/proteon)
	proteon.remove_filter("awoken_proteon")
	proteon.add_filter("sentient_proteon", 3, list("type" = "outline", "color" = COLOR_CULT_RED, "size" = 2, "alpha" = 40))

/obj/structure/spawner/sentient/proteon_spawner/handle_deconstruct(disassembled)
	playsound(src, 'sound/effects/hallucinations/veryfar_noise.ogg', 75)
	visible_message(span_cult_bold("[src] completely falls apart, the screams of the damned reaching a feverous pitch before slowly fading away into nothing."))

// MARK: cave
/obj/structure/spawner/cave
	name = "cave"
	desc = "You spot something glimmering from within. Maybe you can reach in and try to grab it?"
	icon = 'voidcrew/icons/obj/animal_spawner.dmi'
	icon_state = "cave_den"
	mob_types = list(/mob/living/simple_animal/hostile/bear/cave)
	max_mobs = 2
	max_integrity = 650
	spawn_time = 300
	faction = list("wasteland")
	var/uses = 6
	var/bite_chance = 15
	var/success_chance = 80
	var/caveloot = list(
		/obj/item/stack/spacecash/c1000 = 10,
		/obj/item/stack/spacecash/c10000 = 1,
		/obj/item/research_notes/loot/big = 10,
		/obj/item/research_notes/loot/genius = 1,
		/obj/item/stack/ore/diamond = 10,
		/obj/item/stack/telecrystal/five = 1,
		/obj/item/gun/ballistic/bow = 10,
		///obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn = 10,
		///obj/item/gun/ballistic/automatic/zip_pistol = 10,
		///obj/item/gun/ballistic/rifle/boltaction/polymer = 9,
		///obj/item/gun/ballistic/shotgun/winchester = 5,
		/obj/item/gun/ballistic/revolver/nagant = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 2,
		///obj/item/gun/ballistic/automatic/aks74u = 1,
		///obj/item/gun/ballistic/shotgun/doublebarrel/hook = 1,
		/obj/item/pickaxe/diamond = 10,
		/obj/item/kinetic_crusher = 6,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 5,
		/obj/item/binoculars = 10,
		/obj/item/grenade/frag/mega = 6,
		///obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 10,
		///obj/item/reagent_containers/food/snacks/breadslice/moldy = 10,
		/obj/item/instrument/guitar = 10,
		///obj/item/storage/fancy/cigarettes/derringer/gold = 3,
		/obj/item/spear/explosive = 10,
		///obj/item/ammo_casing/caseless/arrow/wood = 10,
		///obj/item/ammo_casing/caseless/arrow/bone = 6,
		/obj/item/survivalcapsule = 7,
		/obj/item/survivalcapsule/luxuryelite = 2,
		/obj/item/storage/box/stockparts/basic = 10,
		/obj/item/storage/box/stockparts/deluxe = 3,
		/obj/item/stock_parts/cell/high = 5,
		///obj/item/strange_crystal = 10,
		/obj/item/clothing/mask/cigarette/rollie/mindbreaker = 10,
		/obj/item/wrench/abductor = 2,
		/obj/item/clothing/glasses/meson = 10,
		/obj/item/clothing/suit/utility/radiation = 10,
		/obj/item/clothing/head/utility/radiation = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5,
		/obj/item/reagent_containers/hypospray/medipen/stimpack = 1,
		/obj/item/stack/medical/bruise_pack = 10,
		/obj/item/stack/medical/ointment = 10,
		/obj/item/storage/medkit/regular = 3,
		/obj/item/storage/bottles/sandblast = 5,
		/obj/item/reagent_containers/cup/bottle/romerol = 1,
		//obj/item/implanter/adrenalin = 3,
		/obj/item/implanter/stealth = 1,
		/obj/item/melee/greykingsword = 2
	)

/obj/structure/spawner/cave/Initialize()
	. = ..()
	uses = rand(1,uses)

/obj/structure/spawner/cave/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	if(uses == 0)
		to_chat(user, "<span class='warning'>There's nothing left to loot!</span>")
		return
	obj_flags |= IN_USE
	to_chat(user, "<span class='warning'>You start searching the [name] for anything useful...</span>")
	if(do_after(user, 40, target = src))
		if(prob(bite_chance))
			user.adjustBruteLoss(15)
			playsound(user.loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
			to_chat(user, "<span class='alert'>OW! Something bit you!</span>")
		else
			if(prob(85))
				to_chat(user, "<span class='alert'>You found something!</span>")
				var/picked_loot = pickweight(caveloot)
				new picked_loot(loc)
				uses -= 1
				if (uses == 0)
					to_chat(user, "<span class='warning'>You've emptied out the [name]!</span>")
					qdel(spawner_type)
			else
				to_chat(user, "<span class='warning'>You didn't find anything, maybe try looking again?")
	else
		to_chat(user, "<span class='warning'><b>Your search was interrupted!</b></span>")
	obj_flags &= ~IN_USE

/obj/structure/spawner/cave/beach
	name = "oak barrel"
	desc = "A musty barrel. Reach in and unlock its mold-covered mysteries!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	mob_types = list(/mob/living/simple_animal/hostile/pirate/melee/beach, /mob/living/simple_animal/hostile/pirate/ranged/beach)
	max_mobs = 2
	max_integrity = 250
	bite_chance = 0
	faction = list("beach")
	caveloot = list(
		/obj/item/storage/bag/money/vault = 10,
		/obj/item/research_notes/loot/big = 8,
		/obj/item/research_notes/loot/genius = 4,
		/obj/item/grenade/clusterbuster/slime = 1,
		/obj/item/grenade/chem_grenade/teargas/moustache = 4,
		/obj/item/slimecross/burning/metal = 10,
		/obj/item/slimecross/burning/gold = 10,
		/obj/item/slimecross/burning/oil = 10,
		/obj/item/slimecross/burning/rainbow = 10,
		/obj/item/slimecross/regenerative/adamantine = 10,
		/obj/item/slimecross/regenerative/rainbow = 10,
		/obj/item/slimecross/stabilized/yellow = 10,
		/obj/item/slimecross/stabilized/purple = 10,
		/obj/item/slimecross/charged/darkblue = 10,
		/obj/item/slimecross/charged/pyrite = 10,
		/obj/item/slimecross/charged/red = 10,
		/obj/item/slimecross/chilling/yellow = 10,
		/obj/item/slimecross/chilling/gold = 10,
		/obj/item/slimecross/chilling/adamantine = 10,
		/obj/item/instrument/banjo = 10,
		/obj/item/gun/ballistic/automatic/mini_uzi = 10,
		/obj/item/gun/ballistic/automatic/pistol/deagle/gold = 10,
		/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 10,
		/obj/item/melee/energy/sword/pirate = 5,
		///obj/item/melee/transforming/energy/ctf/solgov = 2,

	)
