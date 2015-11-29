/*
 * Author: BaerMitUmlaut
 * Deploy ropes from the helicopter.
 *
 * Arguments:
 * 0: Unit occupying the helicopter <OBJECT>
 * 1: The helicopter itself <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, _vehicle] call ace_fastroping_deployRopes
 *
 * Public: No
 */

#include "script_component.hpp"
params ["_unit", "_vehicle"];
private ["_config", "_waitTime"];

_config = configFile >> "CfgVehicles" >> typeOf _vehicle;
_waitTime = 0;
if (isText (_config >> QGVAR(onDeploy))) then {
    _waitTime = [_vehicle] call (missionNamespace getVariable (getText (_config >> QGVAR(onDeploy))));
};

[{
    params ["_vehicle", "_config"];
    private ["_ropeOrigins", "_deployedRopes", "_hookAttachment", "_origin", "_dummy", "_anchor", "_hook", "_ropeTop", "_ropeBottom"];

    _ropeOrigins = getArray (_config >> QGVAR(ropeOrigins));
    _deployedRopes = [];
    _hookAttachment = _vehicle getVariable [QGVAR(FRIES), _vehicle];
    {
        _hook = QGVAR(helper) createVehicle [0, 0, 0];
        _hook allowDamage false;
        if (typeName _x == "ARRAY") then {
            _hook attachTo [_hookAttachment, _x];
        } else {
            _hook attachTo [_hookAttachment, [0, 0, 0], _x];
        };

        _origin = getPosASL _hook;

        _dummy = QGVAR(helper) createVehicle [0, 0, 0];
        _dummy allowDamage false;
        _dummy setPosASL (_origin vectorAdd [0, 0, -1]);

        _anchor = QGVAR(helper) createVehicle [0, 0, 0];
        _anchor allowDamage false;
        _anchor setPosASL (_origin vectorAdd [0, 0, -2.5]);

        _ropeTop = ropeCreate [_dummy, [0, 0, 0], _hook, [0, 0, 0], 1];
        _ropeBottom = ropeCreate [_dummy, [0, 0, 0], _anchor, [0, 0, 0], 34];

        _ropeTop addEventHandler ["RopeBreak", {[_this, "top"] call FUNC(onRopeBreak)}];
        _ropeBottom addEventHandler ["RopeBreak", {[_this, "bottom"] call FUNC(onRopeBreak)}];

        //deployedRopes format: attachment point, top part of the rope, bottom part of the rope, attachTo helper object, anchor helper object, occupied
        _deployedRopes pushBack [_x, _ropeTop, _ropeBottom, _dummy, _anchor, _hook, false];
        true
    } count _ropeOrigins;

    _vehicle setVariable [QGVAR(deployedRopes), _deployedRopes, true];
}, [_vehicle, _config], _waitTime] call EFUNC(common,waitAndExecute);
