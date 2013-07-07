main()
{

	level.tweakfile = true;

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );

	
	setExpFog(     1000,             2000,          0,    0,     0,      1,          0.1,           0,         0,        0,                (-0.75,-0.29,0.58),           0,             1,            0 );
	//setExpFog( start distance, halfway distance, red, green, blue, max opacity, transition time, sun red, sun green, sun blue,      sun max opacity,       sun direction, sun begin fade angle, sun end fade angle )
	VisionSetNaked("so_bridge", 0);
  
}