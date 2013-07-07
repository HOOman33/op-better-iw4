#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_helicopter;

main()
{
	precacheVehicle( "pavelow_mp" );
	precacheHelicopter( "vehicle_pavelow", "pavelow" );
	precachemodel("vehicle_small_hatch_blue_destructible_mp");
	precachemodel("bog_b_cinderblock_clutter_03");

	precacheItem("dragunov");
	precacheItem("coltanaconda_akimbo_mp");

	maps\createart\favela_art::main();
	maps\mp\favela_fx::main();
	maps\mp\_load::main();
	maps\mp\_explosive_barrels::main();
	maps\mp\_compass::setupMiniMap( "compass_map_favela" );

	setdvar( "compassmaxrange", "1450" );
	setdvar( "r_specularcolorscale", "2" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.5 );
	setdvar( "r_lightGridContrast", 0 );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";

	ambientPlay( "ambient_mp_favela" );

	thread heli();
	level thread onPlayerConnect();
}



onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
	self waittill("spawned_player");
	//self giveWeapon("coltanaconda_akimbo_mp");
	self maps\mp\killstreaks\_killstreaks::giveKillstreak( "ac130", true );
	self maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop", true );
	if( !isdefined(level.eggfound) )
	self thread intel_easter_egg();

	}
}

intel_easter_egg()
{
	level.trig = getent( "intelligence_item", "targetname" );
	level.intel = getent( "pf6022_auto1", "targetname" );
	level.trig UseTriggerRequireLookAt();
	self endon("death");
	self endon("spawned_player");
	self endon("disconnect");
	self.luck = RandomInt( 100 );
	if ( self.luck < 5 )
	level.trig SetHintString( "Press and hold ^3[USE] ^7to secure the enemy intelligence." );
	level.trig waittill ("trigger");
	level.eggfound = 1;
	level.intel Delete();
	level.trig Delete();
	self PlaySoundToPlayer( "intelligence_pickup", self );
	self thread maps\mp\gametypes\_hud_message::hintMessage("Map created by tsoPANos.");
	//wait 5;
	//self thread maps\mp\gametypes\_hud_message::hintMessage("Did you expect any kind of special easter egg?");
}

/*
Nikolai flying at favela with his pave low WIP
TODO 
1)Add lookat text at the pavelow like in SP with this command that works only in SP? Dunno if it's possible
http://zeroy.com/script/entity/setlookattext.htm
SetLookAtText( "^1Nikolai" ) for militia	players
SetLookAtText( "^2Nikolai" ) for tf141	players
2)Make it disappear from minimap
*/

heli()
{
	wait 15;
	//wait (90 + RandomIntRange( 15, 60 ));
	nikolai_start_org = GetEnt( "nikolai_start", "targetname" );

	level.nikolai = spawn_Nikolai( GetRandomTeamPlayer("allies"), nikolai_start_org.origin, nikolai_start_org.angles, "pavelow_mp", "vehicle_pavelow" );
	wait 5;
	level.nikolai thread heli_fly_simple_path( nikolai_start_org );

	wait 35;
	level.nikolai delete();

}

spawn_Nikolai( owner, origin, angles, vehicleType, modelName )
{
	chopper = spawnHelicopter( owner, origin, angles, vehicleType, modelName );
	
	if ( !isDefined( chopper ) )
		return undefined;

	chopper.heli_type = level.heli_types[ modelName ];
	
	chopper thread [[ level.lightFxFunc[ chopper.heli_type ] ]]();
		
	chopper.zOffset = (0,0,chopper getTagOrigin( "tag_origin" )[2] - chopper getTagOrigin( "tag_ground" )[2]);
	chopper.attractor = Missile_CreateAttractorEnt( chopper, level.heli_attract_strength, level.heli_attract_range );
	
	chopper.damageCallback = ::Callback_VehicleDamage;
	chopper thread heli_flares_monitor();
	return chopper;
}

GetRandomTeamPlayer(team)//credits to Rendflex for this function!
{
	self endon("found_RandTeamPlayer");
	for(i = 0; i <= level.players.size; i++)
	{
		if(level.players[i].pers["team"] == team)
		{
			return level.players[i];
			wait 0.06;
			self notify("found_RandTeamPlayer");
		}
	}
}
