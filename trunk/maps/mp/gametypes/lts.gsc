#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Last Team Standing - By Keouf
	Objective: 	Score points for your team by eliminating players on the opposing team
	Round ends:	When one team is eliminated or roundlength time is reached
	Map ends:	When one team reaches the score limit, or time limit or round limit is reached
	Respawning:	Players remain dead for the round and will respawn at the beginning of the next round

	Level requirements
	------------------
		Allied Spawnpoints:
			classname		mp_sd_spawn_attacker
			Allied players spawn from these. Place at least 16 of these relatively close together.

		Axis Spawnpoints:
			classname		mp_sd_spawn_defender
			Axis players spawn from these. Place at least 16 of these relatively close together.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

/*QUAKED mp_sd_spawn_attacker (0.0 1.0 0.0) (-16 -16 0) (16 16 72)
Attacking players spawn randomly at one of these positions at the beginning of a round.*/

/*QUAKED mp_sd_spawn_defender (1.0 0.0 0.0) (-16 -16 0) (16 16 72)
Defending players spawn randomly at one of these positions at the beginning of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	
	registerRoundSwitchDvar( level.gameType, 3, 0, 9 );
	registerTimeLimitDvar( level.gameType, 2.5, 0, 1440 );
	registerScoreLimitDvar( level.gameType, 1, 0, 500 );
	registerRoundLimitDvar( level.gameType, 0, 0, 12 );
	registerWinLimitDvar( level.gameType, 4, 0, 12 );
	registerNumLivesDvar( level.gameType, 1, 0, 10 );
	registerHalfTimeDvar( level.gameType, 0, 0, 1 );
	
	level.objectiveBased = true;
	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	level.getSpawnPoint = ::getSpawnPoint;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onDeadEvent = ::onDeadEvent;
	level.onOneLeftEvent = ::onOneLeftEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onNormalDeath = ::onNormalDeath;
	
	game["dialog"]["gametype"] = "lts";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level.gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
}


onStartGameType()
{
	foreach ( player in level.players ) 
	{
			player RadarJamOff();
	}

	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;
	
	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}
	
	setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	
	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
	
	setClientNameMode( "manual_change" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_attacker" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_defender" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "war";
	
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_rank::registerScoreInfo( "win", 2 );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", 1.5 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );

}


getSpawnPoint()
{
	if(self.pers["team"] == game["attackers"])
		spawnPointName = "mp_sd_spawn_attacker";
	else
		spawnPointName = "mp_sd_spawn_defender";

	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( spawnPointName );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	return spawnpoint;
}


onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId)
{
	thread checkAllowSpectating();
}


checkAllowSpectating()
{
	wait ( 0.05 );
	
	update = false;
	if ( !level.aliveCount[ game["attackers"] ] )
	{
		level.spectateOverride[game["attackers"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( !level.aliveCount[ game["defenders"] ] )
	{
		level.spectateOverride[game["defenders"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( update )
		maps\mp\gametypes\_spectating::updateSpectateSettings();
}


lts_endGame( winningTeam, endReasonText )
{
	thread maps\mp\gametypes\_gamelogic::endGame( winningTeam, endReasonText );
}


onDeadEvent( team )
{
	if ( team == game["attackers"] )
	{
		level thread lts_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )
	{
		level thread lts_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}


onOneLeftEvent( team )
{
	lastPlayer = getLastLivingPlayer( team );

	lastPlayer thread giveLastOnTeamWarning();
}


onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );
}


giveLastOnTeamWarning()
{
	self endon("death");
	self endon("disconnect");
	level endon( "game_ended" );
		
	self waitTillRecoveredHealth( 3 );
	
	otherTeam = getOtherTeam( self.pers["team"] );
	level thread teamPlayerCardSplash( "callout_lastteammemberalive", self, self.pers["team"] );
	level thread teamPlayerCardSplash( "callout_lastenemyalive", self, otherTeam );
	level notify ( "last_alive", self );	
	self maps\mp\gametypes\_missions::lastManSD();
}


onTimeLimit()
{
	lts_endGame( "tie", game["strings"]["time_limit_reached"] );
}