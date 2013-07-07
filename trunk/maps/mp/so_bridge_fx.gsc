main()
{
	level._effect[ "rain_mp_storm" ]						= loadfx( "weather/rain_mp_storm" );
	level._effect[ "rain_noise_splashes" ]					= loadfx( "weather/rain_noise_splashes" );  // floating and drops
	level._effect[ "rain_splash_lite_64x64" ]				= loadfx( "weather/rain_splash_lite_64x64" ); 
	level._effect[ "rain_splash_lite_128x128" ]				= loadfx( "weather/rain_splash_lite_128x128" );// drops only
	level._effect[ "river_splash_small" ]					= loadfx( "water/river_splash_small" );
	level._effect[ "drips_fast" ]							= loadfx( "misc/drips_fast" );
	level._effect[ "lightning" ]							= loadfx( "weather/lightning_mp_storm" );
	level._effect[ "smoke_plume_white_01" ] 				= loadfx( "smoke/smoke_plume_white_01" );
	level._effect[ "smoke_plume_white_02" ] 				= loadfx( "smoke/smoke_plume_white_02" );
	level._effect[ "waterfall_drainage_mp" ] 				= loadfx( "water/waterfall_drainage_mp" ); //  waterfall obv..
	level._effect[ "waterfall_drainage_mp_small" ] 			= loadfx( "water/waterfall_drainage_mp_small" );
	level._effect[ "waterfall_drainage_splash_mp" ] 		= loadfx( "water/waterfall_drainage_splash_mp" ); // splash on the ground
	level._effect[ "objective_smoke" ]	                    = loadfx( "smoke/signal_smoke_green" );
	level._effect["fire_med_nosmoke"]			            = loadfx ("fire/tank_fire_engine");
	level._effect["spotlight_beam"]			                = loadfx ("misc/spotlight_beam"); 	

	maps\createfx\so_bridge_fx::main();
}