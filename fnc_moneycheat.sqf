//paste below code into debug to use this cheat it will give you 1 mil

if (isServer) then { 
    { 
        private _player = _x; 
        private _playerUID = getPlayerUID _player; 
        private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0]; 
        _cashMoney = _cashMoney + 99999; 
        profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney]; 
        saveProfileNamespace; 
        [format ["<t size='0.7' color='#00ff00'>You have received <t color='#FFFFFF'>$999,999</t></t>", _cashMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
    } forEach allPlayers; 
};
