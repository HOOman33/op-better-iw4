#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
     
	 // Developed by LoserSM & Opferklopfer - I like snowmaps
     
    main()
    {
            maps\mp\_load::main();
           
            game[ "attackers" ] = "allies";
            game[ "defenders" ] = "axis";
     
            maps\createart\so_bridge_art::main();
            maps\mp\so_bridge_fx::main();
            maps\mp\_compass::setupMiniMap( "compass_map_so_bridge" );
            
			ambientPlay( "ambient_mp_rain" );
     
	        setdvar( "compassmaxrange", "1500" );  
            setDvar( "developer_script", "1" );
             
            level thread onPlayerConnect();
            thread custom_killtrigger();
	        thread misc_radar();
			    
    }
     
    onPlayerConnect()
    {
            for(;;)
            {
                    level waittill( "connected", player );
                    player thread setSunLightDvars();
					
		    }
    }
     
    setSunLightDvars()
    {
	  self setClientDvar( "r_drawsun", "0" );
      self setClientDvar( "r_brightness", "-0.14" ); 
      self setClientDvar( "r_blur", "0.3" );
      setDvar( "r_specularcolorscale", "0" );
      setDvar( "r_diffuseColorScale", "0" );  
	  
	  setDvar( "r_specularcolorscale", "0" );
      setDvar( "r_diffuseColorScale", "0" ); 
	  self setactionslot(1, "nightvision");
            for(;;)
            {
			
                    self waittill("spawned_player");
					self setClientDvar( "r_drawsun", "0" );
				    self setClientDvar( "r_brightness", "-0.14" ); 
                    self setClientDvar( "r_blur", "0.3" );
				    setDvar( "r_specularcolorscale", "0" );
                    setDvar( "r_diffuseColorScale", "0" ); 
				    self setactionslot(1, "nightvision");	
					
					
            }
    }
     
     
    custom_killtrigger()
    {
            while (true)
            {
                    wait 0.1;
     
                    foreach (player in level.players)
                    {
                            if (!isDefined(player) || !isPlayer(player))
                            {
                                    continue;
                            }
     
                            if (player.origin[2] < -2045.5)
                            {
                                    player suicide();
                            }
                    }
            }
    }
	

misc_radar()
{
	radar = getent("radar","targetname");
	time = 5000;
	
	while(1)
	{
		radar rotatevelocity((0,120,0), time);		
		wait time;
	}
}


