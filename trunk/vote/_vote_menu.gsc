#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

/**********
** vote system by banz v1.1
**
** TODO: 
** add gametype voting - done
** maybe: add quick selecting through numpad buttons (qs menu...)
**
**
***********/

init()
{
	precacheShader( "menu_setting_selection_bar" );

	
	setDvarIfUninitialized( "sv_votemaps", "Favela,Afghan,Crash,Skidrow,Estate,Trailerpark,Strike,Vacant,Highrise,Storm,Invasion,Karachi,Bailout,Subbase,Rundown,Quarry" );
	
	setDvarIfUninitialized( "sv_votemodes", "sd,war,dom,gg,dm" );
	
	setDvarIfUninitialized( "sv_mapcount", 8 );
	
	setDvar( "sv_changemethod", 0 ); //Use 1 on dedicated servers or use 0 for private matches.
	
	setDvarIfUninitialized( "sv_voteall", 0 );
	//setDvarIfUninitialized( "sv_menusound", 1 );
	
	setDvarIfUninitialized( "sv_voteonly", "map" );
	
	//level.menuSound = getDvarInt( "sv_menusound" );
	
	level.changeMode = getDvarInt( "sv_changemethod" );
	level.voteAll = getDvarInt( "sv_voteall");
	level.voteOnly = getDvar( "sv_voteonly" );
	
	level.voteMaps = getDvar( "sv_votemaps" );
	level.voteModes = getDvar( "sv_votemodes" );
	
	level.mapTok = strTok( level.voteMaps, "," );
	level.modeTok = strTok( level.voteModes, "," );
	
	level.maxMaps = getDvarInt( "sv_mapcount" );
	
	checkMaps = level.mapTok;
	checkModes = level.modeTok;
	
	//check for invalid maps, modes
	thread checkDvars( checkMaps, checkModes );
	
	if( level.maxMaps > 15 || level.maxMaps < 1 )
		level.maxMaps = 15;
		
	if( level.maxMaps > level.mapTok.size )
		level.maxMaps = level.mapTok.size;
	
    randomArray = [];
      
    for(i = 0; i < level.maxMaps; i++) {
		selectedRand = randomintrange(0, level.mapTok.size);
        randomArray[i] = level.mapTok[selectedRand];
        level.mapTok = restructMapArray(level.mapTok, selectedRand);
    }
      
     level.mapTok = randomArray;
   
	for( i=0; i < level.mapTok.size; i++ )
	{
		level.mapVotes[i] = 0;
	}
	for( i=0; i < level.modeTok.size; i++ )
	{
		level.modeVotes[i] = 0;
	}
	
}

checkDvars( maps, modes )
{
	level endon( "check_done" );
	
	mapError = 0;
	modeError = 0;
	
	//check for typos / invalid maps
	if ( !checkMaps( maps ) ) {
		mapError = 1;
	}
	if( !checkGameType( modes ) ) {
		modeError = 1;
	}
	if( mapError || modeError )
		thread errorMessage( mapError, modeError );
		
		
	level notify( "check_done" );	
}



errorMessage( error1, error2  )
{
level endon("game_ended");
	
	if( error1 && error2 )
		logPrint("vote error: there is a typo in sv_votemaps and sv_votemodes dvar!");
	else if( error1 && !error2 )
		logPrint("vote map error: there is a typo in sv_votemaps dvar!");
	else
		logPrint("vote mode error: there is a typo in sv_votemodes dvar!");
		
		
	for(;;)
	{
		if( error1 && error2 )
			iprintlnbold("^7Error in ^1sv_votemaps ^7and ^1sv_votemodes ^7dvar!");
		else if( error1 && !error2 )
			iprintlnbold("^7Error in ^1sv_votemaps ^7dvar!");
		else
			iprintlnbold("^7Error in ^1sv_votemodes ^7dvar!");
	wait 5;
	}
}



checkGameType( types )
{
	foreach( type in types ) {
		switch( type )
		{
		case "war":
		case "dm":
		case "dom":
		case "koth":
		case "sab":
		case "sd":
		case "arena":
		case "dd":
		case "ctf":
		case "oneflag":
		case "gtnw":
		case "oitc":
		case "gg":
		case "ss":
		case "m40a3": //m40a3 gametype
			continue;
		default:
			return false;
		}
	}
	return true;
}


checkMaps( maps )
{
	foreach( map in maps) {
		map = toLower( map );
	
		switch( map )
		{
		case "favela":
		case "crash":
		case "skidrow":
		case "estate":
		case "wasteland":
		case "strike":
		case "vacant":
		case "highrise":
		case "invasion":
		case "karachi":
		case "bailout":
		case "subbase":
		case "afghan":
		case "carnival":
		case "fuel":
		case "salvage":
		case "scrapyard":
		case "derail":
		case "quarry":
		case "rundown":
		case "rust":
		case "underpass":
		case "overgrown":
		case "storm":
		case "trailerpark":
		case "terminal": //added
		case "nuketown":
		case "oilrig":
		case "burgertown":
		case "credits":
		case "gulag":
		case "contingency":
		case "pripyat":
		//dlc4
		case "crossfire":
		case "bloc":
		case "cargoship":
			continue;
		default:
			return false;
		}
	}
	return true;
}


restructMapArray(oldArray, index)
{
   restructArray = [];

	for( i=0; i < oldArray.size; i++) {
		if(i < index) 
			restructArray[i] = oldArray[i];
		else if(i > index) 
			restructArray[i - 1] = oldArray[i];
	}

	return restructArray;
}


updateMenuDisplay()
{
	self endon( "disconnect" );
	self endon("kill_menu");
	level endon( "time_over" );
	for(;;)
	{
		wait 0.1;
		if( self.mOpen == "map" )
		{
			for(i=0; i < level.mapTok.size; i++) {
				if( getMapName( toLower( level.mapTok[i] ) ) == level.winMap && level.mapVotes[i] != 0 )
					self.mText[i] setText("^3"+level.mapTok[i]+" ["+level.mapVotes[i]+"/"+level.players.size+"]" );
				else
					self.mText[i] setText(level.mapTok[i]+" ["+level.mapVotes[i]+"/"+level.players.size+"]" );
			}
		}
		else if ( self.mOpen == "mode" )
		{
			for(i=0; i < level.modeTok.size; i++) {
				if( toLower( level.modeTok[i] )  == level.winMode && level.modeVotes[i] != 0 )
					self.mText[i] setText("^3"+getModeName(level.modeTok[i])+" ["+level.modeVotes[i]+"/"+level.players.size+"]" );
				else
					self.mText[i] setText(getModeName(level.modeTok[i])+" ["+level.modeVotes[i]+"/"+level.players.size+"]" );
			}
		}
	}
}


getHighestVotedMap()
{
	highest = 0;

	position = randomInt(level.mapVotes.size);
	
	for(i=0; i < level.mapVotes.size; i++ ) {		
		if( level.mapVotes[i] > highest ) {
			highest = level.mapVotes[i];
			position = i;
		}
	}		

	return position;
}

getHighestVotedMode()
{
	highest = 0;

	position = randomInt(level.modeVotes.size);
	
	for(i=0; i < level.modeVotes.size; i++ ) {
	
		if( level.modeVotes[i] > highest ) {
			highest = level.modeVotes[i];
			position = i;
		}
	}		

	return position;
}

hasBeenVoted()
{
	for(i=0; i < level.modeVotes.size; i++ ) {
		if( level.modeVotes[i] > 0 )
				return true;
	}			
	return false;
}



castMap( number )
{
	if( !isDefined(self.hasVoted) || !self.hasVoted ) {
		self.hasVoted = 1;
		level.mapVotes[number]++;
		self.votedNum = number;
		self iprintln("You voted for ^3"+level.mapTok[self.votedNum]);
	}
	else if( self.hasVoted && isDefined( self.votedNum ) && self.votedNum != number )
	{
		level.mapVotes[self.votedNum]--;
		level.mapVotes[number]++;
		self.votedNum = number;
		self iprintln("You ^3re-voted ^7for ^3"+level.mapTok[self.votedNum]);
	}
	else if( self.hasVoted && isDefined( self.votedNum ) && self.votedNum == number )
	{
		level.mapVotes[self.votedNum]--;
		self.votedNum = undefined;
		self.hasVoted = undefined;
		self iprintln("You ^3cancelled^7 your previous vote.");
	}
}

castMode( number )
{
	if( !isDefined(self.hasVotedb) || !self.hasVotedb ) {
		self.hasVotedb = 1;
		level.modeVotes[number]++;
		self.votedNumb = number;
		self iprintln("You voted for ^3"+getModeName(level.modeTok[self.votedNumb]));
	}
	else if( self.hasVotedb && isDefined( self.votedNumb ) && self.votedNumb != number )
	{
		level.modeVotes[self.votedNumb]--;
		level.modeVotes[number]++;
		self.votedNumb = number;
		self iprintln("You ^3re-voted ^7for ^3"+getModeName(level.modeTok[self.votedNumb]));
	}
	else if( self.hasVotedb && isDefined( self.votedNumb ) && self.votedNumb == number )
	{
		level.modeVotes[self.votedNumb]--;
		self.votedNumb = undefined;
		self.hasVotedb = undefined;
		self iprintln("You ^3cancelled^7 your previous vote.");
	}
}

onDisconnect()
{
	level endon ( "time_over" );
	self waittill ( "disconnect" );

	if ( isDefined( self.votedNum ) ) {
		level.mapVotes[self.votedNum]--;
	}
	if( isDefined( self.VotedNumb ) ) {
		level.modeVotes[self.votedNumb]--;
	}
}

handleVoting()
{
level endon( "time_over" );
level endon( "game_ended" );
level.RandomMap = toLower( level.mapTok[randomInt(level.mapTok.size)] );  
level.winMap = getMapName( level.RandomMap );

if( !level.voteAll && level.voteOnly == "gametype" ) {
	level.RandomMode = toLower( level.modeTok[randomInt(level.modeTok.size)] );  //random gametype only, if gametype only vote
	level.winMode = level.RandomMode;
}
else
	level.winMode = level.gameType;

	while( level.player.size > 0 )
	{		
		winNumberA = getHighestVotedMap();
		winNumberB = getHighestVotedMode();
		
		level.winMap = getMapName( toLower( level.mapTok[winNumberA] ) ); 
		if( level.voteAll || level.voteOnly != "gametype" ) {
			if( hasBeenVoted() )
				level.winMode = toLower( ( level.modeTok[winNumberB] ) ); 
			else
				level.winMode = level.gameType; 
		}
		else
			level.winMode = toLower( ( level.modeTok[winNumberB] ) ); 
	
	wait 0.2;
	}
	if( level.voteAll || level.voteOnly != "gametype" )
		level.winMode = level.gameType;
}


getMapName( map )
{
	
	switch( map )
	{
	case "bailout":
		return "complex";
	case "carnival":
		return "abandon";
	case "fuel":
		return "fuel2";
	case "karachi":
		return "checkpoint";
	case "salvage":
		return "compact";
	case "scrapyard":
		return "boneyard";
	case "skidrow":
		return "nightshift";
	case "wasteland":
		return "brecourt";
	case "nuketown":
		return "nuked";
	case "burgertown":
		return "invasion2";
	case "pripyat":
		return "so_ghillies";
	case "credits":
		return "iw4_credits";
	case "crossfire":
		return "cross_fire";
	default:
		return map;
	}
}


getModeName( mode )
{
	switch( mode )
	{
	case "war":
		return "Team Deathmatch";
	case "sd":
		return "Search And Destroy";
	case "dom":
		return "Domination";
	case "dd":
		return "Demolition";
	case "ctf":
		return "Capture The Flag";
	case "dm":
		return "Free For All";
	case "gg":
		return "Gun Game";
	case "ss":
		return "Sharpshooter";
	case "oitc":
		return "One In The Chamber";
	case "arena":
		return "Arena";
	case "vip":
		return "VIP";
	case "gtnw":
		return "Global Thermal Nuclear War";
	case "koth":
		return "Headquarters";
	case "oneflag":
		return "One Flag CTF";
	case "sab":
		return "Sabotage";
	default:
		return "invalid gamemode";
	}	
}


showScores()
{
	self endon( "disconnect" );
	level endon("time_over");
	//self.mOpen = "";
	
	for(;;)
	{	
		self waittill( "closed" );
		wait 0.05;
		if( self.mOpen == "" ) {
			self notify("kill_menu");
			self closepopupMenu();
			self closeInGameMenu();
			self.sessionstate = "intermission";
			self openMenu( game["menu_endgameupdate"] );
			break;
		}
	}	
}


getMenuMapString()
{
	menuString = "";
	
	for(i=0; i < level.mapTok.size; i++) {
		if( i < level.mapTok.size )
			menuString += level.mapTok[i]+" ["+level.mapVotes[i]+"/"+level.players.size+"],";
		else
			menuString += level.mapTok[i]+" ["+level.mapVotes[i]+"/"+level.players.size+"]";
	}
		
	return menuString;
}

getMenuModeString()
{
	menuString = "";
	
	for(i=0; i < level.modeTok.size; i++) {
		if( i < level.modeTok.size )
			menuString += getModeName( level.modeTok[i] )+" ["+level.modeVotes[i]+"/"+level.players.size+"],";
		else
			menuString += getModeName( level.modeTok[i] )+" ["+level.modeVotes[i]+"/"+level.players.size+"]";
	}
		
	return menuString;
}


create_vote_menu()
{
	self endon("disconnect"); 
	self endon("cac_done");
	//level endon("time_over");
	
	if( level.voteAll )
	{
		self addMenu( "main", "VOTING SYSTEM", "1. Map,2. Gametype",  "none");
		self addMenu( "map", "VOTE NEXT MAP", self getMenuMapString(), "main");
		self addMenu( "mode", "VOTE NEXT GAMETYPE", self getMenuModeString(), "main");
		
		self addFunc( "main", ::setMenu, "map" );
		self addFunc( "main", ::setMenu, "mode" );
		
		
		for(i=0; i < level.mapTok.size; i++) {
			self addFunc( "map", ::castMap, i);
		}
	
		for(i=0; i < level.modeTok.size; i++) {
			self addFunc( "mode", ::castMode, i);
		}
	}
	else if( !level.voteAll )
	{
		if ( level.voteOnly == "map" ) {
			self addMenu( "map", "VOTE NEXT MAP", self getMenuMapString(), "none");
			for(i=0; i < level.mapTok.size; i++) {
				self addFunc( "map", ::castMap, i);
			}
		}
			
		else if( level.voteOnly == "gametype" ) {
			self addMenu( "mode", "VOTE NEXT GAMETYPE", self getMenuModeString(), "none");
			for(i=0; i < level.modeTok.size; i++) {
				self addFunc( "mode", ::castMode, i);
			}
		}
	}

	self notify("cac_done");
}

createRectangle( align, relative, x, y, width, height, color, alpha, shader ) 
{
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	
	if( isDefined( shader ) )
		barElemBG setShader( shader, width, height );
	else
		barElemBG setShader( "progress_bar_bg", width, height );
	
	barElemBG.hidden = false;
	barElemBG setPoint( align, relative, x, y );
	barElemBG.x = -2;
	barElemBG.y = -2;
	return barElemBG;
}

runVoteMenu()
{
	self endon("disconnect");
	self endon("kill_menu");
	
	level endon("time_over");
	self.mOpen = "";
	self.mPlay = "";
	self.mCurs = [];
	self.mText = [];
	self.mBack = [];
	self.mBack[0] = createRectangle( "LEFT", "LEFT", 150, 0, 285, 720, ( 0, 0, 0 ), 0 );
	self.mBack[1] = createRectangle( "", "", 0, 0, 1000, 720, ( 0, 0, 0 ), 0 );
	self.mBack[2] = createRectangle( "LEFTTOP", "LEFTTOP", -10, 79, 285, 22, ( 0, 0, 0 ), 0, "menu_setting_selection_bar" );
	
	//self.mBack[3] = createRectangle( "RIGHTTOP", "RIGHTTOP", -10, 79, 285, 22, ( 0, 0, 0 ), 0, "menu_button_selection_bar" );
	self setMenu("");
	self thread runCurs();
	for(;;)
	{
		self waittill("buttonPress", button);
		if(self.mOpen != "")
		{
			if( button == "up" )
			{
				if(self.mCurs[self.mOpen] == 0) 
					self.mCurs[self.mOpen] = self.mText.size - 1;
				else 
					self.mCurs[self.mOpen]--;
					
				if( self.mOpen == "main" && self.mCurs[self.mOpen] == 6 )
					self.mCurs[self.mOpen]--;
					
				if( self.mOpen == "main" && self.mCurs[self.mOpen] == 8 )
					self.mCurs[self.mOpen]--;	
				
				self playLocalSound( "mouse_over" );
				self notify("slide");
			}
			else if( button == "down" )
			{
				if(self.mCurs[self.mOpen] == self.mText.size - 1) 
					self.mCurs[self.mOpen] = 0;
				else 
					self.mCurs[self.mOpen]++;
					
				if( self.mOpen == "main" && self.mCurs[self.mOpen] == 6 )
					self.mCurs[self.mOpen]++;
					
				if( self.mOpen == "main" && self.mCurs[self.mOpen] == 8 )
					self.mCurs[self.mOpen]++;	
				
				self playLocalSound( "mouse_over" );
				self notify("slide");
			}
			else if( button == "select" )
			{
				self.selected = 0;
				self [[level.menu[self.mOpen].func[self.mCurs[self.mOpen]]]](level.menu[self.mOpen].args[self.mCurs[self.mOpen]]);
				self playLocalSound( "mouse_click" );
			}
			else if( button == "open/cancel" )
			{
				if(level.menu[self.mOpen].parent != "none") 
				{
					self setMenu(level.menu[self.mOpen].parent);
					self playLocalSound( "mouse_over" );
				}
				else
					self exit_menu();
			}
		}
		else
		{
			if( button == "open/cancel" ) 
			{

				self setClientDvar( "cg_hudChatPosition", "200 640" );
				self setBlurForPlayer( 10, 0 );
				self setMoveSpeedScale( 0 );
				//self allowJump(false);

				if (level.voteAll )
					self setMenu("main"); 
				else if( !level.voteAll )
				{
					if( level.voteOnly == "map" ) 
						self setMenu("map"); 
					else if( level.voteOnly == "gametype" ) 
						self setMenu("mode"); 
				}
			}
		}
		wait 0.05;
	}
}

runCurs()
{
	self endon("disconnect");
	self endon("kill_menu");
	level endon("time_over");
	cursLast = -1;
	for(;;)
	{
		self waittill("slide");
		
		self notify( "stop_text_flashing" );
		self.mText[cursLast].color = ( 1, 1, 1 );
		self.mText[self.mCurs[self.mOpen]] thread flashing( self );
		self.mBack[2].y = ( self.mCurs[self.mOpen] * 24 ) + 62;
		cursLast = self.mCurs[self.mOpen];
		wait 0.05;
	}
}

flashing( player )
{
	player endon( "stop_text_flashing" );
	level endon("time_over");
	for(;;)
	{
		self.color = ( 1, 1, 1 );
		wait .1;
		self.color = ( 0.85, 0.85, 0.85 );
		wait .15;
		self.color = ( 0.7, 0.7, 0.7 );
		wait .1;
		self.color = ( 0.85, 0.85, 0.85 );
		wait .15;
	}
}

setMenu(name)
{	
	self wipeMenu();
	self.mText = [];
	self.mOpen = name;
	
	if( !isDefined( self.mCurs[self.mOpen] ) ) 
		self.mCurs[self.mOpen] = 0;
	
	if( self.mOpen != "" )
	{
		if( !self.mBack[0].alpha || !self.mBack[1].alpha )
		{
			self.mBack[0].alpha = .25;
			self.mBack[1].alpha = .25;
			self.mBack[2].alpha = 1;
		}
		self.tText = self createText( "hudBig", 1, "LEFT", "LEFT", 10, -190, level.menu[self.mOpen].title );
		self.iText = self createText( "default", 1.6, "LEFTBOTTOM", "LEFTBOTTOM", 10, -45, "^3[{+forward}]/[{+back}] ^0- ^7Navigate\n^3[{+gostand}] ^0- ^7Select\n^3[{+actionslot 2}] ^0- ^7Back/Close");
		for( i = 0; i < level.menu[self.mOpen].text.size; i++ )
		{
			self.mText[i] = self createText( "default", 1.6, "", "", -100, 60+(i*24), level.menu[self.mOpen].text[i] );	
			self.mText[i] setPoint( "LEFT", "LEFT", 10, -168+(i*24) );
		}
		self notify( "slide" );
	}
	else
	{
		for( i = 0; i < self.mBack.size; i++ )
			self.mBack[i].alpha = 0;
	}
}

wipeMenu()
{
	self.tText destroy();
	self.iText destroy();
	
	for(i = 0; i < self.mText.size; i++) 
		self.mText[i] destroy();
	
	self.tText = undefined;
	self.iText = undefined;
	self.mText = undefined; 
}

createText(font, fontScale, point, rPoint, x, y, text)
{
	fontElem = newClientHudElem( self );
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.baseFontScale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	fontElem.color = ( 1, 1, 1 );
	fontElem setPoint(point, rPoint, x, y);
	fontElem setText(text);
	return fontElem;
}

addMenu(name, title, text, parent)
{
	if(!isDefined(level.menu)) level.menu = [];
	level.menu[name] = spawnStruct();
	level.menu[name].text = [];
	level.menu[name].func = [];
	level.menu[name].args = [];
	level.menu[name].title = title;
	level.menu[name].text = strTok(text, ",");
	
	if(!isDefined(parent) || parent == "")
		level.menu[name].parent = "none";
	else 
		level.menu[name].parent = parent;
}

addFunc(name, func, args)
{
	arraySize = level.menu[name].func.size;
	level.menu[name].func[arraySize] = func;
	level.menu[name].args[arraySize] = args;
}

watchVoteButtons()
{
	self endon("disconnect");
	self endon("kill_menu");
	level endon("time_over");
	self notifyOnPlayerCommand( "up", "+forward" );
	self notifyOnPlayerCommand( "down", "+back" );
	self notifyOnPlayerCommand( "select", "+gostand" );
	self notifyOnPlayerCommand( "open/cancel", "+actionslot 2" );
	for(;;)
	{
		button = self waittill_any_return( "up", "down", "select", "open/cancel", "death" );
		if( button == "death" )
			continue;
		else
			self notify( "buttonPress", button );
	}
}

exit_menu()
{
        self setMenu("");
        self setBlurForPlayer( 0, 0 );
        self setClientDvar( "cg_hudChatPosition", "5 200" );
		self notify( "closed" );
}

