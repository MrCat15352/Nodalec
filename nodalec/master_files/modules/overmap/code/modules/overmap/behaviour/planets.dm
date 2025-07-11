//НУ ДАВАЙ ПОМЯУКАЙ ОБ ДАТУМ/ОВЕРМАП



/datum/overmap/planet

/datum/overmap/planet/lava
	name = "strange lava planet"
	desc = "A very weak energy signal originating from a planet with lots of seismic and volcanic activity."
	color = COLOR_ORANGE

	ruin_type = ZTRAIT_LAVA_RUINS
	mapgen = /datum/map_generator/planet_generator/lava
	target_area = /area/overmap_encounter/planetoid/lava
	surface = /turf/open/misc/asteroid/basalt/lava_land_surface
	weather_controller_type = /datum/weather/ash_storm
	planet_template = /datum/planet/lava

/datum/overmap/planet/ice
	name = "strange ice planet"
	desc = "A very weak energy signal originating from a planet with traces of water and extremely low temperatures."
	color = COLOR_BLUE_LIGHT

	ruin_type = ZTRAIT_ICE_RUINS
	mapgen = /datum/map_generator/planet_generator/snow
	target_area = /area/overmap_encounter/planetoid/ice
	surface = /turf/open/misc/asteroid/snow/icemoon
	weather_controller_type = /datum/weather/snow_storm
	planet_template = /datum/planet/snow

/datum/overmap/planet/beach
	name = "strange beach planet"
	desc = "A very weak energy signal originating from a planet with many traces of fish."
	color = COLOR_NAVY

	ruin_type = ZTRAIT_BEACH_RUINS
	mapgen = /datum/map_generator/planet_generator/beach
	target_area = /area/overmap_encounter/planetoid/beach
	surface = /turf/open/misc/asteroid/sand/beach/lit
	weather_controller_type = /datum/weather/
	planet_template = /datum/planet/beach

/datum/overmap/planet/jungle
	name = "strange jungle planet"
	desc = "A very weak energy signal originating from a planet teeming with life."
	color = COLOR_LIME

	ruin_type = ZTRAIT_JUNGLE_RUINS
	mapgen = /datum/map_generator/planet_generator
	target_area = /area/overmap_encounter/planetoid/jungle
	surface = /turf/open/misc/dirt/jungle
	weather_controller_type = /datum/weather/
	planet_template = /datum/planet/jungle

/datum/overmap/planet/wasteland
	name = "strange apocalyptic planet"
	desc = "A very weak energy signal originating from a abandoned industrial planet."
	color = COLOR_BEIGE

	ruin_type = ZTRAIT_WASTELAND_RUINS
	mapgen = /datum/map_generator/planet_generator/lava
	target_area = /area/overmap_encounter/planetoid/wasteland
	surface = /turf/open/misc/wasteland/lit
	weather_controller_type = /datum/weather/
	planet_template = /datum/planet/wasteland

/datum/overmap/planet/reebe
	name = "???"
	desc = "Some sort of strange portal. Theres no identification of what this is."
	color = COLOR_YELLOW
	icon_state = "wormhole"

	ruin_type = ZTRAIT_REEBE_RUINS
	spawn_rate = -1 // disabled because reebe sucks for natural gen
	mapgen = /datum/map_generator/cave_generator/reebe
	target_area = /area/overmap_encounter/planetoid/reebe
	surface = /turf/open/chasm/reebe_void

/datum/overmap/planet/asteroid
	name = "large asteroid"
	desc = "A large asteroid with significant traces of minerals."
	color = COLOR_GRAY
	icon_state = "asteroid"

	//spawn_rate = 30
	spawn_rate = -1
	mapgen = /datum/map_generator/cave_generator/asteroid

/datum/overmap/planet/space // not a planet but freak off!!
	name = "weak energy signal"
	desc = "A very weak energy signal emenating from space."
	color = null
	icon_state = "strange_event"

	ruin_type = ZTRAIT_SPACE_RUINS

/datum/overmap/planet/empty // not a planet but freak off!!
	name = "Empty Space"
	desc = "A ship appears to be docked here."
	color = null
	icon_state = "object"
	spawn_rate = -1


