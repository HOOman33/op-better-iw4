#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	setDvar("testClients_doMove", 0 );
	setDvar("testClients_doAttack", 0 );
	setDvar("testClients_doCrouch", 0 );
	self setClientDvar("r_filmUseTweaks", 1);
	self setClientDvar("r_filmtweakenable", 1);
	self setClientDvar("r_glowTweakEnable", 1);
	self setClientDvar("r_glowUseTweaks", 1);
	setDvarIfUninitialized("svr_bots", 0 );
	setDvar("player_meleeRange", 64 );
	setDvar("player_extendedMeleeRange", 64 );
	setDvarIfUninitialized("give_weapon", 1 );
	setDvarIfUninitialized("g_barebones", 0); //enable or disable barebone mode
	level thread onPlayerConnect();
	level thread initGiveWeapon();
	level thread LoadLevelFX();
	level thread PrecacheLevel();
}

PrecacheLevel()
{
	precacheShader("line_horizontal");
}

LoadLevelFX()
{
	level._effect["dlc_1"] = loadFx("smoke/battlefield_smokebank_s_warm_thick");
	level._effect["dlc_2_fire"] = loadFx("fire/firelp_large_pm");
	level._effect["fire"] = loadFx("fire/firelp_large_pm");
	level._effect["fire1"] = loadfx("fire/tank_fire_engine");
	level._effect["toxic"] = loadfx ("fire/jet_afterburner");
	level._effect["evil"] = loadfx("fire/jet_afterburner_harrier_damaged");
	level._effect["fire_map"] = LoadFx("fire/tank_fire_engine");
	level._effect["inferno"]["boom"] = loadfx( "props/barrelexp" );
	level._effect["tnt_boom"] = loadfx("explosions/tanker_explosion");	 
	level._effect[ "FOW" ] = loadfx( "dust/nuke_aftermath_mp" );
	level._effect[ "emp_grenade" ] = loadfx( "explosions/emp_flash_mp" );
	level._effect["small_fire"] = loadfx("fire/firelp_small_pm");
	level._effect["explosion_default"] = loadfx( "props/barrelexp" );
	level.teleFX["red"] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "axis" ) );
	level.teleFX["grey"] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "allies" ) );
	level._effect["large_fire_propane"] = loadFX("fire/propane_capfire");
	level.fx_napalm =   loadfx ("explosions/stealth_bomb_mp");
	level._effect["red_smoke"] = loadFX("smoke/signal_smoke_airdrop");
	level._effect[ "firelp_small_pm" ] = loadfx( "fire/firelp_small_pm" );
	level._effect["med_aura"] = loadFx("misc/ui_flagbase_silver");
	
	level._effect["blood0"] = loadfx( "impacts/flesh_hit_head_fatal_exit" );	// sprays on wall
	level._effect["blood1"] = loadfx( "impacts/flesh_hit_splat_large" );		// chunks
	level._effect["blood2"] = loadfx( "impacts/flesh_hit_body_fatal_exit" );	// big spray
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player);
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
	}
}

onJoinedTeam()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill( "joined_team" );
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		if(getDvarInt("svr_bots") >= 1)
			level thread initTestClients(9);
		self maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke", true );
		self thread MoniterStance();
		self unsetPerk("specialty_pistoldeath");
		self unsetPerk("specialty_extendedmelee");
		self unsetPerk("specialty_copycat");
		self unsetPerk("specialty_combathigh");
		self unsetPerk("specialty_grenadepulldeath");
		self unsetPerk("specialty_finalstand");
	}
}

MoniterStance()
{
	self endon("disconnect");
	self endon("death");
	while(1)
	{
		if(self getStance() == "stand")
		{
			self player_recoilScaleOn(100);
		}
		else if(self getStance() == "crouch")
		{
			self player_recoilScaleOn(90);
		}
		else if(self getStance() == "prone")
		{
			self player_recoilScaleOn(85);
		}
		wait 0.05;
	}
}

initGiveWeapon()
{
	level endon("disconnect");
	while(1)
	{
		if(getDvarInt("give_weapon") != 1)
		{
			if(getDvar("give_weapon") == "ammo")
			{
				foreach(player in level.players)
				{
					player giveMaxAmmo(player getCurrentWeapon());
				}
			}
			else
			{
				foreach(player in level.players)
				{
					player takeWeapon(player getCurrentWeapon());
					player giveWeapon(getDvar("give_weapon"),0, true);
					player giveMaxAmmo(getDvar("give_weapon"));
					wait 0.01;
					player switchToWeapon(getDvar("give_weapon"));
				}
			}
			setDvar("give_weapon", 1);
		}
		wait 0.1;
	}
}

initTestClients()
{
	for(i = 0;i < 2;i++)
	{
		ent[i] = addtestclient();
		if (!isdefined(ent[i]))
		{
			wait 1;
			continue;
		}
		ent[i].pers["isBot"] = true;
		ent[i] thread initIndividualBot();
		wait 0.1;
	}
}

initIndividualBot()
{
	self endon( "disconnect" );
	while(!isdefined(self.pers["team"])) 
		wait .05;
	self notify("menuresponse", game["menu_team"], "autoassign");
	wait 0.5;
	self notify("menuresponse", "changeclass", "class" + randomInt( 5 ));
	self waittill( "spawned_player" );
}