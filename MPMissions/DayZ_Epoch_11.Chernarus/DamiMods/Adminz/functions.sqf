/*
	Created by:
	Dami
*/
//----------------------------------------------//
	enable_debugmonitor = true;					// Enables and binds the debug monitor to right control on the keyboard.
	join_messages 		= true;					// Welcomes a player with "Welcome to _server_name(whatever you set this variable to"
	disable_voiceonside = true;					// True - Prevents voice on side.
	has_serversite 		= true; 				// True - Adds "Be sure to visit us @ _server_site(whatever you set this variable to)" to welcome message.
	_server_site 		= "survivors-sanctuary.com"; 	//For debug
	_server_name 		= "UKSS #1";		//For welcome message
	_donatorlistok 		=						//Removes gear from the player IDs in this array when they die.
	[
		"39087238","39092806"
	];
//---------------------------------------------//
"norrnRaLW" addPublicVariableEventHandler {[_this select 1] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\publicEH\load_wounded.sqf");};
"norrnRLact" addPublicVariableEventHandler {[_this select 1] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\load\load_wounded.sqf");};
"norrnRDead" addPublicVariableEventHandler {[_this select 1] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\publicEH\deadState.sqf");};
"norrnRaDrag" addPublicVariableEventHandler {[_this select 1] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\publicEH\animDrag.sqf");};
"norrnRnoAnim" addPublicVariableEventHandler {[_this select 1] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\publicEH\noAnim.sqf");};

player_useMeds = {
	private["_item"];
	_item = _this;
	call gear_ui_init;
	_onLadder =		(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
	if (_onLadder) exitWith {cutText [(localize "str_player_21") , "PLAIN DOWN"]};
	_hasmeditem = _this in magazines player;
	_config = configFile >> "CfgMagazines" >> _item;
	_text = getText (_config >> "displayName");
	if (!_hasmeditem) exitWith {cutText [format[(localize "str_player_31"),_text,"use"] , "PLAIN DOWN"]};
	switch (_item) do {
		case "ItemBandage": {
			[0,0,0,[player]] spawn (compile preProcessFileLineNumbers "DamiMods\Adminz\bandage.sqf");
		};
		case "ItemMorphine": {
			[0,0,0,[player]] spawn (compile preProcessFileLineNumbers "DamiMods\Adminz\morphine.sqf");
		};
		case "ItemPainkiller": {
			[0,0,0,[player]] spawn (compile preProcessFileLineNumbers "DamiMods\Adminz\painkiller.sqf");
		};
		case "ItemAntibiotic": {
			[0,0,0,[player]] spawn (compile preProcessFileLineNumbers "DamiMods\Adminz\antibiotics.sqf");
		};
		case "ItemHeatPack": {
			player removeMagazine "ItemHeatPack";
			dayz_temperatur = (dayz_temperatur + 5) min dayz_temperaturmax;
			cutText [localize "str_player_27", "PLAIN DOWN"];
		};
	};
};

dayz_spaceInterrupt = {
	private ["_dikCode", "_handled"];
	_dikCode = _this select 1;
	_handled = false;
	if (_dikCode in (actionKeys "GetOver")) then {
		if (!r_fracture_legs and (time - dayz_lastCheckBit > 4)) then {
			_inBuilding = [player] call fnc_isInsideBuilding;
			_nearbyObjects = nearestObjects[getPosATL player, ["TentStorage", "Hedgehog_DZ", "Sandbag1_DZ","TrapBear","Wire_cat1"], 8];
			if (!_inBuilding and (count _nearbyObjects == 0)) then {
				dayz_lastCheckBit = time;
				call player_CombatRoll;
			};
		};
	};
	if (_dikCode in actionKeys "MoveLeft") then {r_interrupt = true};
	if (_dikCode in actionKeys "MoveRight") then {r_interrupt = true};
	if (_dikCode in actionKeys "MoveForward") then {r_interrupt = true};
	if (_dikCode in actionKeys "MoveBack") then {r_interrupt = true};
	if (_dikCode in actionKeys "ForceCommandingMode") then {_handled = true};
	if (_dikCode in actionKeys "PushToTalk" and (time - dayz_lastCheckBit > 10)) then {
		dayz_lastCheckBit = time;
		[player,50,true,(getPosATL player)] spawn player_alertZombies;
	};
	if (_dikCode in actionKeys "VoiceOverNet" and (time - dayz_lastCheckBit > 10)) then {
		dayz_lastCheckBit = time;
		[player,50,true,(getPosATL player)] spawn player_alertZombies;
	};
	if (_dikCode in actionKeys "PushToTalkDirect" and (time - dayz_lastCheckBit > 10)) then {
		dayz_lastCheckBit = time;
		[player,15,false,(getPosATL player)] spawn player_alertZombies;
	};
	if (_dikCode in actionKeys "Chat" and (time - dayz_lastCheckBit > 10)) then {
		dayz_lastCheckBit = time;
		[player,15,false,(getPosATL player)] spawn player_alertZombies;
	};
	if (_dikCode in actionKeys "User20" and (time - dayz_lastCheckBit > 5)) then {
		dayz_lastCheckBit = time;
	};
	if ((_dikCode == 0x3E or _dikCode == 0x0F or _dikCode == 0xD3) and (time - dayz_lastCheckBit > 10)) then {
		dayz_lastCheckBit = time;
		call dayz_forceSave;
	};
	if (_dikCode == 0x9D) then {
		if (debugMonitor) then {
			debugMonitor = false;
			hintSilent "";
		} else {[enable_debugmonitor,join_messages,_server_site,_server_name,_donatorlistok,has_serversite] spawn fnc_debug;};
	};
	_handled
};

fnc_usec_playerBleed = {
	private["_bleedTime","_bleedPerSec","_total","_bTime","_myBleedTime"];
	_bleedTime = 400;
	_bleedPerSec = (r_player_bloodTotal / _bleedTime);
	_total = r_player_bloodTotal;
	r_player_injured = true;
	_myBleedTime = (random 500) + 100;
	_bTime = 0;
	while {r_player_injured} do {
		if (r_player_blood > 0) then {
			r_player_blood = r_player_blood - _bleedPerSec;
		};
		_bTime = _bTime + 1;
		if (_bTime > _myBleedTime) then {
			r_player_injured = false;
			_id = [player,player] spawn (compile preProcessFileLineNumbers "\z\addons\dayz_code\medical\publicEH\medBandaged.sqf");
			dayz_sourceBleeding = objNull;
			{player setVariable[_x,false,true];} forEach USEC_woundHit;
			player setVariable ["USEC_injured",false,true];
		};
		sleep 1;
	};
};

fnc_debug =
{
	enable_debugmonitor = _this select 0;
	join_messages 		= _this select 1;
	_server_site 		= _this select 2;
	_server_name 		= _this select 3;
	_donatorlistok 		= _this select 4;
	has_serversite 		= _this select 5;
	waitUntil {(!isNil 'dayz_Totalzedscheck') || (!isNil 'dayz_locationCheck') || (!isNil 'dayzplayerlogin') || (!isNil 'dayz_animalcheck')};
	if ((isNil "debugfirstrun") && (enable_debugmonitor)) then
	{
		hintSilent parseText format ["Welcome to <t size='0.95'font='Zeppelin33'align='center'color='#E20000'>%2</t>, %1!",name player, _server_name];
		sleep 4;
		debugMonitor = true;
		debugfirstrun = true;
	} else {if (enable_debugmonitor) then {debugMonitor = true;} else {debugmonitor = false;};};
	while {debugMonitor} do
	{
		if (join_messages) then
		{
			if (isNil "first_jip_join") then
			{
				first_jip_join = true;
				if (getPlayerUID player in _donatorlistok) then
				{
					sleep 5;
					cutText [format ["Welcome back, %2!",_server_site,name player],"PLAIN DOWN"];
					sleep 5;
					cutText [format ["Thanks for donating! Your gear will disappear when you die.",_server_name],"PLAIN DOWN"];
					sleep 15;
					player addEventHandler ['killed',
					{
						removeAllWeapons player;
						removeBackpack player;
						debugMonitor = false;
						hint "Your weapons have been removed from your dead body!";
					}];
				}
				else
				{
					sleep 5;
					cutText [format ["Welcome to %1, %2! RCTRL toggles the DEBUG.",_server_name, name player],"PLAIN DOWN"];
					sleep 5;
					if (has_serversite) then
					{
						cutText [format ["Be sure to visit our site @ %1",_server_site],"PLAIN DOWN"];
					};
				};
			};
		};
		_kills = (player getVariable['zombieKills', 0]);
		_killsH = (player getVariable['humanKills', 0]);
		_killsB = (player getVariable['banditKills', 0]);
		_humanity = (player getVariable['humanity', 0]);
		_zombies = count (getPos player nearEntities [["zZombie_Base"], 11000]);
		_zombiesA = {alive _x} count (getPos player nearEntities [["zZombie_Base"], 11000]);
		_currentclass = (gettext (configFile >> 'CfgVehicles' >> (typeof vehicle player) >> 'displayName'));
		_currentvehicle = (gettext (configFile >> 'CfgVehicles' >> (typeof vehicle player) >> 'picture'));
		_currentvehiclez = format ["<img size='1' image='%1'/>",_currentvehicle];
		hintSilent parseText format ["
		<t size='1.25' font='Bitstream'align='center'color='#D4D4D4'>
	%1</t><br/>
	
		<t size='0.95'font='Zeppelin33'align='center'color='#E20000'>
	[<t color='#D4D4D4'>%12</t>]</t><br/>
	
		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Days Survived:</t>

		<t size='0.95'font='Bitstream'align='right'color='#D4D4D4'>
	%15</t><br/>
	
		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	FPS:</t>

		<t size='0.95' font='Bitstream'align='right'color='#D4D4D4'>
	%4</t><br/>
	
		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Blood:</t>

		<t size='0.95' font='Bitstream'align='right'color='#D4D4D4'>
	%2</t><br/>

		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Humanity:</t>

		<t size='0.95'font='Bitstream'align='right'color='#D4D4D4'>
	%3</t><br/><br/>

		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Murders:</t>

		<t size='0.95'font='Bitstream'align='right'color='#D4D4D4'>
	%5</t><br/>

		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Bandit Kills:</t>

		<t size='0.95'font='Bitstream'align='right'color='#D4D4D4'>
	%6</t><br/>

		<t size='0.9'font='Zeppelin33'align='left'color='#FF0000'>
	Zombie Kills:</t>

		<t size='0.95'font='Bitstream'align='right'color='#D4D4D4'>
	%7</t><br/>
	
		<t size='0.85'font='Zeppelin33'align='center'color='#E20000'>
	survivors-sanctuary.com</t><br/>",
		(dayz_playerName),	/*1*/
		(r_player_blood),	/*2*/
		(round _humanity),	/*3*/
		(round diag_fps),	/*4*/
		_killsH,			/*5*/
		_killsB,			/*6*/
		_kills,				/*7*/
		_zombiesA,			/*8*/
		_zombies,			/*9*/
		_server_site,		/*10*/
		(dayz_skilllevel),	/*11*/
		_currentclass,		/*12*/
		_currentvehiclez,	/*13*/
		_onlineassholes,	/*14*/
		dayz_skilllevel
		];
	};
};

[enable_debugmonitor,join_messages,_server_site,_server_name,_donatorlistok,has_serversite] spawn fnc_debug;