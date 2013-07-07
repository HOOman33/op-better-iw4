/************************************/
/*         Map by momo5502          */
/************************************/


#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\_createfx;
#using_animtree( "script_model" );
 
main()
{		
        maps\mp\_load::main();
		maps\mp\estate_fx::main();
		maps\createart\estate_art::main();
		maps\createart\estate_fog::main();
		
		level.scr_animtree[ "bouncingbetty" ] 								= #animtree;
		level.scr_anim[ "bouncingbetty" ][ "bouncing_betty_detonate" ]		= %bouncing_betty_detonate;
		level.scr_model[ "bouncingbetty" ] 									= "projectile_bouncing_betty_grenade";
		PreCacheModel( "projectile_bouncing_betty_grenade" );
		PreCacheModel( "accessories_gas_canister_highrez" );
		PreCacheModel( "prop_cigarette_pack" );
		
		common_scripts\_destructible_types_anim_airconditioner::main();
		common_scripts\_destructible_types_anim_generator::main();
		common_scripts\_destructible_types_anim_me_fanceil1_spin::main();
 
        game[ "attackers" ] = "allies";
        game[ "defenders" ] = "axis";
		
		ambientPlay( "ambient_mp_estate" );
		
        maps\mp\_compass::setupMiniMap( "compass_map_estate" );
        setdvar( "compassmaxrange", "4000" );
		
		VisionSetNaked( "estate", 0 );
		
		thread solar_panels();
		thread bouncing_betty_gameplay_init();
}

//********************
// SOLAR PANELS
//********************

solar_panels()
{
	panels = getentarray( "solar_panel", "targetname" );
	panels_colmaps = getentarray( "solar_panel_collision", "targetname" );
	
	array_thread( panels, ::solar_panels_rotate );
	array_thread( panels_colmaps, ::solar_panels_rotate );
}

solar_panels_rotate()
{
	yaw = self.angles[1];
	while(true)
	{
	self RotateYaw( -95, 60, 3, 3 );
	wait 60;
	self RotateYaw( yaw, 60, 3, 3 );
	wait 60;
	}
}


//Bouncing betty killtrigger

bouncing_betty_gameplay_init()
{
	mines = getentarray( "bouncing_betty", "targetname" );
	
	foreach( mine in mines )
	{
		mine thread bouncing_betty_gameplay();
	}
}

bouncing_betty_gameplay()
{	
	mine = spawn( "script_origin", self.origin );
	mine.radius = self.radius;
	mine.origin = self.origin;
	
	while( true )
	{
		self waittill( "trigger" );
		mine bouncing_betty_fx();
	}
}

bouncing_betty_fx()
{

	playFX( getfx( "bouncing_betty_launch" ), self.origin );
	self playsound( "mine_betty_click" );
	wait 0.5;
	self playsound( "mine_betty_spin" );
	
	spinner = spawn( "script_model", self.origin );
	spinner setmodel( "projectile_bouncing_betty_grenade" );
	spinner.animname = "bouncingbetty";
	//spinner useAnimTree( level.scr_animtree[ "bouncingbetty" ] );
	spinner scriptModelPlayAnim( level.scr_animtree[ "bouncingbetty" ] );
		
	spinner moveto( spinner.origin + ( 0, 0, 128), 0.7);
	spinner thread play_spinner_fx();
	//self anim_single_solo( spinner, "bouncing_betty_detonate" );
	spinner scriptModelPlayAnim( "bouncing_betty_detonate" );
	
	wait 0.7;
	
	explosion_org = spinner.origin;
	
	spinner playsound( "grenade_explode_metal" );
	
	playFXontag( getfx( "bouncing_betty_explosion" ), spinner, "tag_fx" );

	spinner notify( "deletion_notification" );
	spinner delete();

	radiusdamage( explosion_org, self.radius, 1000, 20 );
	wait 0.2;
}

play_spinner_fx()
{
	self endon( "death" );
	self endon( "deletion_notification");
	timer = gettime() + 1000;
	while ( gettime() < timer )
	{
		wait .05;
		playFXontag( getfx( "bouncing_betty_swirl" ), self, "tag_fx_spin1" );
		playFXontag( getfx( "bouncing_betty_swirl" ), self, "tag_fx_spin3" );
		wait .05;
		playFXontag( getfx( "bouncing_betty_swirl" ), self, "tag_fx_spin2" );
		playFXontag( getfx( "bouncing_betty_swirl" ), self, "tag_fx_spin4" );
	}
}