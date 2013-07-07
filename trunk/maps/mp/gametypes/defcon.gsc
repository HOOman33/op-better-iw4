#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
   Defcon
   Objective:    Reach to Defcon 1 and launch Nuke
   Map ends:      When one team reaches the score limit, or time limit is reached
   Respawning:   No wait / Near teammates

   Level requirementss
   ------------------
      Spawnpoints:
         classname      mp_tdm_spawn
         All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
         at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

      Spectator Spawnpoints:
         classname      mp_global_intermission
         Spectators spawn from these and intermission is viewed from these positions.
         Atleast one is required, any more and they are randomly chosen between.
*/

DEFCON_INTERVAL = 5;
DEFCON_1 = "DefCon 1";
DEFCON_2 = "DefCon 2";
DEFCON_3 = "DefCon 3";
DEFCON_4 = "DefCon 4";
DEFCON_5 = "DefCon 5";
DEFCON_KS1 = "Juggernaut!";
DEFCON_KS2 = "airdrop";
DEFCON_KS3 = "Marihuana";


main()
{
   if(getdvar("mapname") == "mp_background")
      return;
   
   maps\mp\gametypes\_globallogic::init();
   maps\mp\gametypes\_callbacksetup::SetupCallbacks();
   maps\mp\gametypes\_globallogic::SetupCallbacks();

   registerRoundSwitchDvar( level.gameType, 0, 0, 9 );
   registerTimeLimitDvar( level.gameType, 15, 0, 1440 );
   registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
   registerRoundLimitDvar( level.gameType, 1, 0, 10 );
   registerWinLimitDvar( level.gameType, 1, 0, 10 );
   registerRoundSwitchDvar( level.gameType, 0, 0, 30 );
   registerNumLivesDvar( level.gameType, 0, 0, 10 );
   registerHalfTimeDvar( level.gameType, 0, 0, 1 );

   level.teamBased = true;
   level.onPrecacheGameType = ::onPrecacheGameType;
   level.onStartGameType = ::onStartGameType;
   level.getSpawnPoint = ::getSpawnPoint;
   level.onNormalDeath = ::onNormalDeath;
   
   level.continuedKillCount["axis"]= 0;
   level.continuedKillCount["allies"] = 0;
   level.currentDefcon["axis"] = 5;
   level.currentDefcon["allies"] = 5;
   level.defconStreakUsed[2] = false;
   level.defconStreakUsed[3] = false;
   level.defconStreakUsed[4] = false;
   
   
   //level.onTimeLimit = ::onTimeLimit;   // overtime not fully supported yet

   game["dialog"]["gametype"] = "dfcn_tm_death";
   game["dialog"]["defcon_1"] = "defcon_1";
   game["dialog"]["defcon_2"] = "defcon_2";
   game["dialog"]["defcon_3"] = "defcon_3";
   game["dialog"]["defcon_4"] = "defcon_4";
   game["dialog"]["defcon_5"] = "defcon_5";
   
   game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
}
onPrecacheGameType()
{
   precacheShader("cardicon_prestige10_02");
   precacheShader("dpad_killstreak_nuke");
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
         
   level.spawnMins = ( 0, 0, 0 );
   level.spawnMaxs = ( 0, 0, 0 );   
   maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
   maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
   maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
   maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
   
   level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
   setMapCenter( level.mapCenter );
   
   allowed[0] = level.gameType;
   allowed[1] = "airdrop_pallet";
   
   maps\mp\gametypes\_gameobjects::main(allowed);
   
   if ( level.splitScreen )
      hudElemAlpha = 0;
   else
      hudElemAlpha = 0.85;
   
   iconAllies = maps\mp\gametypes\_teams::getTeamIcon("allies");
   iconAxis = maps\mp\gametypes\_teams::getTeamIcon("axis");
   
   level.friendlyDefconStatusIcon["allies"] = createServerIcon( iconAllies, 24, 24, "allies" );
   level.friendlyDefconStatusIcon["allies"] setPoint( "TOP LEFT", "TOP LEFT", 132, 0 );
   level.friendlyDefconStatusIcon["allies"].alpha = hudElemAlpha;
   level.friendlyDefconStatusIcon["allies"].hideWhenInMenu = true;
   
   level.friendlyDefconStatus["allies"] = createServerFontString( "small", 1.6, "allies" );   
   level.friendlyDefconStatus["allies"] setParent( level.friendlyDefconStatusIcon["allies"] );
   level.friendlyDefconStatus["allies"] setPoint( "LEFT", "RIGHT", 4 );
   level.friendlyDefconStatus["allies"] setText( DEFCON_5 );
   level.friendlyDefconStatus["allies"].alpha = hudElemAlpha;
   level.friendlyDefconStatus["allies"].color = (1,1,1);
   level.friendlyDefconStatus["allies"].glowColor = (0.75,0.25,0.25);
   level.friendlyDefconStatus["allies"].glowAlpha = 1;
   level.friendlyDefconStatus["allies"].hideWhenInMenu = true;

   level.enemyDefconStatusIcon["allies"] = createServerIcon( iconAxis, 24, 24, "allies" );
   level.enemyDefconStatusIcon["allies"] setPoint( "TOP LEFT", "TOP LEFT", 132, 26 );
   level.enemyDefconStatusIcon["allies"].alpha = hudElemAlpha;
   level.enemyDefconStatusIcon["allies"].hideWhenInMenu = true;
   
   level.enemyDefconStatus["allies"] = createServerFontString( "small", 1.6, "allies" );
   level.enemyDefconStatus["allies"] setParent( level.enemyDefconStatusIcon["allies"] );
   level.enemyDefconStatus["allies"] setPoint( "LEFT", "RIGHT", 4 );
   level.enemyDefconStatus["allies"] setText( DEFCON_5 );   
   level.enemyDefconStatus["allies"].alpha = hudElemAlpha;
   level.enemyDefconStatus["allies"].color = (1,1,1);
   level.enemyDefconStatus["allies"].glowColor = (0.25,0.75,0.25);
   level.enemyDefconStatus["allies"].glowAlpha = 1;
   level.enemyDefconStatus["allies"].hideWhenInMenu = true;
   
   level.friendlyDefconStatusIcon["axis"] = createServerIcon( iconAxis, 24, 24, "axis" );
   level.friendlyDefconStatusIcon["axis"] setPoint( "TOP LEFT", "TOP LEFT", 132, 0 );
   level.friendlyDefconStatusIcon["axis"].alpha = hudElemAlpha;
   level.friendlyDefconStatusIcon["axis"].hideWhenInMenu = true;

   level.friendlyDefconStatus["axis"] = createServerFontString( "small", 1.6, "axis" );
   level.friendlyDefconStatus["axis"] setParent( level.friendlyDefconStatusIcon["axis"] );   
   level.friendlyDefconStatus["axis"] setPoint( "LEFT", "RIGHT", 4 );
   level.friendlyDefconStatus["axis"] setText( DEFCON_5 );
   level.friendlyDefconStatus["axis"].alpha = hudElemAlpha;
   level.friendlyDefconStatus["axis"].color = (1,1,1);
   level.friendlyDefconStatus["axis"].glowColor = (0.75,0.25,0.25);
   level.friendlyDefconStatus["axis"].glowAlpha = 1;
   level.friendlyDefconStatus["axis"].hideWhenInMenu = true;
   
   level.enemyDefconStatusIcon["axis"] = createServerIcon( iconAllies, 24, 24, "axis" );
   level.enemyDefconStatusIcon["axis"] setPoint( "TOP LEFT", "TOP LEFT", 132, 26 );
   level.enemyDefconStatusIcon["axis"].alpha = hudElemAlpha;
   level.enemyDefconStatusIcon["axis"].hideWhenInMenu = true;

   level.enemyDefconStatus["axis"] = createServerFontString( "small", 1.6, "axis" );
   level.enemyDefconStatus["axis"] setParent( level.enemyDefconStatusIcon["axis"] );
   level.enemyDefconStatus["axis"] setPoint( "LEFT", "RIGHT", 4 );
   level.enemyDefconStatus["axis"] setText( DEFCON_5 );   
   level.enemyDefconStatus["axis"].alpha = hudElemAlpha;
   level.enemyDefconStatus["axis"].color = (1,1,1);
   level.enemyDefconStatus["axis"].glowColor = (0.25,0.75,0.25);
   level.enemyDefconStatus["axis"].glowAlpha = 1;
   level.enemyDefconStatus["axis"].hideWhenInMenu = true;
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


onNormalDeath( victim, attacker, lifeId )
{
   if ( ( isDefined( level.nukeIncoming ) && level.nukeIncoming ) || ( isDefined( level.nukeDetonated ) && level.nukeDetonated ) )
      return;

   score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
   assert( isDefined( score ) );

   attacker maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( attacker.pers["team"], score );
   
   if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level.otherTeam[attacker.team]] )
      attacker.finalKill = true;
      
   level.continuedKillCount[attacker.team]++;
   level.continuedKillCount[getOtherTeam(attacker.team)] = 0;
   level.friendlyDefconStatus[attacker.team].glowAlpha = 1;
   level.friendlyDefconStatus[level.otherTeam[attacker.team]].glowAlpha = 0;
   level.enemyDefconStatus[attacker.team].glowAlpha = 0;
   level.enemyDefconStatus[level.otherTeam[attacker.team]].glowAlpha = 1;
   
   if (level.continuedKillCount[attacker.team] == DEFCON_INTERVAL)
   {
      level.continuedKillCount[attacker.team] = 0;
      if (level.currentDefcon[attacker.team]>0)
      {
         level.currentDefcon[attacker.team]--;
         attacker thread doSplashDefcon(level.currentDefcon[attacker.team]);
      }
   }
   if (isDefined(level.defconStreakUsed[level.currentDefcon[attacker.team]]) && !level.defconStreakUsed[level.currentDefcon[attacker.team]])
   {
      level.defconStreakUsed[level.currentDefcon[attacker.team]] = true;
      streakName = undefined;
      switch(level.currentDefcon[attacker.team])
      {
         case 2: streakName = DEFCON_KS1; break;
         case 3: streakName = DEFCON_KS2; break;
         case 4: streakName = DEFCON_KS3; break;
      }
      foreach (player in level.players)
      {
         if(isDefined(player) && player.team==getOtherTeam(attacker.team))
         {
            player playLocalSound( "mp_defcon_down" );
            player maps\mp\killstreaks\_killstreaks::givekillstreak(streakName,false);
            player maps\mp\killstreaks\_killstreaks::giveOwnedKillstreakItem();
         }
         else if (isDefined(player) && player==attacker)
         {
            player maps\mp\killstreaks\_killstreaks::givekillstreak(streakName,false);
            player maps\mp\killstreaks\_killstreaks::giveOwnedKillstreakItem();
         }
      }
   }
   if (level.currentDefcon[attacker.team] == 1)
   {
      attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "captured_nuke", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) );
      attacker maps\mp\killstreaks\_nuke::tryUseNuke( 1 );
   }
   thread UpdateHud();
}
doSplashDefcon(num)
{
   notifyData = spawnstruct();
   notifyData.iconName = "cardicon_prestige10_02";
   notifyData.titleText = "DEFCON " + num;
   notifyData.glowColor = (0.3, 0.6, 0.3); //RGB Color array divided by 100
   notifyData.sound = "flag_spawned";
   dialog = "defcon_" + num;
   notifyData.leaderSound = dialog;
   foreach ( player in level.players )
   {
      if (isDefined(player) && player.team==self.team)
         player thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
      
      //player thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "changed_defcon", self );
   }
}
UpdateHud()
{
   shader="dpad_killstreak_nuke";
   width = 24;
   height = 24;
   if (level.currentDefcon["allies"]!=1)
      DefconAllies= ("DefCon " + level.currentDefcon["allies"] + ". Kills to next: " + (DEFCON_INTERVAL - level.continuedKillCount["allies"]));
   else
   {
      DefconAllies = DEFCON_1;
      level.friendlyDefconStatusIcon["allies"] setShader( shader, width, height );
      level.friendlyDefconStatusIcon["allies"].shader = shader;
      level.enemyDefconStatusIcon["axis"] setShader( shader, width, height );
      level.enemyDefconStatusIcon["axis"].shader = shader;
   }
   if (level.currentDefcon["axis"]!=1)
      DefconAxis= ("DefCon " + level.currentDefcon["axis"] + ". Kills to next: " + (DEFCON_INTERVAL - level.continuedKillCount["axis"]));
   else
   {
      DefconAxis = DEFCON_1;
      level.friendlyDefconStatusIcon["axis"] setShader( shader, width, height );
      level.friendlyDefconStatusIcon["axis"].shader = shader;
      level.enemyDefconStatusIcon["allies"] setShader( shader, width, height );
      level.enemyDefconStatusIcon["allies"].shader = shader;
   }

   level.friendlyDefconStatus["allies"] setText( DefconAllies );
   level.enemyDefconStatus["allies"] setText( DefconAxis );
   level.friendlyDefconStatus["axis"] setText( DefconAxis );
   level.enemyDefconStatus["axis"] setText( DefconAllies );
}
onTimeLimit()
{
   if ( game["status"] == "overtime" )
   {
      winner = "forfeit";
   }
   else if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
   {
      winner = "overtime";
   }
   else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
   {
      winner = "axis";
   }
   else
   {
      winner = "allies";
   }
   
   thread maps\mp\gametypes\_gamelogic::endGame( winner, game["strings"]["time_limit_reached"] );
}