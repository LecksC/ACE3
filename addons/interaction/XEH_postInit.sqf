// by commy2 and esteldunedain

#include "script_component.hpp"

ACE_Modifier = 0;

//SelectLeader Event Handler for BecomeLeader action:
[QGVAR(selectLeader), {
    PARAMS_2(_group,_leader);
    _group selectLeader _leader;
}] call EFUNC(common,addEventHandler);

if (!hasInterface) exitWith {};

GVAR(isOpeningDoor) = false;

// restore global fire teams for JIP
private ["_team"];
{
    _team = _x getVariable [QGVAR(assignedFireTeam), ""];
    if (_team != "") then {_x assignTeam _team};
} forEach allUnits;


["isNotSwimming", {!underwater (_this select 0)}] call EFUNC(common,addCanInteractWithCondition);

#include "keys.sqf"

// reload mutex, you can't play signal while reloading
GVAR(ReloadMutex) = true;

// PFH for Reloading
[{
    if (isNull (findDisplay 46)) exitWith {};
        // handle reloading
        (findDisplay 46) displayAddEventHandler ["KeyDown", {
        if ((_this select 1) in actionKeys "ReloadMagazine") then {
            _weapon = currentWeapon ACE_player;

            if (_weapon != "") then {
                GVAR(ReloadMutex) = false;

                _gesture  = getText (configfile >> "CfgWeapons" >> _this >> "reloadAction");
                _isLauncher = "Launcher" in ([configFile >> "CfgWeapons" >> _this, true] call BIS_fnc_returnParents);
                _config = if (_isLauncher) then { "CfgMovesMaleSdr" } else { "CfgGesturesMale" };
                _duration = getNumber (configfile >> _config >> "States" >> _gesture >> "speed");

                if (_duration != 0) then {
                    _duration = if (_duration < 0) then { abs _duration } else { 1 / _duration };
                } else {
                    _duration = 3;
                };

                [{GVAR(ReloadMutex) = true;}, [], _duration] call EFUNC(common,waitAndExecute);
            };
        };
        false
        }];
    [_this select 1] call CBA_fnc_removePerFrameHandler;
}, 0,[]] call CBA_fnc_addPerFrameHandler;
