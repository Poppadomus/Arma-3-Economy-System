TER_fnc_handlePayment = {     
    params ["_price"];     
    private _playerUID = getPlayerUID player;     
    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
         
    if (_bankMoney >= _price) then {     
        _bankMoney = _bankMoney - _price;     
        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
        saveProfileNamespace;     
        true     
    } else {     
        false     
    };     
};    
    
    
missionNamespace setVariable ["TER_VASS_paymentHandler", TER_fnc_handlePayment];    
    
    
if (isServer) then {     
    {     
        if (isNil {profileNamespace getVariable (getPlayerUID _x + "_bankMoney")}) then {     
            profileNamespace setVariable [getPlayerUID _x + "_bankMoney", 0];     
            profileNamespace setVariable [getPlayerUID _x + "_cashMoney", 500];     
            saveProfileNamespace;     
        };     
    } forEach allPlayers;     
     
    [] spawn {     
        while {true} do {     
            {     
                private _playerUID = getPlayerUID _x;     
                private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
                _bankMoney = _bankMoney + 100;     
                profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
                saveProfileNamespace;     
                ["<t size='0.7' color='#00ff00'>Welfare Check: <t color='#FFFFFF'>$100</t> has been deposited into your account</t>", -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _x];     
            } forEach allPlayers;     
            sleep 60;     
        };     
    };     
};     
     
private _atmModels = [     
    "Land_Atm_01_F",     
    "Land_Atm_02_F",     
    "Land_ATM_01_malden_F",     
    "Land_ATM_02_malden_F"     
];     
     
fnc_updateClientDisplay = {     
    params ["_cash", "_bank"];     
    private _display = findDisplay -1;     
    if (!isNull _display) then {     
        (_display displayCtrl 3) ctrlSetText format["Cash: $%1", _cash];     
        (_display displayCtrl 4) ctrlSetText format["Bank: $%1", _bank];     
    };     
};     
     
{     
    {     
        _x addAction ["<t color='#FFD700'>Use ATM</t>", {     
            createDialog "RscDisplayEmpty";     
            private _display = findDisplay -1;     
            private _bg = _display ctrlCreate ["RscText", 1];     
            _bg ctrlSetPosition [0.35, 0.2, 0.3, 0.5];     
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];     
            _bg ctrlCommit 0;     
            private _title = _display ctrlCreate ["RscText", 2];     
            _title ctrlSetText "ATM Menu";     
            _title ctrlSetPosition [0.35, 0.2, 0.3, 0.05];     
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];     
            _title ctrlSetTextColor [1, 1, 1, 1];     
            _title ctrlCommit 0;     
            private _cashText = _display ctrlCreate ["RscText", 3];     
            _cashText ctrlSetPosition [0.375, 0.26, 0.25, 0.05];     
            _cashText ctrlSetTextColor [0, 1, 0, 1];     
            _cashText ctrlSetText format["Cash: $%1", profileNamespace getVariable [(getPlayerUID player) + "_cashMoney", 0]];     
            _cashText ctrlCommit 0;     
            private _bankText = _display ctrlCreate ["RscText", 4];     
            _bankText ctrlSetPosition [0.375, 0.31, 0.25, 0.05];     
            _bankText ctrlSetTextColor [0, 0.8, 1, 1];     
            _bankText ctrlSetText format["Bank: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];     
            _bankText ctrlCommit 0;     
            private _amountInput = _display ctrlCreate ["RscEdit", 5];     
            _amountInput ctrlSetPosition [0.375, 0.37, 0.25, 0.05];     
            _amountInput ctrlSetText "100";     
            _amountInput ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];     
            _amountInput ctrlCommit 0;     
            private _depositBtn = _display ctrlCreate ["RscButton", 6];     
            _depositBtn ctrlSetText "Deposit";     
            _depositBtn ctrlSetPosition [0.375, 0.44, 0.25, 0.05];     
            _depositBtn ctrlSetTextColor [0, 1, 0, 1];     
            _depositBtn ctrlCommit 0;     
            _depositBtn ctrlAddEventHandler ["ButtonClick", {     
                params ["_ctrl"];     
                private _display = ctrlParent _ctrl;     
                private _amount = parseNumber ctrlText (_display displayCtrl 5);     
                if (_amount > 0) then {     
                    [player, _amount, _display] remoteExec ["fnc_atmDeposit", 2];     
                } else {     
                    hint "Please enter a valid amount.";     
                };     
            }];     
            private _withdrawBtn = _display ctrlCreate ["RscButton", 7];     
            _withdrawBtn ctrlSetText "Withdraw";     
            _withdrawBtn ctrlSetPosition [0.375, 0.51, 0.25, 0.05];     
            _withdrawBtn ctrlSetTextColor [1, 0.5, 0, 1];     
            _withdrawBtn ctrlCommit 0;     
            _withdrawBtn ctrlAddEventHandler ["ButtonClick", {     
                params ["_ctrl"];     
                private _display = ctrlParent _ctrl;     
                private _amount = parseNumber ctrlText (_display displayCtrl 5);     
                if (_amount > 0) then {     
                    [player, _amount, _display] remoteExec ["fnc_atmWithdraw", 2];     
                } else {     
                    hint "Please enter a valid amount.";     
                };     
            }];     
            private _closeBtn = _display ctrlCreate ["RscButton", 8];     
            _closeBtn ctrlSetText "Close";     
            _closeBtn ctrlSetPosition [0.375, 0.58, 0.25, 0.05];     
            _closeBtn ctrlSetTextColor [1, 0, 0, 1];     
            _closeBtn ctrlCommit 0;     
            _closeBtn ctrlAddEventHandler ["ButtonClick", {     
                closeDialog 0;     
            }];     
        }, [], 1.5, true, true, "", "", 3];     
    } forEach (allMissionObjects _x);     
} forEach _atmModels;     
     
if (isServer) then {     
    fnc_atmDeposit = {     
        params ["_player", "_amount", "_display"];     
        private _playerUID = getPlayerUID _player;     
        private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];     
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
             
        if (_cashMoney >= _amount) then {     
            _cashMoney = _cashMoney - _amount;     
            _bankMoney = _bankMoney + _amount;     
            profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];     
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
            saveProfileNamespace;     
            [format ["<t size='0.7' color='#00ff00'>Deposited <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t> | Cash: <t color='#FFFFFF'>$%3</t></t>", _amount, _bankMoney, _cashMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
            [_cashMoney, _bankMoney] remoteExec ["fnc_updateClientDisplay", _player];     
        } else {     
            ["<t size='0.7' color='#ff0000'>Not enough cash on hand!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        };     
    };     
     
    fnc_atmWithdraw = {     
        params ["_player", "_amount", "_display"];     
        private _playerUID = getPlayerUID _player;     
        private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];     
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
             
        if (_bankMoney >= _amount) then {     
            _bankMoney = _bankMoney - _amount;     
            _cashMoney = _cashMoney + _amount;     
            profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];     
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
            saveProfileNamespace;     
            [format ["<t size='0.7' color='#ffa500'>Withdrew <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t> | Cash: <t color='#FFFFFF'>$%3</t></t>", _amount, _bankMoney, _cashMoney], -1, 0.90, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
            [_cashMoney, _bankMoney] remoteExec ["fnc_updateClientDisplay", _player];     
        } else {     
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        };     
    };     
         
    publicVariable "fnc_atmDeposit";     
    publicVariable "fnc_atmWithdraw";     
    publicVariable "fnc_updateClientDisplay";     
};     
{     
    _x addAction ["<t color='#FFD700'>Vehicle Shop</t>", {     
        private _vehicles = [     
            ["C_Truck_02_covered_F", "Covered Truck", 450000],     
            ["C_Truck_02_transport_F", "Transport Truck", 375000],     
            ["C_Truck_02_box_F", "Box Truck", 525000],     
            ["C_Truck_02_fuel_F", "Fuel Truck", 400000],     
            ["C_Van_01_box_F", "Box Van", 275000],     
            ["C_Van_01_transport_F", "Transport Van", 225000],     
            ["C_SUV_01_F", "SUV", 175000],     
            ["C_Quadbike_01_F", "Quadbike", 25000],     
            ["C_Offroad_01_F", "Offroad", 125000],     
            ["C_Hatchback_01_F", "Hatchback", 100],     
            ["C_Hatchback_01_sport_F", "Sport Hatchback", 150000],     
            ["C_Van_01_fuel_F", "Fuel Van", 325000]     
        ];     
             
        createDialog "RscDisplayEmpty";     
        private _display = findDisplay -1;     
             
        private _bg = _display ctrlCreate ["RscText", 1];     
        _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6];     
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];     
        _bg ctrlCommit 0;     
             
        private _title = _display ctrlCreate ["RscText", 2];     
        _title ctrlSetText "Vehicle Shop";     
        _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];     
        _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];     
        _title ctrlSetTextColor [1, 1, 1, 1];     
        _title ctrlCommit 0;     
     
        private _bankText = _display ctrlCreate ["RscText", 3];     
        _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];     
        _bankText ctrlSetTextColor [0, 1, 0, 1];     
        _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];     
        _bankText ctrlCommit 0;     
     
        private _listBox = _display ctrlCreate ["RscListBox", 4];     
        _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3];     
        _listBox ctrlCommit 0;     
     
        {     
            _x params ["_class", "_name", "_price"];     
            private _index = _listBox lbAdd format["%1 - $%2", _name, _price];     
            _listBox lbSetData [_index, _class];     
            _listBox lbSetValue [_index, _price];     
            _listBox lbSetPictureRight [_index, getText (configFile >> "CfgVehicles" >> _class >> "picture")];     
            _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]];     
        } forEach _vehicles;     
             
        private _buyBtn = _display ctrlCreate ["RscButton", 5];     
        _buyBtn ctrlSetText "Purchase Vehicle";     
        _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05];     
        _buyBtn ctrlSetTextColor [0, 1, 0, 1];     
        _buyBtn ctrlCommit 0;     
             
        _buyBtn ctrlAddEventHandler ["ButtonClick", {     
            params ["_ctrl"];     
            private _display = ctrlParent _ctrl;     
            private _listBox = _display displayCtrl 4;     
            private _selectedIndex = lbCurSel _listBox;     
                 
            if (_selectedIndex != -1) then {     
                private _vehicleClass = _listBox lbData _selectedIndex;     
                private _price = _listBox lbValue _selectedIndex;     
                [player, _vehicleClass, _price] remoteExec ["fnc_purchaseVehicle", 2];     
            };     
        }];     
             
        private _closeBtn = _display ctrlCreate ["RscButton", 6];     
        _closeBtn ctrlSetText "Close";     
        _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05];     
        _closeBtn ctrlSetTextColor [1, 0, 0, 1];     
        _closeBtn ctrlCommit 0;     
             
        _closeBtn ctrlAddEventHandler ["ButtonClick", {     
            closeDialog 0;     
        }];     
    }, [], 1.5, true, true, "", "", 3];     
} forEach (allMissionObjects "O_Soldier_VR_F");     
     
if (isServer) then {     
    fnc_purchaseVehicle = {     
        params ["_player", "_vehicleClass", "_price"];     
        private _playerUID = getPlayerUID _player;     
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
             
        if (_bankMoney >= _price) then {     
            private _spawnPos = [];     
            private _helipads = nearestObjects [position _player, ["Land_HelipadSquare_F"], 100];     
                 
            {     
                private _padPos = getPos _x;     
                private _nearVehicles = _padPos nearEntities ["AllVehicles", 5];     
                if (count _nearVehicles == 0) exitWith {     
                    _spawnPos = _padPos;     
                };     
            } forEach _helipads;     
                 
            if (count _spawnPos > 0) then {     
                _bankMoney = _bankMoney - _price;     
                profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
                saveProfileNamespace;     
                     
                private _vehicle = createVehicle [_vehicleClass, _spawnPos, [], 0, "NONE"];     
                _vehicle setDir (getDir (_helipads select 0));     
                     
                [format ["<t size='0.7' color='#00ff00'>Vehicle purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
            } else {     
                ["<t size='0.7' color='#ff0000'>No available spawn points!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
            };     
        } else {     
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        };     
    };     
         
    publicVariable "fnc_purchaseVehicle";     
};    
if (isNil "g_weaponsList") then {     
    g_weaponsList = [     
        ["hgun_Rook40_F", "Rook-40 9mm", 1500, ["16Rnd_9x21_Mag"]]     
    ];     
};     
     
{
    _x addAction ["<t color='#FFD700'>Pistol Shop</t>", {
        private _weapons = [
            ["hgun_Rook40_F", "Rook-40 9mm", 1500, ["16Rnd_9x21_Mag"]],
            ["hgun_Pistol_heavy_01_F", "4-Five", 2000, ["11Rnd_45ACP_Mag"]],
            ["hgun_ACPC2_F", "ACP-C2", 1800, ["9Rnd_45ACP_Mag"]],
            ["hgun_P07_F", "P07", 1200, ["16Rnd_9x21_Mag"]],
            ["hgun_Pistol_heavy_02_F", "Zubr", 2500, ["6Rnd_45ACP_Cylinder"]]
        ];
        
        private _mags = [
            ["16Rnd_9x21_Mag", "9mm Mag", 150],
            ["30Rnd_9x21_Mag", "9mm Mag (30)", 300],
            ["11Rnd_45ACP_Mag", "45ACP Mag", 200],
            ["9Rnd_45ACP_Mag", "45ACP Mag (9)", 180],
            ["6Rnd_45ACP_Cylinder", "45ACP Cylinder", 300]
        ];

        createDialog "RscDisplayEmpty";
        private _display = findDisplay -1;

        private _bg = _display ctrlCreate ["RscText", 1];
        _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.7];
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];
        _bg ctrlCommit 0;

        private _title = _display ctrlCreate ["RscText", 2];
        _title ctrlSetText "Weapon Shop";
        _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];
        _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];
        _title ctrlSetTextColor [1, 1, 1, 1];
        _title ctrlCommit 0;

        private _bankText = _display ctrlCreate ["RscText", 3];
        _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];
        _bankText ctrlSetTextColor [0, 1, 0, 1];
        _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];
        _bankText ctrlCommit 0;

        private _listBox = _display ctrlCreate ["RscListBox", 4];
        _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.2];
        _listBox ctrlCommit 0;

        {
            _x params ["_class", "_name", "_price"];
            private _index = _listBox lbAdd format["%1 - $%2", _name, _price];
            _listBox lbSetData [_index, _class];
            _listBox lbSetValue [_index, _price];
            _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")];
            _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]];
        } forEach _weapons;

        private _buyBtn = _display ctrlCreate ["RscButton", 5];
        _buyBtn ctrlSetText "Purchase Weapon";
        _buyBtn ctrlSetPosition [0.325, 0.53, 0.16, 0.05];
        _buyBtn ctrlSetTextColor [0, 1, 0, 1];
        _buyBtn ctrlCommit 0;

        _buyBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _listBox = _display displayCtrl 4;
            private _selectedIndex = lbCurSel _listBox;
            if (_selectedIndex != -1) then {
                private _weaponClass = _listBox lbData _selectedIndex;
                private _price = _listBox lbValue _selectedIndex;
                [player, _weaponClass, _price] remoteExec ["fnc_purchaseWeapon", 2];
            };
        }];

        private _sellBtn = _display ctrlCreate ["RscButton", 10];
        _sellBtn ctrlSetText "Sell Weapon";
        _sellBtn ctrlSetPosition [0.495, 0.53, 0.16, 0.05];
        _sellBtn ctrlSetTextColor [1, 0.5, 0, 1];
        _sellBtn ctrlCommit 0;

        _sellBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _player = player;
            private _currentWeapon = currentWeapon _player;
            if (_currentWeapon != "") then {
                private _weaponInfo = _weapons findIf { (_x select 0) isEqualTo _currentWeapon };
                if (_weaponInfo != -1) then {
                    private _salePrice = (_weapons select _weaponInfo) select 2;
                    _salePrice = _salePrice / 2;
                    private _playerUID = getPlayerUID _player;
                    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
                    _player removeWeapon _currentWeapon;
                    {
                        if (_x in (magazines _player)) then {
                            _player removeMagazine _x;
                        };
                    } forEach (getArray (configFile >> "CfgWeapons" >> _currentWeapon >> "magazines"));
                    _bankMoney = _bankMoney + _salePrice;
                    profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
                    saveProfileNamespace;
                    [format ["<t size='0.7' color='#00ff00'>Weapon sold for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _salePrice, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
                } else {
                    ["<t size='0.7' color='#ff0000'>This weapon is not for sale here!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
                };
            } else {
                ["<t size='0.7' color='#ff0000'>You have no weapon to sell!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
            };
        }];

        private _magSection = _display ctrlCreate ["RscText", 7];
        _magSection ctrlSetText "Magazines";
        _magSection ctrlSetPosition [0.3, 0.59, 0.4, 0.05];
        _magSection ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];
        _magSection ctrlSetTextColor [1, 1, 1, 1];
        _magSection ctrlCommit 0;

        private _magListBox = _display ctrlCreate ["RscListBox", 8];
        _magListBox ctrlSetPosition [0.325, 0.65, 0.35, 0.2];
        _magListBox ctrlCommit 0;

        {
            _x params ["_magClass", "_magName", "_magPrice"];
            private _magIndex = _magListBox lbAdd format["%1 - $%2", _magName, _magPrice];
            _magListBox lbSetData [_magIndex, _magClass];
            _magListBox lbSetValue [_magIndex, _magPrice];
            _magListBox lbSetPictureRight [_magIndex, getText (configFile >> "CfgMagazines" >> _magClass >> "picture")];
            _magListBox lbSetPictureRightColor [_magIndex, [1, 1, 1, 1]];
        } forEach _mags;

        private _buyMagBtn = _display ctrlCreate ["RscButton", 9];
        _buyMagBtn ctrlSetText "Buy Mag";
        _buyMagBtn ctrlSetPosition [0.325, 0.86, 0.16, 0.05];
        _buyMagBtn ctrlSetTextColor [0, 1, 0, 1];
        _buyMagBtn ctrlCommit 0;

        _buyMagBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _magListBox = _display displayCtrl 8;
            private _selectedMagIndex = lbCurSel _magListBox;
            if (_selectedMagIndex != -1) then {
                private _magClass = _magListBox lbData _selectedMagIndex;
                private _magPrice = _magListBox lbValue _selectedMagIndex;
                [player, _magClass, _magPrice] remoteExec ["fnc_purchaseMag", 2];
            };
        }];

        private _closeBtn = _display ctrlCreate ["RscButton", 6];
        _closeBtn ctrlSetText "Close";
        _closeBtn ctrlSetPosition [0.515, 0.86, 0.16, 0.05];
        _closeBtn ctrlSetTextColor [1, 0, 0, 1];
        _closeBtn ctrlCommit 0;

        _closeBtn ctrlAddEventHandler ["ButtonClick", {
            closeDialog 0;
        }];
    }, [], 1.5, true, true, "", "", 3];
} forEach (allMissionObjects "I_Soldier_VR_F");

if (isServer) then {
    fnc_purchaseWeapon = {
        params ["_player", "_weaponClass", "_price"];
        private _playerUID = getPlayerUID _player;
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
        if (_bankMoney >= _price) then {
            private _currentWeapon = currentWeapon _player;
            if (_currentWeapon != "") then {
                _player removeWeapon _currentWeapon;
                {
                    if (_x in (magazines _player)) then {
                        _player removeMagazine _x;
                    };
                } forEach (getArray (configFile >> "CfgWeapons" >> _currentWeapon >> "magazines"));
            };
            _player addWeapon _weaponClass;
            private _magazineClass = getArray (configFile >> "CfgWeapons" >> _weaponClass >> "magazines") select 0;
            for "_i" from 1 to 3 do {
                _player addMagazine _magazineClass;
            };
            _bankMoney = _bankMoney - _price;
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
            saveProfileNamespace;
            [format ["<t size='0.7' color='#00ff00'>Weapon purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        } else {
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        };
    };

    fnc_purchaseMag = {
        params ["_player", "_magClass", "_price"];
        private _playerUID = getPlayerUID _player;
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
        if (_bankMoney >= _price) then {
            _player addMagazine _magClass;
            _bankMoney = _bankMoney - _price;
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
            saveProfileNamespace;
            [format ["<t size='0.7' color='#00ff00'>Magazine purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        } else {
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        };
    };

    publicVariable "fnc_purchaseWeapon";
    publicVariable "fnc_purchaseMag";
};

{     
    _x addAction [     
        "<t color='#FFD700'>Vest Shop</t>",     
        {     
			private _vests = [
				["V_PlateCarrierGL_blk", "Black Plate Carrier GL", 500],
				["V_PlateCarrierGL_rgr", "Green Plate Carrier GL", 500],
				["V_PlateCarrierGL_mtp", "MTP Plate Carrier GL", 500],
				["V_PlateCarrierGL_tna_F", "Tropic Plate Carrier GL", 500],
				["V_PlateCarrierGL_wdl", "Woodland Plate Carrier GL", 500],
				["V_PlateCarrier1_blk", "Black Plate Carrier Lite", 400],
				["V_PlateCarrier1_rgr", "Green Plate Carrier Lite", 400],
				["V_PlateCarrier1_rgr_noflag_F", "Green Plate Carrier Lite (No Flag)", 400],
				["V_PlateCarrier1_tna_F", "Tropic Plate Carrier Lite", 400],
				["V_PlateCarrier1_wdl", "Woodland Plate Carrier Lite", 400],
				["V_PlateCarrier2_blk", "Black Plate Carrier", 450],
				["V_PlateCarrier2_rgr", "Green Plate Carrier", 450],
				["V_PlateCarrier2_rgr_noflag_F", "Green Plate Carrier (No Flag)", 450],
				["V_PlateCarrier2_wdl", "Woodland Plate Carrier", 450],
				["V_PlateCarrierSpec_blk", "Black Plate Carrier Special", 600],
				["V_PlateCarrierSpec_rgr", "Green Plate Carrier Special", 600],
				["V_PlateCarrierSpec_mtp", "MTP Plate Carrier Special", 600],
				["V_PlateCarrierSpec_tna_F", "Tropic Plate Carrier Special", 600],
				["V_PlateCarrierSpec_wdl", "Woodland Plate Carrier Special", 600],
				["V_Chestrig_blk", "Black Chest Rig", 300],
				["V_Chestrig_rgr", "Green Chest Rig", 300],
				["V_Chestrig_khk", "Khaki Chest Rig", 300],
				["V_Chestrig_oli", "Olive Chest Rig", 300],
				["V_PlateCarrierL_CTRG", "CTRG Plate Carrier Lite", 400],
				["V_PlateCarrierH_CTRG", "CTRG Plate Carrier Heavy", 500],
				["V_DeckCrew_blue_F", "Blue Deck Crew", 200],
				["V_DeckCrew_brown_F", "Brown Deck Crew", 200],
				["V_DeckCrew_green_F", "Green Deck Crew", 200],
				["V_DeckCrew_red_F", "Red Deck Crew", 200],
				["V_DeckCrew_violet_F", "Violet Deck Crew", 200],
				["V_DeckCrew_white_F", "White Deck Crew", 200],
				["V_DeckCrew_yellow_F", "Yellow Deck Crew", 200],
				["V_EOD_blue_F", "Blue EOD Vest", 400],
				["V_EOD_IDAP_blue_F", "IDAP Blue EOD Vest", 400],
				["V_EOD_coyote_F", "Coyote EOD Vest", 400],
				["V_EOD_olive_F", "Olive EOD Vest", 400],
				["V_PlateCarrierIAGL_dgtl", "Digital IAGL Plate Carrier", 500],
				["V_PlateCarrierIAGL_oli", "Olive IAGL Plate Carrier", 500],
				["V_PlateCarrierIA1_dgtl", "Digital IA1 Plate Carrier", 400],
				["V_PlateCarrierIA2_dgtl", "Digital IA2 Plate Carrier", 450],
				["V_TacVest_gen_F", "Gendarmerie Tactical Vest", 300],
				["V_Plain_crystal_F", "Crystal Plain Vest", 200],
				["V_Plain_medical_F", "Medical Plain Vest", 200],
				["V_SmershVest_01_F", "Smersh Vest", 350],
				["V_SmershVest_01_radio_F", "Smersh Vest with Radio", 400],
				["V_HarnessOGL_brn", "Brown OGL Harness", 250],
				["V_HarnessOGL_ghex_F", "Green Hex OGL Harness", 250],
				["V_HarnessOGL_gry", "Grey OGL Harness", 250],
				["V_HarnessO_brn", "Brown Harness", 200],
				["V_HarnessO_ghex_F", "Green Hex Harness", 200],
				["V_HarnessO_gry", "Grey Harness", 200],
				["V_LegStrapBag_black_F", "Black Leg Strap Bag", 150],
				["V_LegStrapBag_coyote_F", "Coyote Leg Strap Bag", 150],
				["V_LegStrapBag_olive_F", "Olive Leg Strap Bag", 150],
				["V_CarrierRigKBT_01_heavy_EAF_F", "EAF Heavy Carrier Rig", 500],
				["V_CarrierRigKBT_01_heavy_olive_F", "Olive Heavy Carrier Rig", 500],
				["V_CarrierRigKBT_01_light_EAF_F", "EAF Light Carrier Rig", 400],
				["V_CarrierRigKBT_01_light_olive_F", "Olive Light Carrier Rig", 400],
				["V_CarrierRigKBT_01_EAF_F", "EAF Carrier Rig", 450],
				["V_CarrierRigKBT_01_olive_F", "Olive Carrier Rig", 450],
				["V_Pocketed_black_F", "Black Pocketed Vest", 200],
				["V_Pocketed_coyote_F", "Coyote Pocketed Vest", 200],
				["V_Pocketed_olive_F", "Olive Pocketed Vest", 200],
				["V_Rangemaster_belt", "Rangemaster Belt", 100],
				["V_TacVestIR_blk", "Black IR Tactical Vest", 350],
				["V_RebreatherIA", "IA Rebreather", 300],
				["V_RebreatherIR", "IR Rebreather", 300],
				["V_RebreatherB", "B Rebreather", 300],
				["V_Safety_blue_F", "Blue Safety Vest", 100],
				["V_Safety_orange_F", "Orange Safety Vest", 100],
				["V_Safety_yellow_F", "Yellow Safety Vest", 100],
				["V_BandollierB_blk", "Black Bandolier", 200],
				["V_BandollierB_cbr", "Coyote Bandolier", 200],
				["V_BandollierB_ghex_F", "Green Hex Bandolier", 200],
				["V_BandollierB_rgr", "Ranger Green Bandolier", 200],
				["V_BandollierB_khk", "Khaki Bandolier", 200],
				["V_BandollierB_oli", "Olive Bandolier", 200],
				["V_TacChestrig_cbr_F", "Coyote Tactical Chest Rig", 250],
				["V_TacChestrig_grn_F", "Green Tactical Chest Rig", 250],
				["V_TacChestrig_oli_F", "Olive Tactical Chest Rig", 250],
				["V_TacVest_blk", "Black Tactical Vest", 300],
				["V_TacVest_brn", "Brown Tactical Vest", 300],
				["V_TacVest_camo", "Camo Tactical Vest", 300],
				["V_TacVest_khk", "Khaki Tactical Vest", 300],
				["V_TacVest_oli", "Olive Tactical Vest", 300],
				["V_TacVest_blk_POLICE", "Police Tactical Vest", 300],
				["V_I_G_resistanceLeader_F", "Resistance Leader Vest", 400],
				["V_PlateCarrier_Kerry", "Kerry Plate Carrier", 450],
				["V_Press_F", "Press Vest", 200]
			];      
     
            createDialog "RscDisplayEmpty";     
            private _display = findDisplay -1;     
     
            private _bg = _display ctrlCreate ["RscText", 1];     
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.5];     
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];     
            _bg ctrlCommit 0;     
     
            private _title = _display ctrlCreate ["RscText", 2];     
            _title ctrlSetText "Vest Shop";     
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];     
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];     
            _title ctrlSetTextColor [1, 1, 1, 1];     
            _title ctrlCommit 0;     
     
            private _bankText = _display ctrlCreate ["RscText", 3];     
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];     
            _bankText ctrlSetTextColor [0, 1, 0, 1];     
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];     
            _bankText ctrlCommit 0;     
     
            private _listBox = _display ctrlCreate ["RscListBox", 4];     
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3];     
            _listBox ctrlCommit 0;     
     
            {     
                _x params ["_class", "_name", "_price"];     
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price];     
                _listBox lbSetData [_index, _class];     
                _listBox lbSetValue [_index, _price];     
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")];     
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]];     
            } forEach _vests;     
     
            private _buyBtn = _display ctrlCreate ["RscButton", 5];     
            _buyBtn ctrlSetText "Purchase Vest";     
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05];     
            _buyBtn ctrlSetTextColor [0, 1, 0, 1];     
            _buyBtn ctrlCommit 0;     
            _buyBtn ctrlAddEventHandler ["ButtonClick", {     
                params ["_ctrl"];     
                private _display = ctrlParent _ctrl;     
                private _listBox = _display displayCtrl 4;     
                private _selectedIndex = lbCurSel _listBox;     
                if (_selectedIndex != -1) then {     
                    private _vestClass = _listBox lbData _selectedIndex;     
                    private _price = _listBox lbValue _selectedIndex;     
                    [player, _vestClass, _price] remoteExec ["fnc_purchaseVest", 2];     
                };     
            }];     
     
            private _closeBtn = _display ctrlCreate ["RscButton", 6];     
            _closeBtn ctrlSetText "Close";     
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05];     
            _closeBtn ctrlSetTextColor [1, 0, 0, 1];     
            _closeBtn ctrlCommit 0;     
            _closeBtn ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];     
        },     
        [],     
        1.5,     
        true,     
        true,     
        "",     
        "",     
        3     
    ];     
} forEach (allMissionObjects "B_Soldier_VR_F");     
     
if (isServer) then {     
    fnc_purchaseVest = {     
        params ["_player", "_vestClass", "_price"];     
        private _playerUID = getPlayerUID _player;     
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
             
        if (_bankMoney >= _price) then {     
            _player addVest _vestClass;     
            _bankMoney = _bankMoney - _price;     
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
            saveProfileNamespace;     
            [format ["<t size='0.7' color='#00ff00'>Vest purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        } else {     
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        };     
    };     
     
    publicVariable "fnc_purchaseVest";     
};    
    
if (isServer) then {    
    commodities = [    
        ["Crack", 100],    
        ["Cocaine", 500],    
        ["Crystal Meth", 50],    
        ["Ecstasy", 200],    
        ["Spice", 80],    
        ["Heroin", 60],    
        ["Cannabis", 120],    
        ["LSD", 40]    
    ];    
    publicVariable "commodities";    
    
    [] spawn {    
        while {true} do {    
            {    
                _x params ["_name", "_price"];    
                private _change = (random 20) - 10;    
                private _newPrice = (_price + _change) max 1;    
                _x set [1, _newPrice];    
            } forEach commodities;    
            publicVariable "commodities";    
            sleep 5;    
        };    
    };    
};    
    
fnc_updateCommodityDisplay = {    
    params ["_display"];    
    if (!isNull _display) then {    
        private _listBox = _display displayCtrl 4;    
        private _bankText = _display displayCtrl 3;    
    
        _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];    
    
        lbClear _listBox;    
        {    
            _x params ["_name", "_price"];    
            private _index = _listBox lbAdd format["%1 - $%2", _name, round _price];    
            _listBox lbSetData [_index, _name];    
            _listBox lbSetValue [_index, round _price];    
        } forEach commodities;    
    };    
};    
    
{    
    _x addAction [    
        "<t color='#FFD700'>Commodity Market</t>",    
        {    
            createDialog "RscDisplayEmpty";    
            private _display = findDisplay -1;    
            private _bg = _display ctrlCreate ["RscText", 1];    
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.7];    
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];    
            _bg ctrlCommit 0;    
            private _title = _display ctrlCreate ["RscText", 2];    
            _title ctrlSetText "Commodity Market";    
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];    
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];    
            _title ctrlSetTextColor [1, 1, 1, 1];    
            _title ctrlCommit 0;    
            private _bankText = _display ctrlCreate ["RscText", 3];    
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];    
            _bankText ctrlSetTextColor [0, 1, 0, 1];    
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];    
            _bankText ctrlCommit 0;    
            private _listBox = _display ctrlCreate ["RscListBox", 4];    
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3];    
            _listBox ctrlCommit 0;    
    
            private _updateHandle = [] spawn {    
                private _display = findDisplay -1;    
                while {!isNull _display} do {    
                    [_display] call fnc_updateCommodityDisplay;    
                    sleep 1;    
                };    
            };    
    
            _display setVariable ["updateHandle", _updateHandle];    
    
            {    
                _x params ["_name", "_price"];    
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price];    
                _listBox lbSetData [_index, _name];    
                _listBox lbSetValue [_index, _price];    
            } forEach commodities;    
    
            private _buyBtn = _display ctrlCreate ["RscButton", 5];    
            _buyBtn ctrlSetText "Buy";    
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.16, 0.05];    
            _buyBtn ctrlSetTextColor [0, 1, 0, 1];    
            _buyBtn ctrlCommit 0;    
    
            _buyBtn ctrlAddEventHandler ["ButtonClick", {    
                params ["_ctrl"];    
                private _display = ctrlParent _ctrl;    
                private _listBox = _display displayCtrl 4;    
                private _selectedIndex = lbCurSel _listBox;    
                if (_selectedIndex != -1) then {    
                    private _commodityName = _listBox lbData _selectedIndex;    
                    private _price = _listBox lbValue _selectedIndex;    
                    private _playerUID = getPlayerUID player;    
                    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];    
                    if (_bankMoney >= _price) then {    
                        _bankMoney = _bankMoney - _price;    
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];    
                        saveProfileNamespace;    
                        private _playerCommodities = profileNamespace getVariable [_playerUID + "_commodities", []];    
                        _playerCommodities pushBack [_commodityName, _price];    
                        profileNamespace setVariable [_playerUID + "_commodities", _playerCommodities];    
                        saveProfileNamespace;    
                        [format ["<t size='0.7' color='#00ff00'>Bought 1 share of %1 for <t color='#FFFFFF'>$%2</t>. Bank Balance: <t color='#FFFFFF'>$%3</t></t>", _commodityName, _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];    
                    } else {    
                        ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];    
                    };    
                };    
            }];    
    
            private _sellBtn = _display ctrlCreate ["RscButton", 10];    
            _sellBtn ctrlSetText "Sell";    
            _sellBtn ctrlSetPosition [0.495, 0.64, 0.16, 0.05];    
            _sellBtn ctrlSetTextColor [1, 0.5, 0, 1];    
            _sellBtn ctrlCommit 0;    
    
            _sellBtn ctrlAddEventHandler ["ButtonClick", {    
                params ["_ctrl"];    
                private _display = ctrlParent _ctrl;    
                private _listBox = _display displayCtrl 4;    
                private _selectedIndex = lbCurSel _listBox;    
                if (_selectedIndex != -1) then {    
                    private _commodityName = _listBox lbData _selectedIndex;    
                    private _price = _listBox lbValue _selectedIndex;    
                    private _playerUID = getPlayerUID player;    
                    private _playerCommodities = profileNamespace getVariable [_playerUID + "_commodities", []];    
                    private _index = _playerCommodities findIf {(_x select 0) isEqualTo _commodityName};    
                    if (_index != -1) then {    
                        private _boughtPrice = (_playerCommodities select _index) select 1;    
                        _playerCommodities deleteAt _index;    
                        profileNamespace setVariable [_playerUID + "_commodities", _playerCommodities];    
                        saveProfileNamespace;    
                        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];    
                        _bankMoney = _bankMoney + _price;    
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];    
                        saveProfileNamespace;    
                        [format ["<t size='0.7' color='#00ff00'>Sold 1 share of %1 for <t color='#FFFFFF'>$%2</t>. Bank Balance: <t color='#FFFFFF'>$%3</t></t>", _commodityName, _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];    
                    } else {    
                        ["<t size='0.7' color='#ff0000'>You don't own any shares of this commodity!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];    
                    };    
                };    
            }];    
    
            private _closeBtn = _display ctrlCreate ["RscButton", 6];    
            _closeBtn ctrlSetText "Close";    
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05];    
            _closeBtn ctrlSetTextColor [1, 0, 0, 1];    
            _closeBtn ctrlCommit 0;    
    
            _closeBtn ctrlAddEventHandler ["ButtonClick", {    
                params ["_ctrl"];    
                private _display = ctrlParent _ctrl;    
                terminate (_display getVariable "updateHandle");    
                closeDialog 0;    
            }];    
        },    
        [],    
        1.5,    
        true,    
        true,    
        "",    
        "",    
        3    
    ];    
} forEach (allMissionObjects "C_Soldier_VR_F");    
    
fnc_floatingKillText = {    
    params ["_text", "_startX", "_startY", "_moveX", "_moveY", "_duration"];    
    private _display = findDisplay 46;    
    private _ctrl = _display ctrlCreate ["RscStructuredText", -1];    
        
    _ctrl ctrlSetPosition [_startX, _startY, 0.4, 0.1];    
    _ctrl ctrlSetStructuredText parseText _text;    
    _ctrl ctrlSetFade 0;    
    _ctrl ctrlCommit 0;    
        
    private _startTime = diag_tickTime;    
    private _pos = ctrlPosition _ctrl;    
        
    while {diag_tickTime - _startTime < _duration} do {    
        _pos set [0, (_pos select 0) + (_moveX * (diag_tickTime - _startTime) / _duration)];    
        _pos set [1, (_pos select 1) + (_moveY * (diag_tickTime - _startTime) / _duration)];    
        _ctrl ctrlSetPosition _pos;    
        _ctrl ctrlCommit 0;    
        sleep 0.01;    
    };    
        
    _ctrl ctrlSetFade 1;    
    _ctrl ctrlCommit 1;    
        
    sleep 1;    
    ctrlDelete _ctrl;    
};    
    
if (hasInterface) then {  
    addMissionEventHandler ["EntityKilled", {  
        params ["_killed", "_killer", "_instigator"];  
        if (isNull _instigator) then {  
            _instigator = _killer;  
        };  
  
        if (isPlayer _killer && _killed isKindOf "CAManBase") then {  
            private _distance = _killer distance2D _killed;  
            private _killed_Name = "";  
                
            if (!(isPlayer _killed)) then {  
                _killed_Name = getText(configFile >> "CfgVehicles" >> format["%1", typeOf _killed] >> "Displayname");  
            } else {  
                _killed_Name = name _killed;  
            };  
  
            private _playerUID = getPlayerUID _killer;  
            private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];  
            _cashMoney = _cashMoney + 100;  
            profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];  
            saveProfileNamespace;  
  
            private _sideColor = switch (true) do {  
                case (side group _killed == west): { "#0000FF" };  
                case (side group _killed == east): { "#FF0000" };  
                case (side group _killed == independent): { "#00FF00" };  
                default { "#FF00FF" };  
            };  
  
            private _kill_HUD = format["<t size='0.8' color='#FFFFFF' align='right'><t color='%1'>%2</t> Eliminated (<t color='#00FFFF'>%3m</t>) | <t color='#00FF00'>$%4</t></t>", _sideColor, _killed_Name, floor _distance, 100];  
                
            [_kill_HUD, safezoneX + (safezoneW / 2) - 0.05, safezoneY + (safezoneH / 2) - 0.05, 0, 0.005, 5] remoteExec ["fnc_floatingKillText", owner _killer];  
                
            playSound "TaskSucceeded";  
        };  
    }];  
};

{ 
    _x addAction [ 
        "<t color='#FFD700'>Equipment Shop</t>", 
        { 
            private _equipment = [ 
                ["H_HelmetB", "Combat Helmet", 300], 
                ["H_HelmetSpecB", "Enhanced Combat Helmet", 500], 
                ["H_HelmetB_light", "Light Combat Helmet", 250], 
                ["H_HelmetB_black", "Black Combat Helmet", 350], 
                ["NVGoggles", "Night Vision Goggles", 1000], 
                ["NVGoggles_OPFOR", "Advanced NVGs", 1500], 
                ["NVGoggles_INDEP", "Combat NVGs", 1200], 
                ["G_Balaclava_blk", "Black Balaclava", 100], 
                ["G_Balaclava_oli", "Olive Balaclava", 100], 
                ["G_Balaclava_combat", "Combat Balaclava", 150] 
            ]; 
            createDialog "RscDisplayEmpty"; 
            private _display = findDisplay -1; 
            private _bg = _display ctrlCreate ["RscText", 1]; 
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6]; 
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7]; 
            _bg ctrlCommit 0; 
            private _title = _display ctrlCreate ["RscText", 2]; 
            _title ctrlSetText "Equipment Shop"; 
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05]; 
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1]; 
            _title ctrlSetTextColor [1, 1, 1, 1]; 
            _title ctrlCommit 0; 
            private _bankText = _display ctrlCreate ["RscText", 3]; 
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05]; 
            _bankText ctrlSetTextColor [0, 1, 0, 1]; 
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]]; 
            _bankText ctrlCommit 0; 
            private _listBox = _display ctrlCreate ["RscListBox", 4]; 
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3]; 
            _listBox ctrlCommit 0; 
            { 
                _x params ["_class", "_name", "_price"]; 
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price]; 
                _listBox lbSetData [_index, _class]; 
                _listBox lbSetValue [_index, _price]; 
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")]; 
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]]; 
            } forEach _equipment; 
            private _buyBtn = _display ctrlCreate ["RscButton", 5]; 
            _buyBtn ctrlSetText "Purchase Equipment"; 
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05]; 
            _buyBtn ctrlSetTextColor [0, 1, 0, 1]; 
            _buyBtn ctrlCommit 0; 
            _buyBtn ctrlAddEventHandler ["ButtonClick", { 
                params ["_ctrl"]; 
                private _display = ctrlParent _ctrl; 
                private _listBox = _display displayCtrl 4; 
                private _selectedIndex = lbCurSel _listBox; 
                if (_selectedIndex != -1) then { 
                    private _itemClass = _listBox lbData _selectedIndex; 
                    private _price = _listBox lbValue _selectedIndex; 
                    [player, _itemClass, _price] remoteExec ["fnc_purchaseEquipment", 2]; 
                }; 
            }]; 
            private _closeBtn = _display ctrlCreate ["RscButton", 6]; 
            _closeBtn ctrlSetText "Close"; 
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05]; 
            _closeBtn ctrlSetTextColor [1, 0, 0, 1]; 
            _closeBtn ctrlCommit 0; 
            _closeBtn ctrlAddEventHandler ["ButtonClick", { 
                closeDialog 0; 
            }]; 
        }, 
        [], 
        1.5, 
        true, 
        true, 
        "", 
        "", 
        3 
    ]; 
} forEach (allMissionObjects "C_Man_ConstructionWorker_01_Vrana_F"); 
 
if (isServer) then { 
    fnc_purchaseEquipment = { 
        params ["_player", "_itemClass", "_price"]; 
        private _playerUID = getPlayerUID _player; 
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0]; 
        if (_bankMoney >= _price) then { 
            if (_itemClass select [0,2] == "H_") then { 
                _player addHeadgear _itemClass; 
            } else { 
                if (_itemClass select [0,2] == "G_") then { 
                    _player addGoggles _itemClass; 
                } else { 
                    _player linkItem _itemClass; 
                }; 
            }; 
            _bankMoney = _bankMoney - _price; 
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney]; 
            saveProfileNamespace; 
            [format ["<t size='0.7' color='#00ff00'>Equipment purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        } else { 
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        }; 
    }; 
    publicVariable "fnc_purchaseEquipment"; 
};

{ 
    _x addAction [ 
        "<t color='#FFD700'>Uniform Shop</t>", 
        { 
            private _uniforms = [ 
                ["U_B_CombatUniform_mcam", "Combat Uniform", 400], 
                ["U_B_CombatUniform_mcam_vest", "Combat Uniform (Vest)", 500], 
                ["U_B_GhillieSuit", "Ghillie Suit", 1000], 
                ["U_B_FullGhillie_lsh", "Full Ghillie", 1500], 
                ["U_B_PilotCoveralls", "Pilot Coveralls", 600], 
                ["U_B_HeliPilotCoveralls", "Heli Pilot Coveralls", 550], 
                ["U_B_Wetsuit", "Wetsuit", 800], 
                ["U_B_CTRG_1", "CTRG Combat Uniform", 700], 
                ["U_B_CTRG_3", "CTRG Combat Uniform (Rolled-up)", 700], 
                ["U_B_survival_uniform", "Survival Fatigues", 900] 
            ]; 
 
            createDialog "RscDisplayEmpty"; 
            private _display = findDisplay -1; 
            private _bg = _display ctrlCreate ["RscText", 1]; 
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6]; 
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7]; 
            _bg ctrlCommit 0; 
 
            private _title = _display ctrlCreate ["RscText", 2]; 
            _title ctrlSetText "Uniform Shop"; 
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05]; 
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1]; 
            _title ctrlSetTextColor [1, 1, 1, 1]; 
            _title ctrlCommit 0; 
 
            private _bankText = _display ctrlCreate ["RscText", 3]; 
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05]; 
            _bankText ctrlSetTextColor [0, 1, 0, 1]; 
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]]; 
            _bankText ctrlCommit 0; 
 
            private _listBox = _display ctrlCreate ["RscListBox", 4]; 
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3]; 
            _listBox ctrlCommit 0; 
 
            { 
                _x params ["_class", "_name", "_price"]; 
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price]; 
                _listBox lbSetData [_index, _class]; 
                _listBox lbSetValue [_index, _price]; 
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")]; 
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]]; 
            } forEach _uniforms; 
 
            private _buyBtn = _display ctrlCreate ["RscButton", 5]; 
            _buyBtn ctrlSetText "Purchase Uniform"; 
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05]; 
            _buyBtn ctrlSetTextColor [0, 1, 0, 1]; 
            _buyBtn ctrlCommit 0; 
 
            _buyBtn ctrlAddEventHandler ["ButtonClick", { 
                params ["_ctrl"]; 
                private _display = ctrlParent _ctrl; 
                private _listBox = _display displayCtrl 4; 
                private _selectedIndex = lbCurSel _listBox; 
                if (_selectedIndex != -1) then { 
                    private _uniformClass = _listBox lbData _selectedIndex; 
                    private _price = _listBox lbValue _selectedIndex; 
                    [player, _uniformClass, _price] remoteExec ["fnc_purchaseUniform", 2]; 
                }; 
            }]; 
 
            private _closeBtn = _display ctrlCreate ["RscButton", 6]; 
            _closeBtn ctrlSetText "Close"; 
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05]; 
            _closeBtn ctrlSetTextColor [1, 0, 0, 1]; 
            _closeBtn ctrlCommit 0; 
 
            _closeBtn ctrlAddEventHandler ["ButtonClick", { 
                closeDialog 0; 
            }]; 
        }, 
        [], 
        1.5, 
        true, 
        true, 
        "", 
        "", 
        3 
    ]; 
} forEach (allMissionObjects "C_Man_ConstructionWorker_01_Blue_F"); 
 
if (isServer) then { 
    fnc_purchaseUniform = { 
        params ["_player", "_uniformClass", "_price"]; 
        private _playerUID = getPlayerUID _player; 
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0]; 
         
        if (_bankMoney >= _price) then { 
            _player forceAddUniform _uniformClass; 
            _bankMoney = _bankMoney - _price; 
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney]; 
            saveProfileNamespace; 
            [format ["<t size='0.7' color='#00ff00'>Uniform purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        } else { 
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        }; 
    }; 
     
    publicVariable "fnc_purchaseUniform"; 
};

{ 
    _x addAction [ 
        "<t color='#FFD700'>Backpack Shop</t>", 
        { 
            private _backpacks = [ 
				["B_AssaultPack_blk", "Black Assault Pack", 150],
				["B_AssaultPack_cbr", "Coyote Assault Pack", 150],
				["B_AssaultPack_dgtl", "Digital Assault Pack", 150],
				["B_AssaultPack_eaf_F", "EAF Assault Pack", 150],
				["B_AssaultPack_rgr", "Ranger Green Assault Pack", 150],
				["B_AssaultPack_ocamo", "Hex Assault Pack", 150],
				["B_AssaultPack_khk", "Khaki Assault Pack", 150],
				["B_AssaultPack_mcamo", "MTP Assault Pack", 150],
				["B_AssaultPack_sgg", "Sage Assault Pack", 150],
				["B_AssaultPack_tna_F", "Tropic Assault Pack", 150],
				["B_AssaultPack_wdl_F", "Woodland Assault Pack", 150],
				["B_Bergen_dgtl_F", "Digital Bergen", 300],
				["B_Bergen_hex_F", "Hex Bergen", 300],
				["B_Bergen_mcamo_F", "MTP Bergen", 300],
				["B_Bergen_tna_F", "Tropic Bergen", 300],
				["B_Respawn_Sleeping_bag_blue_F", "Blue Sleeping Bag", 100],
				["B_Respawn_Sleeping_bag_brown_F", "Brown Sleeping Bag", 100],
				["B_Respawn_TentDome_F", "Dome Tent", 200],
				["B_Patrol_Respawn_bag_F", "Patrol Bag", 150],
				["B_Respawn_Sleeping_bag_F", "Sleeping Bag", 100],
				["B_Respawn_TentA_F", "Tent", 200],
				["B_Carryall_blk", "Black Carryall", 400],
				["B_Carryall_cbr", "Coyote Carryall", 400],
				["B_Carryall_eaf_F", "EAF Carryall", 400],
				["B_Carryall_ghex_F", "Green Hex Carryall", 400],
				["B_Carryall_green_F", "Green Carryall", 400],
				["B_Carryall_ocamo", "Hex Carryall", 400],
				["B_Carryall_khk", "Khaki Carryall", 400],
				["B_Carryall_mcamo", "MTP Carryall", 400],
				["B_Carryall_oli", "Olive Carryall", 400],
				["B_Carryall_taiga_F", "Taiga Carryall", 400],
				["B_Carryall_oucamo", "Urban Carryall", 400],
				["B_Carryall_wdl_F", "Woodland Carryall", 400],
				["B_CombinationUnitRespirator_01_F", "Respirator", 250],
				["B_CivilianBackpack_01_Everyday_Astra_F", "Everyday Astra Pack", 200],
				["B_CivilianBackpack_01_Everyday_Black_F", "Everyday Black Pack", 200],
				["B_CivilianBackpack_01_Everyday_Vrana_F", "Everyday Vrana Pack", 200],
				["B_CivilianBackpack_01_Everyday_IDAP_F", "IDAP Pack", 200],
				["B_FieldPack_blk", "Black Field Pack", 250],
				["B_FieldPack_cbr", "Coyote Field Pack", 250],
				["B_FieldPack_ghex_F", "Green Hex Field Pack", 250],
				["B_FieldPack_green_F", "Green Field Pack", 250],
				["B_FieldPack_ocamo", "Hex Field Pack", 250],
				["B_FieldPack_khk", "Khaki Field Pack", 250],
				["B_FieldPack_oli", "Olive Field Pack", 250],
				["B_FieldPack_taiga_F", "Taiga Field Pack", 250],
				["B_FieldPack_oucamo", "Urban Field Pack", 250],
				["B_Kitbag_cbr", "Coyote Kitbag", 300],
				["B_Kitbag_rgr", "Green Kitbag", 300],
				["B_Kitbag_mcamo", "MTP Kitbag", 300],
				["B_Kitbag_sgg", "Sage Kitbag", 300],
				["B_Kitbag_tan", "Tan Kitbag", 300],
				["B_LegStrapBag_black_F", "Black Leg Strap", 150],
				["B_LegStrapBag_coyote_F", "Coyote Leg Strap", 150],
				["B_LegStrapBag_olive_F", "Olive Leg Strap", 150],
				["B_Messenger_Black_F", "Black Messenger", 200],
				["B_Messenger_Coyote_F", "Coyote Messenger", 200],
				["B_Messenger_Gray_F", "Gray Messenger", 200],
				["B_Messenger_Olive_F", "Olive Messenger", 200],
				["B_Messenger_IDAP_F", "IDAP Messenger", 200],
				["B_RadioBag_01_black_F", "Black Radio Pack", 350],
				["B_RadioBag_01_digi_F", "Digital Radio Pack", 350],
				["B_RadioBag_01_eaf_F", "EAF Radio Pack", 350],
				["B_RadioBag_01_ghex_F", "Green Hex Radio Pack", 350],
				["B_RadioBag_01_hex_F", "Hex Radio Pack", 350],
				["B_RadioBag_01_mtp_F", "MTP Radio Pack", 350],
				["B_RadioBag_01_tropic_F", "Tropic Radio Pack", 350],
				["B_RadioBag_01_oucamo_F", "Urban Radio Pack", 350],
				["B_RadioBag_01_wdl_F", "Woodland Radio Pack", 350],
				["B_SCBA_01_F", "SCBA", 300],
				["B_CivilianBackpack_01_Sport_Blue_F", "Blue Sport Pack", 200],
				["B_CivilianBackpack_01_Sport_Green_F", "Green Sport Pack", 200],
				["B_CivilianBackpack_01_Sport_Red_F", "Red Sport Pack", 200],
				["B_Parachute", "Parachute", 400],
				["B_TacticalPack_blk", "Black Tactical Pack", 300],
				["B_TacticalPack_rgr", "Green Tactical Pack", 300],
				["B_TacticalPack_ocamo", "Hex Tactical Pack", 300],
				["B_TacticalPack_mcamo", "MTP Tactical Pack", 300],
				["B_TacticalPack_oli", "Olive Tactical Pack", 300],
				["I_UAV_06_backpack_F", "AR-2 Darter Bag [AAF]", 1500],
				["O_UAV_06_backpack_F", "AR-2 Darter Bag [CSAT]", 1500],
				["B_UAV_06_backpack_F", "AR-2 Darter Bag [NATO]", 1500],
				["I_UAV_06_medical_backpack_F", "AR-2 Medical Darter [AAF]", 2000],
				["O_UAV_06_medical_backpack_F", "AR-2 Medical Darter [CSAT]", 2000],
				["B_UAV_06_medical_backpack_F", "AR-2 Medical Darter [NATO]", 2000],
				["I_UAV_01_backpack_F", "AR-2 Darter Bag [AAF]", 1500],
				["O_UAV_01_backpack_F", "AR-2 Darter Bag [CSAT]", 1500],
				["B_UAV_01_backpack_F", "AR-2 Darter Bag [NATO]", 1500],
				["C_IDAP_UAV_06_antimine_backpack_F", "Demining Drone", 2500],
				["I_UGV_02_Demining_backpack_F", "ED-1D Demining [AAF]", 3000],
				["O_UGV_02_Demining_backpack_F", "ED-1D Demining [CSAT]", 3000],
				["B_UGV_02_Demining_backpack_F", "ED-1D Demining [NATO]", 3000],
				["I_UGV_02_Science_backpack_F", "ED-1E Science [AAF]", 2500],
				["O_UGV_02_Science_backpack_F", "ED-1E Science [CSAT]", 2500],
				["B_UGV_02_Science_backpack_F", "ED-1E Science [NATO]", 2500],
				["B_AssaultPack_Kerry", "Kerry's Pack", 150],
				["B_ViperHarness_blk_F", "Black Viper Harness", 500],
				["B_ViperHarness_ghex_F", "Green Hex Viper Harness", 500],
				["B_ViperHarness_hex_F", "Hex Viper Harness", 500],
				["B_ViperHarness_khk_F", "Khaki Viper Harness", 500],
				["B_ViperHarness_oli_F", "Olive Viper Harness", 500],
				["B_ViperLightHarness_blk_F", "Black Light Viper Harness", 400],
				["B_ViperLightHarness_ghex_F", "Green Hex Light Viper Harness", 400],
				["B_ViperLightHarness_hex_F", "Hex Light Viper Harness", 400],
				["B_ViperLightHarness_khk_F", "Khaki Light Viper Harness", 400],
				["B_ViperLightHarness_oli_F", "Olive Light Viper Harness", 400] 
            ]; 
 
            createDialog "RscDisplayEmpty"; 
            private _display = findDisplay -1; 
            private _bg = _display ctrlCreate ["RscText", 1]; 
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6]; 
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7]; 
            _bg ctrlCommit 0; 
 
            private _title = _display ctrlCreate ["RscText", 2]; 
            _title ctrlSetText "Backpack Shop"; 
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05]; 
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1]; 
            _title ctrlSetTextColor [1, 1, 1, 1]; 
            _title ctrlCommit 0; 
 
            private _bankText = _display ctrlCreate ["RscText", 3]; 
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05]; 
            _bankText ctrlSetTextColor [0, 1, 0, 1]; 
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]]; 
            _bankText ctrlCommit 0; 
 
            private _listBox = _display ctrlCreate ["RscListBox", 4]; 
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3]; 
            _listBox ctrlCommit 0; 
 
            { 
                _x params ["_class", "_name", "_price"]; 
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price]; 
                _listBox lbSetData [_index, _class]; 
                _listBox lbSetValue [_index, _price]; 
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgVehicles" >> _class >> "picture")]; 
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]]; 
            } forEach _backpacks; 
 
            private _buyBtn = _display ctrlCreate ["RscButton", 5]; 
            _buyBtn ctrlSetText "Purchase Backpack"; 
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05]; 
            _buyBtn ctrlSetTextColor [0, 1, 0, 1]; 
            _buyBtn ctrlCommit 0; 
 
            _buyBtn ctrlAddEventHandler ["ButtonClick", { 
                params ["_ctrl"]; 
                private _display = ctrlParent _ctrl; 
                private _listBox = _display displayCtrl 4; 
                private _selectedIndex = lbCurSel _listBox; 
                if (_selectedIndex != -1) then { 
                    private _backpackClass = _listBox lbData _selectedIndex; 
                    private _price = _listBox lbValue _selectedIndex; 
                    [player, _backpackClass, _price] remoteExec ["fnc_purchaseBackpack", 2]; 
                }; 
            }]; 
 
            private _closeBtn = _display ctrlCreate ["RscButton", 6]; 
            _closeBtn ctrlSetText "Close"; 
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05]; 
            _closeBtn ctrlSetTextColor [1, 0, 0, 1]; 
            _closeBtn ctrlCommit 0; 
 
            _closeBtn ctrlAddEventHandler ["ButtonClick", { 
                closeDialog 0; 
            }]; 
        }, 
        [], 
        1.5, 
        true, 
        true, 
        "", 
        "", 
        3 
    ]; 
} forEach (allMissionObjects "C_Man_ConstructionWorker_01_Red_F"); 
 
if (isServer) then { 
    fnc_purchaseBackpack = { 
        params ["_player", "_backpackClass", "_price"]; 
        private _playerUID = getPlayerUID _player; 
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0]; 
         
        if (_bankMoney >= _price) then { 
            removeBackpack _player; 
            _player addBackpack _backpackClass; 
            _bankMoney = _bankMoney - _price; 
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney]; 
            saveProfileNamespace; 
            [format ["<t size='0.7' color='#00ff00'>Backpack purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        } else { 
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        }; 
    }; 
     
    publicVariable "fnc_purchaseBackpack"; 
};

{      
    _x addAction [ 
        "<t color='#FFD700'>Equipment Shop</t>", 
        {      
            private _equipment = [ 
                ["ItemMap", "Map", 50], 
                ["ItemCompass", "Compass", 75], 
                ["ItemWatch", "Watch", 100], 
                ["ItemGPS", "GPS", 300], 
                ["Binocular", "Binoculars", 250], 
                ["FirstAidKit", "First Aid Kit", 150], 
                ["Medikit", "Medikit", 500], 
                ["ToolKit", "Toolkit", 350] 
            ]; 
 
            createDialog "RscDisplayEmpty"; 
            private _display = findDisplay -1; 
 
            private _bg = _display ctrlCreate ["RscText", 1]; 
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6]; 
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7]; 
            _bg ctrlCommit 0; 
 
            private _title = _display ctrlCreate ["RscText", 2]; 
            _title ctrlSetText "Equipment Shop"; 
            _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05]; 
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1]; 
            _title ctrlSetTextColor [1, 1, 1, 1]; 
            _title ctrlCommit 0; 
 
            private _bankText = _display ctrlCreate ["RscText", 3]; 
            _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05]; 
            _bankText ctrlSetTextColor [0, 1, 0, 1]; 
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]]; 
            _bankText ctrlCommit 0; 
 
            private _listBox = _display ctrlCreate ["RscListBox", 4]; 
            _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3]; 
            _listBox ctrlCommit 0; 
 
            { 
                _x params ["_class", "_name", "_price"]; 
                private _index = _listBox lbAdd format["%1 - $%2", _name, _price]; 
                _listBox lbSetData [_index, _class]; 
                _listBox lbSetValue [_index, _price]; 
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")]; 
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]]; 
            } forEach _equipment; 
 
            private _buyBtn = _display ctrlCreate ["RscButton", 5]; 
            _buyBtn ctrlSetText "Purchase Equipment"; 
            _buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05]; 
            _buyBtn ctrlSetTextColor [0, 1, 0, 1]; 
            _buyBtn ctrlCommit 0; 
 
            _buyBtn ctrlAddEventHandler ["ButtonClick", { 
                params ["_ctrl"]; 
                private _display = ctrlParent _ctrl; 
                private _listBox = _display displayCtrl 4; 
                private _selectedIndex = lbCurSel _listBox; 
 
                if (_selectedIndex != -1) then { 
                    private _itemClass = _listBox lbData _selectedIndex; 
                    private _price = _listBox lbValue _selectedIndex; 
                    [player, _itemClass, _price] remoteExec ["fnc_purchaseEquipment", 2]; 
                }; 
            }]; 
 
            private _closeBtn = _display ctrlCreate ["RscButton", 6]; 
            _closeBtn ctrlSetText "Close"; 
            _closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05]; 
            _closeBtn ctrlSetTextColor [1, 0, 0, 1]; 
            _closeBtn ctrlCommit 0; 
 
            _closeBtn ctrlAddEventHandler ["ButtonClick", { 
                closeDialog 0; 
            }]; 
        }, 
        [], 
        1.5, 
        true, 
        true, 
        "", 
        "", 
        3 
    ]; 
} forEach (allMissionObjects "C_man_w_worker_F"); 
 
if (isServer) then { 
    fnc_purchaseEquipment = { 
        params ["_player", "_itemClass", "_price"]; 
        private _playerUID = getPlayerUID _player; 
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0]; 
 
        if (_bankMoney >= _price) then { 
            _player addItem _itemClass; 
            _bankMoney = _bankMoney - _price; 
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney]; 
            saveProfileNamespace; 
            [format ["<t size='0.7' color='#00ff00'>Equipment purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        } else { 
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player]; 
        }; 
    }; 
 
    publicVariable "fnc_purchaseEquipment"; 
};
   
setTimeMultiplier 0;    
setAccTime 0.80;

{
    _x addAction ["<t color='#FFD700'>Rifle Shop</t>", {
        private _weapons = [
			["arifle_AK12_F", "AK-12 7.62 mm", 1200, ["30Rnd_762x39_AK12_Mag_F"]],
			["arifle_AK12_arid_f", "AK-12 7.62 mm (Arid)", 1200, ["30Rnd_762x39_AK12_Arid_Mag_F"]],
			["arifle_AK12_lush_f", "AK-12 7.62 mm (Lush)", 1200, ["30Rnd_762x39_AK12_Lush_Mag_F"]],
			["arifle_AK12_GL_F", "AK-12 GL 7.62 mm", 1500, ["30Rnd_762x39_AK12_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_AK12_GL_arid_F", "AK-12 GL 7.62 mm (Arid)", 1500, ["30Rnd_762x39_AK12_Arid_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_AK12_GL_lush_F", "AK-12 GL 7.62 mm (Lush)", 1500, ["30Rnd_762x39_AK12_Lush_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_AKM_F", "AKM 7.62 mm", 1000, ["30Rnd_762x39_Mag_F"]],
			["arifle_AKS_F", "AKS-74U 5.45 mm", 900, ["30Rnd_545x39_Mag_F"]],
			["arifle_AK12U_F", "AK-12U 7.62 mm", 1100, ["30Rnd_762x39_AK12_Mag_F"]],
			["arifle_AK12U_arid_f", "AK-12U 7.62 mm (Arid)", 1100, ["30Rnd_762x39_AK12_Arid_Mag_F"]],
			["arifle_AK12U_lush_f", "AK-12U 7.62 mm (Lush)", 1100, ["30Rnd_762x39_AK12_Lush_Mag_F"]],
			["arifle_CTAR_blk_F", "CAR-95 5.8 mm (Black)", 1300, ["30Rnd_580x42_Mag_F"]],
			["arifle_CTAR_ghex_F", "CAR-95 5.8 mm (Green Hex)", 1300, ["30Rnd_580x42_Mag_F"]],
			["arifle_CTAR_hex_F", "CAR-95 5.8 mm (Hex)", 1300, ["30Rnd_580x42_Mag_F"]],
			["arifle_CTAR_GL_blk_F", "CAR-95 GL 5.8 mm (Black)", 1600, ["30Rnd_580x42_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_CTAR_GL_ghex_F", "CAR-95 GL 5.8 mm (Green Hex)", 1600, ["30Rnd_580x42_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_CTAR_GL_hex_F", "CAR-95 GL 5.8 mm (Hex)", 1600, ["30Rnd_580x42_Mag_F", "1Rnd_HE_Grenade_shell"]],
			["arifle_CTARS_blk_F", "CAR-95-1 5.8 mm (Black)", 1400, ["100Rnd_580x42_Mag_F"]],
			["arifle_CTARS_ghex_F", "CAR-95-1 5.8 mm (Green Hex)", 1400, ["100Rnd_580x42_Mag_F"]],
			["arifle_CTARS_hex_F", "CAR-95-1 5.8 mm (Hex)", 1400, ["100Rnd_580x42_Mag_F"]],
			["arifle_Katiba_F", "Katiba 6.5 mm", 1200, ["30Rnd_65x39_caseless_green"]],
			["arifle_Katiba_C_F", "Katiba Carbine 6.5 mm", 1100, ["30Rnd_65x39_caseless_green"]],
			["arifle_Katiba_GL_F", "Katiba GL 6.5 mm", 1500, ["30Rnd_65x39_caseless_green", "1Rnd_HE_Grenade_shell"]],
			["sgun_HunterShotgun_01_F", "Kozlice 12G", 800, ["2Rnd_12Gauge_Pellets"]],
			["sgun_HunterShotgun_01_sawedoff_F", "Kozlice 12G (Sawed-Off)", 600, ["2Rnd_12Gauge_Pellets"]],
			["arifle_Mk20_plain_F", "Mk20 5.56 mm", 1000, ["30Rnd_556x45_Stanag"]],
			["arifle_Mk20_F", "Mk20 5.56 mm (Camo)", 1000, ["30Rnd_556x45_Stanag"]],
			["arifle_Mk20_GL_plain_F", "Mk20 GL 5.56 mm", 1300, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_Mk20_GL_F", "Mk20 GL 5.56 mm (Camo)", 1300, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_Mk20C_plain_F", "Mk20C 5.56 mm", 900, ["30Rnd_556x45_Stanag"]],
			["arifle_Mk20C_F", "Mk20C 5.56 mm (Camo)", 900, ["30Rnd_556x45_Stanag"]],
			["arifle_MX_GL_F", "MX 3GL 6.5 mm", 1500, ["30Rnd_65x39_caseless_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MX_GL_Black_F", "MX 3GL 6.5 mm (Black)", 1500, ["30Rnd_65x39_caseless_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MX_GL_khk_F", "MX 3GL 6.5 mm (Khaki)", 1500, ["30Rnd_65x39_caseless_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MX_F", "MX 6.5 mm", 1200, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MX_Black_F", "MX 6.5 mm (Black)", 1200, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MX_khk_F", "MX 6.5 mm (Khaki)", 1200, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXC_F", "MXC 6.5 mm", 1100, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXC_Black_F", "MXC 6.5 mm (Black)", 1100, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXC_khk_F", "MXC 6.5 mm (Khaki)", 1100, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXM_F", "MXM 6.5 mm", 1400, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXM_Black_F", "MXM 6.5 mm (Black)", 1400, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MXM_khk_F", "MXM 6.5 mm (Khaki)", 1400, ["30Rnd_65x39_caseless_mag"]],
			["arifle_MSBS65_F", "Promet 6.5 mm", 1300, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_black_F", "Promet 6.5 mm (Black)", 1300, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_camo_F", "Promet 6.5 mm (Camo)", 1300, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_sand_F", "Promet 6.5 mm (Sand)", 1300, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_GL_F", "Promet GL 6.5 mm", 1600, ["30Rnd_65x39_caseless_msbs_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MSBS65_GL_black_F", "Promet GL 6.5 mm (Black)", 1600, ["30Rnd_65x39_caseless_msbs_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MSBS65_GL_camo_F", "Promet GL 6.5 mm (Camo)", 1600, ["30Rnd_65x39_caseless_msbs_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MSBS65_GL_sand_F", "Promet GL 6.5 mm (Sand)", 1600, ["30Rnd_65x39_caseless_msbs_mag", "1Rnd_HE_Grenade_shell"]],
			["arifle_MSBS65_Mark_F", "Promet MR 6.5 mm", 1500, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_Mark_black_F", "Promet MR 6.5 mm (Black)", 1500, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_Mark_camo_F", "Promet MR 6.5 mm (Camo)", 1500, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_Mark_sand_F", "Promet MR 6.5 mm (Sand)", 1500, ["30Rnd_65x39_caseless_msbs_mag"]],
			["arifle_MSBS65_UBS_F", "Promet SG 6.5 mm", 1700, ["30Rnd_65x39_caseless_msbs_mag", "6Rnd_12Gauge_Pellets"]],
			["arifle_MSBS65_UBS_black_F", "Promet SG 6.5 mm (Black)", 1700, ["30Rnd_65x39_caseless_msbs_mag", "6Rnd_12Gauge_Pellets"]],
			["arifle_MSBS65_UBS_camo_F", "Promet SG 6.5 mm (Camo)", 1700, ["30Rnd_65x39_caseless_msbs_mag", "6Rnd_12Gauge_Pellets"]],
			["arifle_MSBS65_UBS_sand_F", "Promet SG 6.5 mm (Sand)", 1700, ["30Rnd_65x39_caseless_msbs_mag", "6Rnd_12Gauge_Pellets"]],
			["arifle_RPK12_F", "RPK-12 7.62 mm", 1600, ["75rnd_762x39_AK12_Mag_F"]],
			["arifle_RPK12_arid_f", "RPK-12 7.62 mm (Arid)", 1600, ["75rnd_762x39_AK12_Arid_Mag_F"]],
			["arifle_RPK12_lush_f", "RPK-12 7.62 mm (Lush)", 1600, ["75rnd_762x39_AK12_Lush_Mag_F"]],
			["arifle_SDAR_F", "SDAR 5.56 mm", 1000, ["30Rnd_556x45_Stanag", "20Rnd_556x45_UW_mag"]],
			["arifle_SPAR_01_blk_F", "SPAR-16 5.56 mm (Black)", 1200, ["30Rnd_556x45_Stanag"]],
			["arifle_SPAR_01_khk_F", "SPAR-16 5.56 mm (Khaki)", 1200, ["30Rnd_556x45_Stanag"]],
			["arifle_SPAR_01_snd_F", "SPAR-16 5.56 mm (Sand)", 1200, ["30Rnd_556x45_Stanag"]],
			["arifle_SPAR_01_GL_blk_F", "SPAR-16 GL 5.56 mm (Black)", 1500, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_SPAR_01_GL_khk_F", "SPAR-16 GL 5.56 mm (Khaki)", 1500, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_SPAR_01_GL_blk_F", "SPAR-16 GL 5.56 mm (Black)", 1500, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_SPAR_01_GL_khk_F", "SPAR-16 GL 5.56 mm (Khaki)", 1500, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_SPAR_01_GL_snd_F", "SPAR-16 GL 5.56 mm (Sand)", 1500, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_SPAR_02_blk_F", "SPAR-16S 5.56 mm (Black)", 1400, ["150Rnd_556x45_Drum_Mag_F"]],
			["arifle_SPAR_02_khk_F", "SPAR-16S 5.56 mm (Khaki)", 1400, ["150Rnd_556x45_Drum_Mag_F"]],
			["arifle_SPAR_02_snd_F", "SPAR-16S 5.56 mm (Sand)", 1400, ["150Rnd_556x45_Drum_Mag_F"]],
			["arifle_SPAR_03_blk_F", "SPAR-17 7.62 mm (Black)", 1600, ["20Rnd_762x51_Mag"]],
			["arifle_SPAR_03_khk_F", "SPAR-17 7.62 mm (Khaki)", 1600, ["20Rnd_762x51_Mag"]],
			["arifle_SPAR_03_snd_F", "SPAR-17 7.62 mm (Sand)", 1600, ["20Rnd_762x51_Mag"]],
			["arifle_TRG20_F", "TRG-20 5.56 mm", 1000, ["30Rnd_556x45_Stanag"]],
			["arifle_TRG21_F", "TRG-21 5.56 mm", 1100, ["30Rnd_556x45_Stanag"]],
			["arifle_TRG21_GL_F", "TRG-21 GL 5.56 mm", 1400, ["30Rnd_556x45_Stanag", "1Rnd_HE_Grenade_shell"]],
			["arifle_ARX_blk_F", "Type 115 6.5 mm (Black)", 1800, ["30Rnd_65x39_caseless_green", "10Rnd_50BW_Mag_F"]],
			["arifle_ARX_ghex_F", "Type 115 6.5 mm (Green Hex)", 1800, ["30Rnd_65x39_caseless_green", "10Rnd_50BW_Mag_F"]],
			["arifle_ARX_hex_F", "Type 115 6.5 mm (Hex)", 1800, ["30Rnd_65x39_caseless_green", "10Rnd_50BW_Mag_F"]]
        ];
        
        private _mags = [
            ["30Rnd_762x39_AK12_Mag_F", "7.62mm 30rnd AK12 Mag", 200],
            ["30Rnd_762x39_AK12_Arid_Mag_F", "7.62mm 30rnd AK12 Arid Mag", 200],
            ["30Rnd_762x39_AK12_Lush_Mag_F", "7.62mm 30rnd AK12 Lush Mag", 200],
            ["30Rnd_762x39_Mag_F", "7.62mm 30rnd AKM Mag", 180],
            ["30Rnd_545x39_Mag_F", "5.45mm 30rnd Mag", 150],
            ["30Rnd_580x42_Mag_F", "5.8mm 30rnd Mag", 200],
            ["100Rnd_580x42_Mag_F", "5.8mm 100rnd Mag", 500],
            ["30Rnd_65x39_caseless_green", "6.5mm 30rnd Caseless Mag", 250],
            ["2Rnd_12Gauge_Pellets", "12G Pellets", 100],
            ["30Rnd_556x45_Stanag", "5.56mm 30rnd STANAG", 200],
            ["30Rnd_65x39_caseless_mag", "6.5mm 30rnd Caseless Mag", 250],
            ["30Rnd_65x39_caseless_msbs_mag", "6.5mm 30rnd MSBS Mag", 250],
            ["6Rnd_12Gauge_Pellets", "12G 6rnd Pellets", 150],
            ["75rnd_762x39_AK12_Mag_F", "7.62mm 75rnd AK12 Mag", 400],
            ["20Rnd_556x45_UW_mag", "5.56mm 20rnd UW Mag", 300],
            ["150Rnd_556x45_Drum_Mag_F", "5.56mm 150rnd Drum", 600],
            ["20Rnd_762x51_Mag", "7.62mm 20rnd Mag", 300],
            ["10Rnd_50BW_Mag_F", "50BW 10rnd Mag", 400],
            ["1Rnd_HE_Grenade_shell", "40mm HE Grenade", 500]
        ];

        createDialog "RscDisplayEmpty";
        private _display = findDisplay -1;

        private _bg = _display ctrlCreate ["RscText", 1];
        _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.7];
        _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];
        _bg ctrlCommit 0;

        private _title = _display ctrlCreate ["RscText", 2];
        _title ctrlSetText "Weapon Shop";
        _title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];
        _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];
        _title ctrlSetTextColor [1, 1, 1, 1];
        _title ctrlCommit 0;

        private _bankText = _display ctrlCreate ["RscText", 3];
        _bankText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];
        _bankText ctrlSetTextColor [0, 1, 0, 1];
        _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];
        _bankText ctrlCommit 0;

        private _listBox = _display ctrlCreate ["RscListBox", 4];
        _listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.2];
        _listBox ctrlCommit 0;

        {
            _x params ["_class", "_name", "_price"];
            private _index = _listBox lbAdd format["%1 - $%2", _name, _price];
            _listBox lbSetData [_index, _class];
            _listBox lbSetValue [_index, _price];
            _listBox lbSetPictureRight [_index, getText (configFile >> "CfgWeapons" >> _class >> "picture")];
            _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]];
        } forEach _weapons;

        private _buyBtn = _display ctrlCreate ["RscButton", 5];
        _buyBtn ctrlSetText "Purchase Weapon";
        _buyBtn ctrlSetPosition [0.325, 0.53, 0.16, 0.05];
        _buyBtn ctrlSetTextColor [0, 1, 0, 1];
        _buyBtn ctrlCommit 0;

        _buyBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _listBox = _display displayCtrl 4;
            private _selectedIndex = lbCurSel _listBox;
            if (_selectedIndex != -1) then {
                private _weaponClass = _listBox lbData _selectedIndex;
                private _price = _listBox lbValue _selectedIndex;
                [player, _weaponClass, _price] remoteExec ["fnc_purchaseWeapon", 2];
            };
        }];

        private _sellBtn = _display ctrlCreate ["RscButton", 10];
        _sellBtn ctrlSetText "Sell Weapon";
        _sellBtn ctrlSetPosition [0.495, 0.53, 0.16, 0.05];
        _sellBtn ctrlSetTextColor [1, 0.5, 0, 1];
        _sellBtn ctrlCommit 0;

        _sellBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _player = player;
            private _currentWeapon = currentWeapon _player;
            if (_currentWeapon != "") then {
                private _weaponInfo = _weapons findIf { (_x select 0) isEqualTo _currentWeapon };
                if (_weaponInfo != -1) then {
                    private _salePrice = (_weapons select _weaponInfo) select 2;
                    _salePrice = _salePrice / 2;
                    private _playerUID = getPlayerUID _player;
                    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
                    _player removeWeapon _currentWeapon;
                    {
                        if (_x in (magazines _player)) then {
                            _player removeMagazine _x;
                        };
                    } forEach (getArray (configFile >> "CfgWeapons" >> _currentWeapon >> "magazines"));
                    _bankMoney = _bankMoney + _salePrice;
                    profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
                    saveProfileNamespace;
                    [format ["<t size='0.7' color='#00ff00'>Weapon sold for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _salePrice, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
                } else {
                    ["<t size='0.7' color='#ff0000'>This weapon is not for sale here!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
                };
            } else {
                ["<t size='0.7' color='#ff0000'>You have no weapon to sell!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
            };
        }];

        private _magSection = _display ctrlCreate ["RscText", 7];
        _magSection ctrlSetText "Magazines";
        _magSection ctrlSetPosition [0.3, 0.59, 0.4, 0.05];
        _magSection ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];
        _magSection ctrlSetTextColor [1, 1, 1, 1];
        _magSection ctrlCommit 0;

        private _magListBox = _display ctrlCreate ["RscListBox", 8];
        _magListBox ctrlSetPosition [0.325, 0.65, 0.35, 0.2];
        _magListBox ctrlCommit 0;

        {
            _x params ["_magClass", "_magName", "_magPrice"];
            private _magIndex = _magListBox lbAdd format["%1 - $%2", _magName, _magPrice];
            _magListBox lbSetData [_magIndex, _magClass];
            _magListBox lbSetValue [_magIndex, _magPrice];
            _magListBox lbSetPictureRight [_magIndex, getText (configFile >> "CfgMagazines" >> _magClass >> "picture")];
            _magListBox lbSetPictureRightColor [_magIndex, [1, 1, 1, 1]];
        } forEach _mags;

        private _buyMagBtn = _display ctrlCreate ["RscButton", 9];
        _buyMagBtn ctrlSetText "Buy Mag";
        _buyMagBtn ctrlSetPosition [0.325, 0.86, 0.16, 0.05];
        _buyMagBtn ctrlSetTextColor [0, 1, 0, 1];
        _buyMagBtn ctrlCommit 0;

        _buyMagBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _magListBox = _display displayCtrl 8;
            private _selectedMagIndex = lbCurSel _magListBox;
            if (_selectedMagIndex != -1) then {
                private _magClass = _magListBox lbData _selectedMagIndex;
                private _magPrice = _magListBox lbValue _selectedMagIndex;
                [player, _magClass, _magPrice] remoteExec ["fnc_purchaseMag", 2];
            };
        }];

        private _closeBtn = _display ctrlCreate ["RscButton", 6];
        _closeBtn ctrlSetText "Close";
        _closeBtn ctrlSetPosition [0.515, 0.86, 0.16, 0.05];
        _closeBtn ctrlSetTextColor [1, 0, 0, 1];
        _closeBtn ctrlCommit 0;

        _closeBtn ctrlAddEventHandler ["ButtonClick", {
            closeDialog 0;
        }];
    }, [], 1.5, true, true, "", "", 3];
} forEach (allMissionObjects "I_Soldier_VR_F");

if (isServer) then {
    fnc_purchaseWeapon = {
        params ["_player", "_weaponClass", "_price"];
        private _playerUID = getPlayerUID _player;
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
        if (_bankMoney >= _price) then {
            private _currentWeapon = currentWeapon _player;
            if (_currentWeapon != "") then {
                _player removeWeapon _currentWeapon;
                {
                    if (_x in (magazines _player)) then {
                        _player removeMagazine _x;
                    };
                } forEach (getArray (configFile >> "CfgWeapons" >> _currentWeapon >> "magazines"));
            };
            _player addWeapon _weaponClass;
            private _magazineClass = getArray (configFile >> "CfgWeapons" >> _weaponClass >> "magazines") select 0;
            for "_i" from 1 to 3 do {
                _player addMagazine _magazineClass;
            };
            _bankMoney = _bankMoney - _price;
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
            saveProfileNamespace;
            [format ["<t size='0.7' color='#00ff00'>Weapon purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        } else {
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        };
    };

    fnc_purchaseMag = {
        params ["_player", "_magClass", "_price"];
        private _playerUID = getPlayerUID _player;
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];
        if (_bankMoney >= _price) then {
            _player addMagazine _magClass;
            _bankMoney = _bankMoney - _price;
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];
            saveProfileNamespace;
            [format ["<t size='0.7' color='#00ff00'>Magazine purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        } else {
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];
        };
    };

    publicVariable "fnc_purchaseWeapon";
    publicVariable "fnc_purchaseMag";
};
