/*
 * Author: Glowbal
 * Loops through a string and filters out object names/variables to assign a value for given variable.
 * Used by moduleAssign* within various parts of the ACE3 project.
 *
 * Arguments:
 * 0: list <STRING>
 * 1: variableName <STRING>
 * 2: value <ANY>
 * 3: Global <BOOL>
 *
 * Return Value:
 * None <NIL>
 *
 * Public: No
 */

#include "script_component.hpp"

private ["_splittedList", "_nilCheckPassedList"];
params ["_list", "_variable", "_setting", "_global"];

if (typeName _list == "STRING") then {
    _splittedList = [_list, ","] call BIS_fnc_splitString;
    _nilCheckPassedList = "";
    {
        _x = [_x] call FUNC(stringRemoveWhiteSpace);
        if !(isnil _x) then {
            if (_nilCheckPassedList == "") then {
                _nilCheckPassedList = _x;
            } else {
                _nilCheckPassedList = _nilCheckPassedList + ","+ _x;
            };
        };
    }foreach _splittedList;

    _list = [] call compile format["[%1]",_nilCheckPassedList];
};

{
    if (!isnil "_x") then {
        if (typeName _x == typeName objNull) then {
            if (local _x) then {
                _x setvariable [_variable, _setting, _global];
            };
        };
    };
}foreach _list;

true
