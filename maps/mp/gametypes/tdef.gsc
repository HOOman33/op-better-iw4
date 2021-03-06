/*************************************************************************************************************************************************************************************************************************************************************
*																												Team Defender - Unreleased																													 *
*																																																															 *
*																													Overall Credits:																														 *
*																											Infinity Ward main coder(s).																													 *
*																											DidUknowiPwn porting it to IW4																													 *
*																																																															 *
*																											© 2013 DidUknowiPwn ™	& Infinity Ward/Activision																								 *
*														Do not edit this mod without contacting me, DidUknowiPwn, my Steam is DidUknowiPwn and my YouTube page is iPwnAtZombies. IF you do, you will be in trouble. 										 *
*************************************************************************************************************************************************************************************************************************************************************/
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

/*
	Team Defender
	Objective: 	Score points for your team by eliminating players on the opposing team.
				Team with flag scores double kill points.
				First corpse spawns the flag.
	Map ends:	When one team reaches the score limit, or time limit is reached
	Respawning:	No wait / Near teammates

	Level requirementss
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

main()
{	
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level.gameType, 5, 0, 1440 );
	registerScoreLimitDvar( level.gameType, 500, 0, 20000 );
	
	level.matchRules_damageMultiplier = 0;
	level.matchRules_vampirism = 0;	

	level.teamBased = true;
	level.initGametypeAwards = ::initGametypeAwards;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.getSpawnPoint = ::getSpawnPoint;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onNormalDeath = ::onNormalDeath;
	
	precacheShader( "waypoint_targetneutral" );	

	game["dialog"]["gametype"] = "team_def";	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	
	game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
}

onPrecacheGameType()
{
	precacheString( &"MP_NEUTRAL_FLAG_CAPTURED_BY" );
	precacheString( &"MP_NEUTRAL_FLAG_DROPPED_BY" );
	precacheString( &"MP_GRABBING_FLAG" );	
}

onStartGameType()
{
	setClientNameMode("auto_change");

	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setObjectiveText( "allies", "Capture the flag for 2x bonus." );
	setObjectiveText( "axis", "Capture the flag for 2x bonus." );
	
	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", "Capture the flag for 2x bonus." );
		setObjectiveScoreText( "axis", "Capture the flag for 2x bonus." );
	}
	else
	{
		setObjectiveScoreText( "allies", "Capture the flag for 2x bonus." );
		setObjectiveScoreText( "axis", "Capture the flag for 2x bonus." );
	}
	setObjectiveHintText( "allies", "Capture the flag for 2x bonus." );
	setObjectiveHintText( "axis", "Capture the flag for 2x bonus." );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 200 );
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "kill_bonus", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "kill_carrier", 50 );	
	maps\mp\gametypes\_rank::registerScoreInfo( "team_assist", 20 );		
	
	allowed[0] = level.gameType;
	allowed[1] = "tdm";
	
	maps\mp\gametypes\_gameobjects::main(allowed);

	tdef();	
}

tdef()
{
	level.icon2D["allies"] = maps\mp\gametypes\_teams::getTeamFlagIcon( "allies" );
	level.icon2D["axis"] = maps\mp\gametypes\_teams::getTeamFlagIcon( "axis" );
	precacheShader( level.icon2D["axis"] );
	precacheShader( level.icon2D["allies"] );
	
	level.carryFlag["allies"] = maps\mp\gametypes\_teams::getTeamFlagCarryModel( "allies" );
	level.carryFlag["axis"] = maps\mp\gametypes\_teams::getTeamFlagCarryModel( "axis" );
	level.carryFlag["neutral"] = "prop_flag_neutral";
	precacheModel( level.carryFlag["allies"] );
	precacheModel( level.carryFlag["axis"] );
	precacheModel( level.carryFlag["neutral"] );
	
	level.iconEscort3D = "waypoint_defend";
	level.iconEscort2D = "waypoint_defend";
	precacheShader( level.iconEscort3D );
	precacheShader( level.iconEscort2D );

	level.iconKill3D = "waypoint_kill";
	level.iconKill2D = "waypoint_kill";
	precacheShader( level.iconKill3D );
	precacheShader( level.iconKill2D );
	
	level.iconCaptureFlag3D = "waypoint_capture_flag";
	level.iconCaptureFlag2D = "waypoint_capture_flag";
	precacheShader( level.iconCaptureFlag3D );
	precacheShader( level.iconCaptureFlag2D );	
	
	precacheShader( "waypoint_flag_friendly" );
	precacheShader( "waypoint_flag_enemy" );
	
	level.gameFlag = undefined;	
}


onSpawnPlayer()
{
	//	flag carrier class? clear this regardless if they were carrier
	if ( isDefined( level.tdef_loadouts ) && isDefined( level.tdef_loadouts[self.team] ) )
		self.pers["gamemodeLoadout"] = undefined;	
	self.isjugg = 0;
	level notify ( "spawned_player" );			
}


onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );

	//	we got the flag	- give bonus
	if ( isDefined( level.gameFlag ) && level.gameFlag maps\mp\gametypes\_gameobjects::getOwnerTeam() == attacker.pers["team"] )
	{
		//	I'm the carrier
		if ( isDefined( attacker.carryFlag ) )
			attacker incPlayerStat( "killsasflagcarrier", 1 );
		//	someone else is
		else
		{
			//	give flag carrier a bonus for kills achieved by team
			level.gameFlag.carrier thread maps\mp\gametypes\_rank::xpEventPopup( "Assist!" );
			maps\mp\gametypes\_gamescore::givePlayerScore( "team_assist", level.gameFlag.carrier, victim, true );
			level.gameFlag.carrier thread maps\mp\gametypes\_rank::giveRankXP( "team_assist" );
		}
			
		attacker thread maps\mp\gametypes\_rank::xpEventPopup( "2X Bonus" );
		maps\mp\gametypes\_gamescore::givePlayerScore( "kill_bonus", attacker, victim, true );	
		attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill_bonus" );
		
		score *= 2;
	}
	//	no flag yet		- create it
	else if ( !isDefined( level.gameFlag ) && canCreateFlagAtVictimOrigin( victim ))
	{
		level.gameFlag = createFlag( victim );
		
		score += maps\mp\gametypes\_rank::getScoreInfoValue( "firstblood" );		
		maps\mp\gametypes\_gamescore::givePlayerScore( "firstblood", attacker, victim, true );							
	}
	//	killed carrier	- give bonus
	else if ( isDefined( victim.carryFlag ) )
	{
		killCarrierBonus = maps\mp\gametypes\_rank::getScoreInfoValue( "kill_carrier" );
		
		thread teamPlayerCardSplash( "callout_killflagcarrier", attacker );
		attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "flag_carrier_killed", killCarrierBonus );
		maps\mp\gametypes\_gamescore::givePlayerScore( "kill_carrier", attacker, victim, true );
		attacker incPlayerStat( "flagcarrierkills", 1 );
		attacker thread [[level.onXPEvent]]( "kill_carrier" );
		attacker notify( "objective", "kill_carrier" );
		attacker thread maps\mp\_matchdata::logGameEvent( "kill_carrier", attacker.origin );	
		
		score += killCarrierBonus;			
	}

	attacker maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( attacker.pers["team"], score );
	
	if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level.otherTeam[attacker.team]] )
		attacker.finalKill = true;
}

onDrop( player )
{
	// get the time when they dropped it
	if( IsDefined( player.tdef_flagTime ) )
	{
		flagTime = int( GetTime() - player.tdef_flagTime );
		player incPlayerStat( "holdingteamdefenderflag", flagTime );
		player.tdef_flagTime = undefined;
		player notify( "dropped_flag" );
	}

	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	otherTeam = level.otherTeam[team];
	
	self.currentCarrier = undefined;

	self maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
	self maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level.iconCaptureFlag2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level.iconCaptureFlag3D );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level.iconCaptureFlag2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level.iconCaptureFlag3D );

	if ( isDefined( player ) )
	{
 		if ( isDefined( player.carryFlag ) )
			player detachFlag();
		
		printAndSoundOnEveryone( otherTeam, "none", &"MP_ENEMY_FLAG_DROPPED_BY", "", "mp_war_objective_lost", "", player );
	}
	else
	{
		playSoundOnPlayers( "mp_war_objective_lost", team );
		playSoundOnPlayers( "mp_war_objective_lost", otherTeam );
	}

	leaderDialog( "dropped_flag", team, "status" );
	leaderDialog( "enemy_dropped_flag", otherTeam, "status" );
}

onPickup( player )
{
	self notify ( "picked_up" );

	// get the time when they picked it up
	player.tdef_flagTime = GetTime();
	player thread watchForEndGame();

	score = maps\mp\gametypes\_rank::getScoreInfoValue( "capture" );
	assert( isDefined( score ) );	

	team = player.pers["team"];
	otherTeam = level.otherTeam[team];
			
	//	flag carrier class?  (do before attaching flag)
	if ( isDefined( level.tdef_loadouts ) && isDefined( level.tdef_loadouts[team] ) )
	{
		player thread applyFlagCarrierClass(); // attaches flag
		player.isjugg = 1;
	}
	else
	{
		player attachFlag();
		player.isjugg = 0;
	}
		
	self.currentCarrier = player;	
	player.carryIcon setShader( level.icon2D[team], player.carryIcon.width, player.carryIcon.height );	
	
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level.iconEscort2D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level.iconEscort2D );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level.iconKill3D );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level.iconKill3D );
	
	leaderDialog( "got_flag", team, "status" );
	leaderDialog( "enemy_got_flag", otherTeam, "status" );	

	thread teamPlayerCardSplash( "callout_flagcapture", player );
	player thread maps\mp\gametypes\_hud_message::SplashNotify( "flag_capture", score );
	maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player, undefined, true );
	player thread [[level.onXPEvent]]( "capture" );
	player incPlayerStat( "flagscaptured", 1 );
	player notify( "objective", "captured" );
	player thread maps\mp\_matchdata::logGameEvent( "capture", player.origin );

	printAndSoundOnEveryone( team, otherTeam, &"MP_NEUTRAL_FLAG_CAPTURED_BY", &"MP_NEUTRAL_FLAG_CAPTURED_BY", "mp_obj_captured", "mp_enemy_obj_captured", player );
	
	//	give a capture bonus to the capturing team if the flag is changing hands
	if ( self.currentTeam == otherTeam )
		player maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, score );
	self.currentTeam = team;
}

applyFlagCarrierClass()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	if ( self.isjugg == 1 )
	{
		self notify( "lost_juggernaut" );
		wait( 0.05 );
	}	
	
	self.pers["gamemodeLoadout"] = level.tdef_loadouts[self.team];
	self maps\mp\gametypes\_class::giveLoadout( self.team, "gamemode", false, false );	
	
	self attachFlag();	
}

canCreateFlagAtVictimOrigin( victim )
{
	mineTriggers = getEntArray( "minefield", "targetname" );
	hurtTriggers = getEntArray( "trigger_hurt", "classname" );
	radTriggers = getEntArray( "radiation", "targetname" );
		
	for ( index = 0; index < radTriggers.size; index++ )
	{
		if ( victim isTouching( radTriggers[index] ) )
			return false;
	}

	for ( index = 0; index < mineTriggers.size; index++ )
	{
		if ( victim isTouching( mineTriggers[index] ) )
			return false;
	}

	for ( index = 0; index < hurtTriggers.size; index++ )
	{
		if ( victim isTouching( hurtTriggers[index] ) )
			return false;
	}	
	
	return true;
}

watchForEndGame()
{
	self endon( "dropped_flag" );
	self endon( "disconnect" );

	level waittill( "game_ended" );

	if( IsDefined( self ) )
	{
		if( IsDefined( self.tdef_flagTime ) )
		{
			flagTime = int( GetTime() - self.tdef_flagTime );
			self incPlayerStat( "holdingteamdefenderflag", flagTime );
		}
	}
}

createFlag( victim )
{	
	//	flag
	visuals[0] = spawn( "script_model", victim.origin );
	visuals[0] setModel( level.carryFlag["neutral"] );
	
	//	trigger	
	trigger = spawn( "trigger_radius", victim.origin, 0, 96, 72);	
	
	gameFlag = maps\mp\gametypes\_gameobjects::createCarryObject( "neutral", trigger, visuals, (0,0,85) );
	gameFlag maps\mp\gametypes\_gameobjects::setTeamUseTime( "friendly", 0.5 );
	gameFlag maps\mp\gametypes\_gameobjects::setTeamUseTime( "enemy", 0.5 );
	gameFlag maps\mp\gametypes\_gameobjects::setTeamUseText( "enemy", &"MP_GRABBING_FLAG" );
	gameFlag maps\mp\gametypes\_gameobjects::setTeamUseText( "friendly", &"MP_GRABBING_FLAG" );
	gameFlag maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	
	gameFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	gameFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level.iconCaptureFlag2D );
	gameFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level.iconCaptureFlag3D );
	gameFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level.iconCaptureFlag2D );
	gameFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level.iconCaptureFlag3D );

	gameFlag maps\mp\gametypes\_gameobjects::setCarryIcon( level.icon2D["axis"] ); //temp, manually changed after picked up
	
	//	these do nothing but the slow update on minimap icon and world icon
	//	leave as false (set on createCarryObject()), we want fast update for friendly and enemy
	//gameFlag.objIDPingFriendly = true;
	//gameFlag.objIDPingEnemy = true;
	
	gameFlag.allowWeapons = true;
	gameFlag.onPickup = ::onPickup;
	gameFlag.onPickupFailed = ::onPickup;
	gameFlag.onDrop = ::onDrop;
	
	gameFlag.oldRadius = 96;	
	gameFlag.currentTeam = "none";
	gameFlag.requiresLOS = true;
	
	//	set it as flag trigger when on ground
	level.favorCloseSpawnEnt = gameFlag.trigger;
	level.favorCloseSpawnScalar = 3;	
	
	return gameFlag;
}


attachFlag()
{
	self attach( level.carryFlag[self.pers["team"]], "J_spine4", true );
	self.carryFlag = level.carryFlag[self.pers["team"]];
	
	//	set it as flag carrier when carried
	level.favorCloseSpawnEnt = self;	
}


detachFlag()
{
	self detach( self.carryFlag, "J_spine4" );
	self.carryFlag = undefined;		
	
	//	set it as flag trigger when on ground
	level.favorCloseSpawnEnt = level.gameFlag.trigger;	
}

getSpawnPoint()
{
	spawnteam = self.pers["team"];
	if ( game["switchedsides"] )
		spawnteam = getOtherTeam( spawnteam );

	if ( level.inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + spawnteam + "_start" );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	return spawnPoint;
}

initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "flagscaptured",		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "flagcarrierkills", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "killsasflagcarrier", 	0, maps\mp\_awards::highestWins );
}