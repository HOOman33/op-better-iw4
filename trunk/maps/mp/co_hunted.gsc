/******************************************************/
/*         Map by momo5502, xetal & Dasfonia          */
/******************************************************/


#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
 
main()
{

    maps\mp\_load::main();
	maps\createart\co_hunted_art::main();
	maps\mp\co_hunted_fx::main();
	maps\mp\hunted_precache::main();
	
    game[ "attackers" ] = "allies";
    game[ "defenders" ] = "axis";
	
    maps\mp\_compass::setupMiniMap( "compass_map_hunted" );		
    setdvar( "compassmaxrange", "3000" );
	
	ambientPlay( "ambient_mp_rural", 0 );
}