// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );
	setExpFog( 581.8, 15447.9, 0.425054, 0.467361, 0.489628, 0.579678, 0 );
	VisionSetNaked( "mp_terminal", 0 );
	wait 2;
	MapFX();

}

MapFX()
{
	playLoopedFX(level._effect["small_fire"], 1, (316,4387,240));
	playLoopedFX(level._effect["red_smoke"], 1, (316,4387,240));
}
