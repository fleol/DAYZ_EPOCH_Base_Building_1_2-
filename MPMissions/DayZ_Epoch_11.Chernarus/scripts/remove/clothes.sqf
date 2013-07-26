// Created by [GEEK SQUAD]Churchie
// Contributors to getting it working are:| cyrq | Manatee Hunter | Deasil | Seaweeduk |Thank you!
// Line 9 Edited For Epoch Skins By TayTayTheKiller
player removeAction s_clothes;
s_clothes = -1;
private["_body","_result"];
    _body = _this select 3;
    _model = typeOf _body;
if( _model in ["Sniper1_DZ","Camo1_DZ""Skin_Functionary1_EP1_DZ","Skin_Haris_Press_EP1_DZ","Skin_Ins_Soldier_GL_DZ","Skin_Rocker2_DZ","Skin_Sniper1_DZ","Skin_Soldier_Bodyguard_AA12_PMC_DZ","Skin_Survivor2_DZ","Skin_TK_INS_Soldier_EP1_DZ","Skin_TK_INS_Warlord_EP1_DZ","Skin_Rocker1_DZ","Skin_Rocker3_DZ","Skin_Rocker4_DZ","Skin_Bandit1_DZ Clothes Bandit","Skin_Bandit2_DZ Clothes Bandit","Skin_BanditW1_DZ Clothes Bandit Female","Skin_BanditW2_DZ Clothes Bandit Female","Skin_SurvivorW2_DZ Clothes Female","Skin_SurvivorW3_DZ Clothes Female","Skin_SurvivorWpink_DZ Clothes Female","Skin_SurvivorWcombat_DZ Clothes Female","Skin_SurvivorWdesert_DZ Clothes Female","Skin_SurvivorWurban_DZ Clothes Female","Skin_CZ_Special_Forces_GL_DES_EP1_DZ Clothes Hero","Skin_Drake_Light_DZ Clothes Hero","Skin_Pilot_EP1_DZ Clothes Hero","Skin_RU_Policeman_DZ Clothes Hero","Skin_Camo1_DZ Clothes","Skin_Rocket_DZ Clothes","Skin_Soldier1_DZ Clothes","Skin_Soldier_Sniper_PMC_DZ","Skin_Soldier_TL_PMC_DZ","Skin_FR_OHara_DZ","Skin_FR_Rodriguez_DZ","Skin_CZ_Soldier_Sniper_EP1_DZ","Skin_Graves_Light_DZ","Skin_GUE_Commander_DZ","Skin_GUE_Soldier_2_DZ","Skin_GUE_Soldier_CO_DZ","Skin_GUE_Soldier_Crew_DZ","Skin_GUE_Soldier_Sniper_DZ"] ) then { _model = "Skin_" + _model;
	_rnd = random 1;
	if (_rnd > 0.4) then {
		_result = [player,_model] call BIS_fnc_invAdd;
	}
	else {
		_model = "Skin_Survivor2_DZ";
		_result = [player,_model] call BIS_fnc_invAdd;
		cutText ["The clothing tears as you try to remove it from the corpse", "PLAIN DOWN"];
	};
if (_result) then { player playActionNow "PutDown";
private["_name","_method","_methodStr"];
    _name = _body getVariable["bodyName","unknown"];
    _method = _body getVariable["deathType","unknown"];
    _methodStr = localize format ["str_death_%1",_method];
    _class = "Survivor2_DZ";
    _position = getPosATL _body;
    _dir = getDir _body;
    _currentAnim = animationState
    _body; private ["_weapons","_magazines","_primweapon","_secweapon"];
    _weapons = weapons _body;
    _primweapon = primaryWeapon
    _body; _secweapon = secondaryWeapon _body;
if(!(_primweapon in _weapons) && _primweapon != "") then { _weapons = _weapons + [_primweapon]; };
if(!(_secweapon in _weapons) && _secweapon != "") then { _weapons = _weapons + [_secweapon]; };
    _magazines = magazines _body;
private ["_newBackpackType","_backpackWpn","_backpackMag"]; dayz_myBackpack = unitBackpack _body;
    _newBackpackType = (typeOf dayz_myBackpack);
if(_newBackpackType != "") then { _backpackWpn = getWeaponCargo unitBackpack _body;
    _backpackMag = getMagazineCargo unitBackpack _body; };
    _currentWpn = currentWeapon _body;
    _muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");
if (count _muzzles > 1) then { _currentWpn = currentMuzzle _body; };
        diag_log "Attempting to switch model";
        diag_log str(_weapons);
        diag_log str(_magazines);
        diag_log (str(_backpackWpn));
        diag_log (str(_backpackMag));
    _body setPosATL dayz_spawnPos;
    _oldUnit = _body;
    _group = createGroup west;
	_newUnit = _group createUnit [_class,position player,[],0,"NONE"];
    _newUnit setPosATL _position;
    _newUnit setDir _dir; {_newUnit removeMagazine _x;} forEach magazines _newUnit;
    removeAllWeapons _newUnit; {
if (typeName _x == "ARRAY") then {_newUnit addMagazine [_x select 0,_x select 1]
    } else { _newUnit addMagazine _x };
    } forEach _magazines; { _newUnit addWeapon _x; } forEach _weapons;
if(str(_weapons) != str(weapons _newUnit)) then { { _weapons = _weapons - [_x];
    } forEach (weapons _newUnit); {
    _newUnit addWeapon _x;
    } forEach _weapons; };
if(_primweapon != (primaryWeapon _newUnit)) then { _newUnit addWeapon _primweapon; };
if(_secweapon != (secondaryWeapon _newUnit) && _secweapon != "") then { _newUnit addWeapon _secweapon; };
if (!isNil "_newBackpackType") then {
if (_newBackpackType != "") then { _newUnit addBackpack _newBackpackType;
    _oldBackpack = dayz_myBackpack; dayz_myBackpack = unitBackpack _newUnit; _backpackWpnTypes = [];
    _backpackWpnQtys = [];
if (count _backpackWpn > 0) then { _backpackWpnTypes = _backpackWpn select 0;
    _backpackWpnQtys = _backpackWpn select 1; };
    _countr = 0; { dayz_myBackpack addWeaponCargoGlobal [_x,(_backpackWpnQtys select _countr)];
    _countr = _countr + 1;
    } forEach _backpackWpnTypes;
    _backpackmagTypes = [];
    _backpackmagQtys = [];
if (count _backpackmag > 0) then { _backpackmagTypes =
    _backpackMag select 0;
    _backpackmagQtys = _backpackMag select 1; };
    _countr = 0; { dayz_myBackpack addmagazineCargoGlobal [_x,(_backpackmagQtys select _countr)];
    _countr = _countr + 1;
    } forEach _backpackmagTypes; }; };
        diag_log "Taking Clothes. Equipment:";
        diag_log str(weapons _newUnit); diag_log str(magazines _newUnit);
        diag_log str(getWeaponCargo unitBackpack _newUnit);
        diag_log str(getMagazineCargo unitBackpack _newUnit);
    removeAllWeapons _oldUnit; {_oldUnit removeMagazine _x;
    } forEach magazines _oldUnit; deleteVehicle _oldUnit;
    _newUnit setDamage 1;
    _newUnit setVariable["bodyName",_name,true];
    _newUnit setVariable["deathType",_method,true];
    } else {
        cutText ["You need a free slot to take clothing.", "PLAIN DOWN"];
    };
};