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
            ["C_Van_01_fuel_F", "Fuel Van", 325000],   
   ["B_Truck_01_mover_F", "HEMTT Mover", 750000],   
   ["B_Truck_01_ammo_F", "HEMTT Ammo", 850000],   
   ["B_Truck_01_cargo_F", "HEMTT Cargo", 800000],   
   ["B_Truck_01_flatbed_F", "HEMTT Flatbed", 775000],   
   ["B_Truck_01_fuel_F", "HEMTT Fuel", 825000],   
   ["B_Truck_01_medical_F", "HEMTT Medical", 800000],   
   ["B_Truck_01_Repair_F", "HEMTT Repair", 850000],   
   ["B_Truck_01_transport_F", "HEMTT Transport", 750000],   
   ["B_Truck_01_covered_F", "HEMTT Covered", 775000],   
   ["B_MRAP_01_F", "Hunter", 600000],   
   ["B_MRAP_01_gmg_F", "Hunter GMG", 950000],   
   ["B_LSV_01_AT_F", "Prowler AT", 900000],   
   ["B_LSV_01_armed_F", "Prowler Armed", 850000],   
   ["B_LSV_01_unarmed_F", "Prowler", 500000],   
   ["B_Quadbike_01_F", "Military Quad", 75000],   
   ["O_MRAP_02_F", "Ifrit", 600000],   
   ["O_MRAP_02_gmg_F", "Ifrit GMG", 950000],   
   ["O_MRAP_02_hmg_F", "Ifrit HMG", 925000],   
   ["O_LSV_02_AT_F", "Qilin AT", 900000],   
   ["O_LSV_02_armed_F", "Qilin Armed", 850000],   
   ["O_LSV_02_unarmed_F", "Qilin", 500000],   
   ["O_Quadbike_01_F", "CSAT Quad", 75000],   
   ["O_Truck_03_device_F", "Tempest Device", 900000],   
   ["O_Truck_03_ammo_F", "Tempest Ammo", 850000],   
   ["O_Truck_03_fuel_F", "Tempest Fuel", 825000],   
   ["O_Truck_03_medical_F", "Tempest Medical", 800000],   
   ["O_Truck_03_repair_F", "Tempest Repair", 850000],   
   ["O_Truck_03_transport_F", "Tempest Transport", 750000],   
   ["O_Truck_03_covered_F", "Tempest Covered", 775000],   
   ["O_Truck_02_Ammo_F", "Zamak Ammo", 800000],   
   ["O_Truck_02_fuel_F", "Zamak Fuel", 775000],   
   ["O_Truck_02_medical_F", "Zamak Medical", 750000],   
   ["O_Truck_02_box_F", "Zamak Box", 725000],   
   ["O_Truck_02_transport_F", "Zamak Transport", 700000],   
   ["O_Truck_02_covered_F", "Zamak Covered", 725000],   
   ["I_Quadbike_01_F", "AAF Quad", 75000],   
   ["I_MRAP_03_F", "Strider", 600000],   
   ["I_MRAP_03_gmg_F", "Strider GMG", 950000],   
   ["I_MRAP_03_hmg_F", "Strider HMG", 925000],   
   ["I_Truck_02_ammo_F", "AAF Zamak Ammo", 800000],   
   ["I_Truck_02_fuel_F", "AAF Zamak Fuel", 775000],   
   ["I_Truck_02_medical_F", "AAF Zamak Medical", 750000],   
   ["I_Truck_02_box_F", "AAF Zamak Box", 725000],   
   ["I_Truck_02_transport_F", "AAF Zamak Transport", 700000],   
   ["I_Truck_02_covered_F", "AAF Zamak Covered", 725000]      
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
        ["Crack", 100, 0],        
        ["Cocaine", 500, 0],        
        ["Crystal Meth", 50, 0],        
        ["Ecstasy", 200, 0],        
        ["Spice", 80, 0],        
        ["Heroin", 60, 0],        
        ["Cannabis", 120, 0],        
        ["LSD", 40, 0]        
    ];        
    publicVariable "commodities";        
       
    [] spawn {        
        while {true} do {        
            {        
                _x params ["_name", "_price", "_owned"];        
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
        private _playerUID = getPlayerUID player;   
        private _playerCommodities = profileNamespace getVariable [_playerUID + "_commodities", []];   
   
        _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [_playerUID + "_bankMoney", 0]];        
   
        lbClear _listBox;        
        {        
            _x params ["_name", "_price"];        
            private _owned = count (_playerCommodities select {(_x select 0) isEqualTo _name});   
            private _totalInvested = 0;   
            private _profitLoss = 0;   
               
            {   
                if ((_x select 0) isEqualTo _name) then {   
                    _totalInvested = _totalInvested + (_x select 1);   
                    _profitLoss = _profitLoss + (_price - (_x select 1));   
                };   
            } forEach _playerCommodities;   
               
            private _index = _listBox lbAdd format["%1 - Current: $%2 | Owned: %3 | P/L: $%4",    
                _name, round _price, _owned, round _profitLoss];        
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
            _bg ctrlSetPosition [0.2, 0.2, 0.8, 0.7];        
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];        
            _bg ctrlCommit 0;        
            private _title = _display ctrlCreate ["RscText", 2];        
            _title ctrlSetText "Commodity Market";        
            _title ctrlSetPosition [0.2, 0.2, 0.8, 0.05];        
            _title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];        
            _title ctrlSetTextColor [1, 1, 1, 1];        
            _title ctrlCommit 0;        
            private _bankText = _display ctrlCreate ["RscText", 3];        
            _bankText ctrlSetPosition [0.225, 0.26, 0.75, 0.05];        
            _bankText ctrlSetTextColor [0, 1, 0, 1];        
            _bankText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];        
            _bankText ctrlCommit 0;        
            private _listBox = _display ctrlCreate ["RscListBox", 4];        
            _listBox ctrlSetPosition [0.225, 0.32, 0.75, 0.25];        
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
   
            private _quantityInput = _display ctrlCreate ["RscEdit", 7];        
            _quantityInput ctrlSetPosition [0.425, 0.58, 0.35, 0.05];        
            _quantityInput ctrlSetText "1";        
            _quantityInput ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];        
            _quantityInput ctrlCommit 0;        
   
            private _minusBtn = _display ctrlCreate ["RscButton", 8];        
            _minusBtn ctrlSetText "-";        
            _minusBtn ctrlSetPosition [0.325, 0.58, 0.05, 0.05];        
            _minusBtn ctrlCommit 0;        
   
            private _plusBtn = _display ctrlCreate ["RscButton", 9];        
            _plusBtn ctrlSetText "+";        
            _plusBtn ctrlSetPosition [0.825, 0.58, 0.05, 0.05];        
            _plusBtn ctrlCommit 0;        
   
            _minusBtn ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _quantityInput = _display displayCtrl 7;        
                private _currentQty = parseNumber ctrlText _quantityInput;        
                if (_currentQty > 1) then {        
                    _quantityInput ctrlSetText str (_currentQty - 1);        
                };        
            }];        
   
            _plusBtn ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _quantityInput = _display displayCtrl 7;        
                private _currentQty = parseNumber ctrlText _quantityInput;        
                _quantityInput ctrlSetText str (_currentQty + 1);        
            }];        
   
            private _buyBtn = _display ctrlCreate ["RscButton", 5];        
            _buyBtn ctrlSetText "Buy";        
            _buyBtn ctrlSetPosition [0.325, 0.65, 0.16, 0.05];        
            _buyBtn ctrlSetTextColor [0, 1, 0, 1];        
            _buyBtn ctrlCommit 0;        
   
            _buyBtn ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _listBox = _display displayCtrl 4;        
                private _selectedIndex = lbCurSel _listBox;        
                private _quantity = parseNumber ctrlText (_display displayCtrl 7);   
                   
                if (_selectedIndex != -1 && _quantity > 0) then {        
                    private _commodityName = _listBox lbData _selectedIndex;        
                    private _price = _listBox lbValue _selectedIndex;        
                    private _totalCost = _price * _quantity;   
                    private _playerUID = getPlayerUID player;        
                    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];        
                       
                    if (_bankMoney >= _totalCost) then {        
                        _bankMoney = _bankMoney - _totalCost;        
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];        
                           
                        private _playerCommodities = profileNamespace getVariable [_playerUID + "_commodities", []];        
                        for "_i" from 1 to _quantity do {   
                            _playerCommodities pushBack [_commodityName, _price];        
                        };   
                        profileNamespace setVariable [_playerUID + "_commodities", _playerCommodities];        
                        saveProfileNamespace;        
                           
                        [format ["<t size='0.7' color='#00ff00'>Bought %1 shares of %2 for <t color='#FFFFFF'>$%3</t></t>",    
                            _quantity, _commodityName, _totalCost], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    } else {        
                        ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    };        
                };        
            }];        
   
            private _sellBtn = _display ctrlCreate ["RscButton", 10];        
            _sellBtn ctrlSetText "Sell";        
            _sellBtn ctrlSetPosition [0.495, 0.65, 0.16, 0.05];        
            _sellBtn ctrlSetTextColor [1, 0.5, 0, 1];        
            _sellBtn ctrlCommit 0;        
   
            _sellBtn ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _listBox = _display displayCtrl 4;        
                private _selectedIndex = lbCurSel _listBox;        
                private _quantity = parseNumber ctrlText (_display displayCtrl 7);   
                   
                if (_selectedIndex != -1 && _quantity > 0) then {        
                    private _commodityName = _listBox lbData _selectedIndex;        
                    private _price = _listBox lbValue _selectedIndex;        
                    private _playerUID = getPlayerUID player;        
                    private _playerCommodities = profileNamespace getVariable [_playerUID + "_commodities", []];        
                    private _ownedShares = _playerCommodities select {(_x select 0) isEqualTo _commodityName};   
                       
                    if (count _ownedShares >= _quantity) then {        
                        private _totalValue = _price * _quantity;   
                        for "_i" from 1 to _quantity do {   
                            private _index = _playerCommodities findIf {(_x select 0) isEqualTo _commodityName};   
                            if (_index != -1) then {   
                                _playerCommodities deleteAt _index;   
                            };   
                        };   
                           
                        profileNamespace setVariable [_playerUID + "_commodities", _playerCommodities];        
                        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];        
                        _bankMoney = _bankMoney + _totalValue;        
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];        
                        saveProfileNamespace;        
                           
                        [format ["<t size='0.7' color='#00ff00'>Sold %1 shares of %2 for <t color='#FFFFFF'>$%3</t></t>",    
                            _quantity, _commodityName, _totalValue], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    } else {        
                        ["<t size='0.7' color='#ff0000'>You don't own enough shares!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    };        
                };        
            }];        
   
            private _closeBtn = _display ctrlCreate ["RscButton", 6];        
            _closeBtn ctrlSetText "Close";        
            _closeBtn ctrlSetPosition [0.325, 0.72, 0.35, 0.05];        
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
        "<t color='#FFD700'>Headgear Shop</t>",    
        {    
            private _headgear = [    
    ["H_HelmetB", "Combat Helmet", 300],  
    ["H_HelmetSpecB", "Enhanced Combat Helmet", 500],  
    ["H_HelmetB_light", "Light Combat Helmet", 250],  
    ["H_HelmetB_black", "Black Combat Helmet", 350],  
    ["H_HelmetHBK_headset_F", "HBK Helmet with Headset", 400],  
    ["H_HelmetHBK_chops_F", "HBK Helmet with Chops", 400],  
    ["H_HelmetHBK_ear_F", "HBK Helmet with Ear Protection", 400],  
    ["H_HelmetHBK_F", "HBK Helmet", 350],  
    ["H_HelmetSpecO_blk", "Special Purpose Helmet Black", 450],  
    ["H_HelmetSpecO_ghex_F", "Special Purpose Helmet Green Hex", 450],  
    ["H_HelmetSpecO_ocamo", "Special Purpose Helmet Ocamo", 450],  
    ["H_HelmetAggressor_F", "Aggressor Helmet", 500],  
    ["H_HelmetAggressor_cover_F", "Aggressor Helmet (Cover)", 525],  
    ["H_HelmetAggressor_cover_taiga_F", "Aggressor Helmet (Taiga)", 525],  
    ["H_PASGT_basic_black_F", "PASGT Basic Black", 300],  
    ["H_PASGT_basic_blue_F", "PASGT Basic Blue", 300],  
    ["H_PASGT_basic_olive_F", "PASGT Basic Olive", 300],  
    ["H_PASGT_basic_white_F", "PASGT Basic White", 300],  
    ["H_HelmetB_camo", "Combat Helmet (Camo)", 350],  
    ["H_HelmetB_desert", "Combat Helmet (Desert)", 350],  
    ["H_HelmetB_grass", "Combat Helmet (Grass)", 350],  
    ["H_HelmetB_sand", "Combat Helmet (Sand)", 350],  
    ["H_HelmetB_snakeskin", "Combat Helmet (Snakeskin)", 350],  
    ["H_HelmetB_tna_F", "Combat Helmet (Tna)", 350],  
    ["H_HelmetB_plain_wdl", "Combat Helmet (Woodland)", 350],  
    ["H_HelmetCrew_O_ghex_F", "Crew Helmet Green Hex", 400],  
    ["H_Tank_black_F", "Tank Crew Helmet Black", 400],  
    ["H_HelmetCrew_I", "Crew Helmet AAF", 400],  
    ["H_HelmetCrew_O", "Crew Helmet CSAT", 400],  
    ["H_HelmetCrew_B", "Crew Helmet NATO", 400],  
    ["H_HelmetLeaderO_ghex_F", "Leader Helmet Green Hex", 600],  
    ["H_HelmetLeaderO_ocamo", "Leader Helmet Ocamo", 600],  
    ["H_HelmetLeaderO_oucamo", "Leader Helmet Urban", 600],  
    ["H_HelmetSpecB_blk", "Enhanced Combat Helmet Black", 550],  
    ["H_HelmetSpecB_paint2", "Enhanced Combat Helmet Paint 2", 550],  
    ["H_HelmetSpecB_paint1", "Enhanced Combat Helmet Paint 1", 550],  
    ["H_HelmetSpecB_sand", "Enhanced Combat Helmet Sand", 550],  
    ["H_HelmetSpecB_snakeskin", "Enhanced Combat Helmet Snakeskin", 550],  
    ["H_HelmetB_Enh_tna_F", "Enhanced Combat Helmet Tna", 550],  
    ["H_HelmetSpecB_wdl", "Enhanced Combat Helmet Woodland", 550],  
    ["H_CrewHelmetHeli_I", "Heli Crew Helmet AAF", 450],  
    ["H_CrewHelmetHeli_O", "Heli Crew Helmet CSAT", 450],  
    ["H_CrewHelmetHeli_B", "Heli Crew Helmet NATO", 450],  
    ["H_PilotHelmetHeli_I", "Heli Pilot Helmet AAF", 500],  
    ["H_PilotHelmetHeli_O", "Heli Pilot Helmet CSAT", 500],  
    ["H_PilotHelmetHeli_B", "Heli Pilot Helmet NATO", 500],  
    ["H_HelmetB_light_black", "Light Combat Helmet Black", 300],  
    ["H_HelmetB_light_desert", "Light Combat Helmet Desert", 300],  
    ["H_HelmetB_light_grass", "Light Combat Helmet Grass", 300],  
    ["H_HelmetB_light_sand", "Light Combat Helmet Sand", 300],  
    ["H_HelmetB_light_snakeskin", "Light Combat Helmet Snakeskin", 300],  
    ["H_HelmetB_Light_tna_F", "Light Combat Helmet Tna", 300],  
    ["H_HelmetB_light_wdl", "Light Combat Helmet Woodland", 300],  
    ["H_PilotHelmetFighter_I", "Fighter Pilot Helmet AAF", 600],  
    ["H_PilotHelmetFighter_O", "Fighter Pilot Helmet CSAT", 600],  
    ["H_PilotHelmetFighter_B", "Fighter Pilot Helmet NATO", 600],  
    ["H_PASGT_basic_blue_press_F", "Press Helmet Basic", 200],  
    ["H_PASGT_neckprot_blue_press_F", "Press Helmet with Neck Protection", 250],  
    ["H_HelmetO_ghex_F", "CSAT Helmet Green Hex", 400],  
    ["H_HelmetO_ocamo", "CSAT Helmet Ocamo", 400],  
    ["H_HelmetO_oucamo", "CSAT Helmet Urban", 400],  
    ["H_RacingHelmet_1_black_F", "Racing Helmet Black", 200],  
    ["H_RacingHelmet_1_blue_F", "Racing Helmet Blue", 200],  
    ["H_RacingHelmet_2_F", "Racing Helmet 2", 200],  
    ["H_RacingHelmet_1_F", "Racing Helmet 1", 200],  
    ["H_RacingHelmet_1_green_F", "Racing Helmet Green", 200],  
    ["H_RacingHelmet_1_orange_F", "Racing Helmet Orange", 200],  
    ["H_RacingHelmet_1_red_F", "Racing Helmet Red", 200],  
    ["H_RacingHelmet_3_F", "Racing Helmet 3", 200],  
    ["H_RacingHelmet_4_F", "Racing Helmet 4", 200],  
    ["H_RacingHelmet_1_white_F", "Racing Helmet White", 200],  
    ["H_RacingHelmet_1_yellow_F", "Racing Helmet Yellow", 200],  
    ["H_HelmetO_ViperSP_ghex_F", "Special Purpose Helmet (Green Hex)", 800],  
    ["H_HelmetO_ViperSP_hex_F", "Special Purpose Helmet (Hex)", 800],  
    ["H_HelmetB_TI_tna_F", "Thermal Combat Helmet (Tna)", 1000],  
    ["H_HelmetB_TI_arid_F", "Thermal Combat Helmet (Arid)", 1000],  
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
            _bg ctrlSetPosition [0.2, 0.2, 0.8, 0.05];    
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
            } forEach _headgear;    
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
                    [player, _itemClass, _price] remoteExec ["fnc_purchaseHeadgear", 2];    
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
    fnc_purchaseHeadgear = {    
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
    publicVariable "fnc_purchaseHeadgear";    
};   





   
{    
    _x addAction [    
        "<t color='#FFD700'>Uniform Shop</t>",    
        {    
            private _uniforms = [    
    ["U_C_IDAP_Man_cargo_F", "IDAP Cargo", 150],   
    ["U_C_IDAP_Man_jeans_F", "IDAP Jeans", 120],   
    ["U_C_IDAP_Man_Casual_F", "IDAP Casual", 130],   
    ["U_C_IDAP_Man_shorts_F", "IDAP Shorts", 100],   
    ["U_C_IDAP_Man_tee_F", "IDAP T-Shirt", 90],   
    ["U_C_IDAP_Man_teeshorts_F", "IDAP T-Shirt & Shorts", 110],   
    ["U_I_C_Soldier_Bandit_4_F", "Bandit Clothes 4", 200],   
    ["U_I_C_Soldier_Bandit_1_F", "Bandit Clothes 1", 200],   
    ["U_I_C_Soldier_Bandit_2_F", "Bandit Clothes 2", 200],   
    ["U_I_C_Soldier_Bandit_5_F", "Bandit Clothes 5", 200],   
    ["U_I_C_Soldier_Bandit_3_F", "Bandit Clothes 3", 200],   
    ["U_C_ArtTShirt_01_v6_F", "Art T-Shirt 6", 80],   
    ["U_C_ArtTShirt_01_v1_F", "Art T-Shirt 1", 80],   
    ["U_C_Man_casual_2_F", "Casual Outfit 2", 100],   
    ["U_C_ArtTShirt_01_v2_F", "Art T-Shirt 2", 80],   
    ["U_C_ArtTShirt_01_v4_F", "Art T-Shirt 4", 80],   
    ["U_C_Man_casual_3_F", "Casual Outfit 3", 100],   
    ["U_C_Man_casual_1_F", "Casual Outfit 1", 100],   
    ["U_C_ArtTShirt_01_v5_F", "Art T-Shirt 5", 80],   
    ["U_C_ArtTShirt_01_v3_F", "Art T-Shirt 3", 80],   
    ["U_C_CBRN_Suit_01_Blue_F", "CBRN Suit Blue", 1000],   
    ["U_B_CBRN_Suit_01_MTP_F", "CBRN Suit MTP", 1000],   
    ["U_B_CBRN_Suit_01_Tropic_F", "CBRN Suit Tropic", 1000],   
    ["U_C_CBRN_Suit_01_White_F", "CBRN Suit White", 1000],   
    ["U_B_CBRN_Suit_01_Wdl_F", "CBRN Suit Woodland", 1000],   
    ["U_I_CBRN_Suit_01_AAF_F", "CBRN Suit AAF", 1000],   
    ["U_I_E_CBRN_Suit_01_EAF_F", "CBRN Suit EAF", 1000],   
    ["U_B_CombatUniform_mcam", "Combat Uniform MTP", 300],   
    ["U_B_CombatUniform_mcam_tshirt", "Combat Uniform MTP T-Shirt", 280],   
    ["U_I_E_Uniform_01_officer_F", "Combat Uniform Officer", 350],   
    ["U_I_E_Uniform_01_shortsleeve_F", "Combat Uniform Shortsleeve", 280],   
    ["U_I_G_resistanceLeader_F", "Combat Uniform Resistance", 400],   
    ["U_I_E_Uniform_01_sweater_F", "Combat Uniform Sweater", 300],   
    ["U_I_E_Uniform_01_tanktop_F", "Combat Uniform Tank Top", 250],   
    ["U_B_T_Soldier_F", "Combat Uniform Tropical", 300],   
    ["U_B_T_Soldier_AR_F", "Combat Uniform Tropical AR", 320],   
    ["U_B_CombatUniform_mcam_wdl_f", "Combat Uniform Woodland", 300],   
    ["U_B_CombatUniform_tshirt_mcam_wdL_f", "Combat Uniform Woodland T-Shirt", 280],   
    ["U_I_CombatUniform", "Combat Uniform", 300],   
    ["U_I_OfficerUniform", "Officer Uniform", 350],   
    ["U_I_CombatUniform_shortsleeve", "Combat Uniform Shortsleeve", 280],   
    ["U_I_E_Uniform_01_F", "Combat Uniform", 300],   
    ["U_C_Poloshirt_blue", "Polo Blue", 50],   
    ["U_C_Poloshirt_burgundy", "Polo Burgundy", 50],   
    ["U_C_Poloshirt_redwhite", "Polo Red/White", 50],   
    ["U_C_Poloshirt_salmon", "Polo Salmon", 50],   
    ["U_C_Poloshirt_stripped", "Polo Stripped", 50],   
    ["U_C_Poloshirt_tricolour", "Polo Tricolor", 50],   
    ["U_Competitor", "Competitor Suit", 150],   
    ["U_C_ConstructionCoverall_Black_F", "Construction Coverall Black", 120],   
    ["U_C_ConstructionCoverall_Blue_F", "Construction Coverall Blue", 120],   
    ["U_C_ConstructionCoverall_Red_F", "Construction Coverall Red", 120],   
    ["U_C_ConstructionCoverall_Vrana_F", "Construction Coverall Vrana", 120],   
    ["U_B_CTRG_1", "CTRG Combat Uniform", 400],   
    ["U_B_CTRG_3", "CTRG Combat Uniform 3", 400],   
    ["U_B_CTRG_2", "CTRG Combat Uniform 2", 400],   
    ["U_B_CTRG_Soldier_F", "CTRG Stealth Uniform", 500],   
    ["U_B_CTRG_Soldier_arid_F", "CTRG Stealth Uniform Arid", 500],   
    ["U_B_CTRG_Soldier_3_F", "CTRG Stealth Uniform 3", 500],   
    ["U_B_CTRG_Soldier_3_arid_F", "CTRG Stealth Uniform 3 Arid", 500],   
    ["U_B_CTRG_Soldier_2_F", "CTRG Stealth Uniform 2", 500],   
    ["U_B_CTRG_Soldier_2_arid_F", "CTRG Stealth Uniform 2 Arid", 500],   
    ["U_B_CTRG_Soldier_urb_1_F", "CTRG Urban Uniform", 500],   
    ["U_B_CTRG_Soldier_urb_3_F", "CTRG Urban Uniform 3", 500],   
    ["U_B_CTRG_Soldier_urb_2_F", "CTRG Urban Uniform 2", 500],   
    ["U_I_L_Uniform_01_camo_F", "Combat Uniform Camo", 300],   
    ["U_I_L_Uniform_01_deserter_F", "Deserter Uniform", 200],   
    ["U_C_Driver_1_black", "Driver Coverall Black", 150],   
    ["U_C_Driver_1_blue", "Driver Coverall Blue", 150],   
    ["U_C_Driver_2", "Driver Coverall 2", 150],   
    ["U_C_Driver_1", "Driver Coverall", 150],   
    ["U_C_Driver_1_green", "Driver Coverall Green", 150],   
    ["U_C_Driver_1_orange", "Driver Coverall Orange", 150],   
    ["U_C_Driver_1_red", "Driver Coverall Red", 150],   
    ["U_C_Driver_3", "Driver Coverall 3", 150],   
    ["U_C_Driver_4", "Driver Coverall 4", 150],   
    ["U_C_Driver_1_white", "Driver Coverall White", 150],   
    ["U_C_Driver_1_yellow", "Driver Coverall Yellow", 150],   
    ["U_C_Uniform_Farmer_01_F", "Farmer Clothes", 100],   
    ["U_O_T_Soldier_F", "Fatigues [CSAT]", 300],   
    ["U_O_CombatUniform_ocamo", "Fatigues [Hex]", 300],   
    ["U_O_CombatUniform_oucamo", "Fatigues [Urban]", 300],   
    ["U_C_FormalSuit_01_black_F", "Formal Suit Black", 200],   
    ["U_B_GEN_Commander_F", "Gendarmerie Commander Uniform", 350],   
    ["U_B_GEN_Soldier_F", "Gendarmerie Uniform", 300],   
    ["U_O_T_Sniper_F", "Ghillie Suit [CSAT]", 800],   
    ["U_B_T_Sniper_F", "Ghillie Suit [NATO]", 800],   
    ["U_I_GhillieSuit", "Ghillie Suit [AAF]", 800],   
    ["U_O_GhillieSuit", "Ghillie Suit [CSAT]", 800],   
    ["U_B_GhillieSuit", "Ghillie Suit [NATO]", 800],   
    ["U_O_R_Gorka_01_F", "Gorka Suit", 400],   
    ["U_O_R_Gorka_01_brown_F", "Gorka Suit Brown", 400],   
    ["U_I_ParadeUniform_01_AAF_decorated_F", "Parade Uniform [AAF]", 500],   
    ["U_O_ParadeUniform_01_CSAT_decorated_F", "Parade Uniform [CSAT]", 500],   
    ["U_I_E_ParadeUniform_01_LDF_decorated_F", "Parade Uniform [LDF]", 500],   
    ["U_B_ParadeUniform_01_US_decorated_F", "Parade Uniform [US]", 500],   
    ["U_C_FormalSuit_01_blue_F", "Formal Suit Blue", 200],   
    ["U_C_FormalSuit_01_gray_F", "Formal Suit Gray", 200],   
    ["U_C_FormalSuit_01_khaki_F", "Formal Suit Khaki", 200],   
    ["U_C_FormalSuit_01_tshirt_black_F", "Formal Suit with T-shirt Black", 180],   
    ["U_C_FormalSuit_01_tshirt_gray_F", "Formal Suit with T-shirt Gray", 180],   
    ["U_I_FullGhillie_ard", "Full Ghillie [AAF]", 1000],   
    ["U_O_FullGhillie_ard", "Full Ghillie [CSAT]", 1000],   
    ["U_B_FullGhillie_ard", "Full Ghillie [NATO]", 1000],   
    ["U_O_T_FullGhillie_tna_F", "Full Ghillie (Jungle) [CSAT]", 1000],   
    ["U_B_T_FullGhillie_tna_F", "Full Ghillie (Jungle) [NATO]", 1000],   
    ["U_I_FullGhillie_lsh", "Full Ghillie (Lush) [AAF]", 1000],   
    ["U_O_FullGhillie_lsh", "Full Ghillie (Lush) [CSAT]", 1000],   
    ["U_B_FullGhillie_lsh", "Full Ghillie (Lush) [NATO]", 1000],   
    ["U_I_FullGhillie_sard", "Full Ghillie (Semi-Arid) [AAF]", 1000],   
    ["U_O_FullGhillie_sard", "Full Ghillie (Semi-Arid) [CSAT]", 1000],   
    ["U_B_FullGhillie_sard", "Full Ghillie (Semi-Arid) [NATO]", 1000],   
    ["U_O_R_Gorka_01_camo_F", "Gorka Suit Camo", 400],   
    ["U_BG_Guerrilla_6_1", "Guerilla Apparel", 200],   
    ["U_BG_Guerilla1_1", "Guerilla Garment", 200],   
    ["U_BG_Guerilla1_2_F", "Guerilla Outfit", 200],   
    ["U_BG_Guerilla2_2", "Guerilla Outfit 2", 200],   
    ["U_BG_Guerilla2_1", "Guerilla Outfit 3", 200],   
    ["U_BG_Guerilla2_3", "Guerilla Outfit 4", 200],   
    ["U_BG_Guerilla3_1", "Guerilla Smocks", 200],   
    ["U_BG_leader", "Guerilla Uniform", 250],   
    ["U_I_HeliPilotCoveralls", "Heli Pilot Coveralls [AAF]", 300],   
    ["U_I_E_Uniform_01_coveralls_F", "Heli Pilot Coveralls [LDF]", 300],   
    ["U_B_HeliPilotCoveralls", "Heli Pilot Coveralls [NATO]", 300],   
    ["U_C_HunterBody_grn", "Hunter Clothes", 150],   
    ["U_OrestesBody", "Jacket and Shorts", 100],   
    ["U_C_Journalist", "Journalist Clothes", 100],   
    ["U_O_officer_noInsignia_hex_F", "Light Combat Uniform", 250],   
    ["U_C_E_LooterJacket_01_F", "Looter Jacket", 150],   
    ["U_I_L_Uniform_01_tshirt_black_F", "Looter T-Shirt Black", 80],   
    ["U_I_L_Uniform_01_tshirt_olive_F", "Looter T-Shirt Olive", 80],   
    ["U_I_L_Uniform_01_tshirt_skull_F", "Looter T-Shirt Skull", 80],   
     ["U_I_L_Uniform_01_tshirt_sport_F", "Looter T-Shirt Sport", 80],   
    ["U_Marshal", "Marshal Clothes", 200],   
    ["U_C_Mechanic_01_F", "Mechanic Clothes", 120],   
    ["U_O_T_Officer_F", "Officer Fatigues", 350],   
    ["U_O_OfficerUniform_ocamo", "Officer Uniform [CSAT]", 350],   
    ["U_I_ParadeUniform_01_AAF_F", "Parade Uniform [AAF]", 400],   
    ["U_O_ParadeUniform_01_CSAT_F", "Parade Uniform [CSAT]", 400],   
    ["U_I_E_ParadeUniform_01_LDF_F", "Parade Uniform [LDF]", 400],   
    ["U_B_ParadeUniform_01_US_F", "Parade Uniform [US]", 400],   
    ["U_C_Paramedic_01_F", "Paramedic Uniform", 200],   
    ["U_I_C_Soldier_Para_2_F", "Paramilitary Garb 2", 250],   
    ["U_I_C_Soldier_Para_3_F", "Paramilitary Garb 3", 250],   
    ["U_I_C_Soldier_Para_5_F", "Paramilitary Garb 5", 250],   
    ["U_I_C_Soldier_Para_4_F", "Paramilitary Garb 4", 250],   
    ["U_I_C_Soldier_Para_1_F", "Paramilitary Garb 1", 250],   
    ["U_I_pilotCoveralls", "Pilot Coveralls [AAF]", 300],   
    ["U_O_PilotCoveralls", "Pilot Coveralls [CSAT]", 300],   
    ["U_B_PilotCoveralls", "Pilot Coveralls [NATO]", 300],   
    ["U_Rangemaster", "Rangemaster Suit", 150],   
    ["U_O_SpecopsUniform_ocamo", "Recon Fatigues", 450],   
    ["U_B_CombatUniform_mcam_vest", "Recon Combat Uniform", 450],   
    ["U_B_T_Soldier_SL_F", "Recon Fatigues [NATO]", 450],   
    ["U_B_CombatUniform_vest_mcam_wdl_f", "Recon Uniform [Woodland]", 450],   
    ["U_C_Scientist", "Scientist Uniform", 200],   
    ["U_C_Uniform_Scientist_01_formal_F", "Scientist Uniform Formal", 250],   
    ["U_C_Uniform_Scientist_01_F", "Scientist Uniform 1", 200],   
    ["U_C_Uniform_Scientist_02_F", "Scientist Uniform 2", 200],   
    ["U_C_Uniform_Scientist_02_formal_F", "Scientist Uniform 2 Formal", 250],   
    ["U_O_V_Soldier_Viper_F", "Special Purpose Suit [CSAT]", 800],   
    ["U_O_V_Soldier_Viper_hex_F", "Special Purpose Suit [Hex]", 800],   
    ["U_C_man_sport_1_F", "Sport Clothes (Blue)", 100],   
    ["U_C_man_sport_3_F", "Sport Clothes (Green)", 100],   
    ["U_C_man_sport_2_F", "Sport Clothes (Red)", 100],   
    ["U_C_Man_casual_6_F", "Summer Clothes 1", 100],   
    ["U_C_Man_casual_4_F", "Summer Clothes 2", 100],   
    ["U_C_Man_casual_5_F", "Summer Clothes 3", 100],   
    ["U_B_survival_uniform", "Survival Fatigues", 350],   
    ["U_I_C_Soldier_Camo_F", "Syndikat Uniform", 250],   
    ["U_Tank_green_F", "Tanker Suit [AAF]", 300],   
    ["U_O_R_Gorka_01_black_F", "Tactical Uniform Black", 400],   
    ["U_I_Protagonist_VR", "VR Suit [AAF]", 1000],   
    ["U_O_Protagonist_VR", "VR Suit [CSAT]", 1000],   
    ["U_B_Protagonist_VR", "VR Suit [NATO]", 1000],   
    ["U_I_Wetsuit", "Wetsuit [AAF]", 600],   
    ["U_O_Wetsuit", "Wetsuit [CSAT]", 600],   
    ["U_B_Wetsuit", "Wetsuit [NATO]", 600],   
    ["U_C_WorkerCoveralls", "Worker Coveralls", 120],   
    ["U_C_Poor_1", "Poor Clothes", 50],   
    ["U_I_G_Story_Protagonist_F", "Worn Combat Fatigues", 200],   
    ["U_B_CombatUniform_mcam_worn", "Worn Combat Uniform", 200]   
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
        "<t color='#FFD700'>Inventory Items Shop</t>",    
        {         
            private _inventoryItems = [    
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
            _title ctrlSetText "Inventory Items Shop";    
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
            } forEach _inventoryItems;    
   
            private _buyBtn = _display ctrlCreate ["RscButton", 5];    
            _buyBtn ctrlSetText "Purchase Item";    
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
                    [player, _itemClass, _price] remoteExec ["fnc_purchaseInventoryItems", 2];    
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
    fnc_purchaseInventoryItems = {    
        params ["_player", "_itemClass", "_price"];    
        private _playerUID = getPlayerUID _player;    
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];    
   
        if (_bankMoney >= _price) then {    
            if (_itemClass select [0,4] == "Item") then {    
                _player linkItem _itemClass;    
            } else {    
                if (_itemClass == "Binocular") then {    
                    _player addWeapon _itemClass;    
                } else {    
                    _player addItem _itemClass;    
                };    
            };    
            _bankMoney = _bankMoney - _price;    
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];    
            saveProfileNamespace;    
            [format ["<t size='0.7' color='#00ff00'>Item purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
        } else {    
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
        };    
    };    
   
    publicVariable "fnc_purchaseInventoryItems";    
};   
      
   





   
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
} forEach (allMissionObjects "C_man_shorts_1_F");   
   
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
    _x addAction ["<t color='#FFD700'>Launchers</t>", {   
        private _weapons = [   
   ["launch_O_Vorona_brown_F", "9M135 Vorona (Brown)", 15000, ["Vorona_HEAT"]],   
   ["launch_O_Vorona_green_F", "9M135 Vorona (Green)", 15000, ["Vorona_HEAT"]],   
   ["launch_MRAWS_green_rail_F", "MAAWS Mk4 Mod 1 (Green)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_MRAWS_olive_rail_F", "MAAWS Mk4 Mod 1 (Olive)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_MRAWS_sand_rail_F", "MAAWS Mk4 Mod 1 (Sand)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_MRAWS_green_F", "MAAWS Mk4 Mod 0 (Green)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_MRAWS_olive_F", "MAAWS Mk4 Mod 0 (Olive)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_MRAWS_sand_F", "MAAWS Mk4 Mod 0 (Sand)", 12000, ["MRAWS_HEAT_F"]],   
   ["launch_NLAW_F", "PCML", 8000, ["NLAW_F"]],   
   ["launch_RPG32_green_F", "RPG-42 (Green)", 10000, ["RPG32_F"]],   
   ["launch_RPG32_F", "RPG-42", 10000, ["RPG32_F"]],   
   ["launch_RPG32_ghex_F", "RPG-42 (Green Hex)", 10000, ["RPG32_F"]],   
   ["launch_RPG7_F", "RPG-7", 9000, ["RPG7_F"]],   
   ["launch_I_Titan_F", "Titan MPRL (Digital)", 20000, ["Titan_AA"]],   
   ["launch_I_Titan_eaf_F", "Titan MPRL (Geometric)", 20000, ["Titan_AA"]],   
   ["launch_O_Titan_ghex_F", "Titan MPRL (Green Hex)", 20000, ["Titan_AA"]],   
   ["launch_O_Titan_F", "Titan MPRL (Hex)", 20000, ["Titan_AA"]],   
   ["launch_B_Titan_olive_F", "Titan MPRL (Olive)", 20000, ["Titan_AA"]],   
   ["launch_B_Titan_F", "Titan MPRL", 20000, ["Titan_AA"]],   
   ["launch_B_Titan_tna_F", "Titan MPRL (Tropic)", 20000, ["Titan_AA"]],   
   ["launch_O_Titan_short_F", "Titan MPRL Compact (Hex)", 18000, ["Titan_AT"]],   
   ["launch_O_Titan_short_ghex_F", "Titan MPRL Compact (Green Hex)", 18000, ["Titan_AT"]],   
   ["launch_I_Titan_short_F", "Titan MPRL Compact (Digital)", 18000, ["Titan_AT"]],   
   ["launch_B_Titan_short_F", "Titan MPRL Compact", 18000, ["Titan_AT"]],   
   ["launch_B_Titan_short_tna_F", "Titan MPRL Compact (Tropic)", 18000, ["Titan_AT"]]   
        ];   
           
        private _mags = [   
   ["Vorona_HEAT", "Vorona HEAT Missile", 3000],   
   ["Vorona_HE", "Vorona HE Missile", 3000],   
   ["MRAWS_HEAT_F", "MAAWS HEAT Round", 2500],   
   ["MRAWS_HE_F", "MAAWS HE Round", 2500],   
   ["NLAW_F", "PCML Missile", 2000],   
   ["RPG32_F", "RPG-42 Rocket", 2000],   
   ["RPG32_HE_F", "RPG-42 HE Rocket", 2000],   
   ["RPG7_F", "RPG-7 Rocket", 1800],   
   ["Titan_AA", "Titan AA Missile", 4000],   
   ["Titan_AT", "Titan AT Missile", 4000],   
   ["Titan_AP", "Titan AP Missile", 4000]   
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
} forEach (allMissionObjects "C_Marshal_F");   
   
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
        "<t color='#FFD700'>Explosives Shop</t>",    
        {         
   private _equipment = [   
    ["TrainingMine_Mag", "Training Mine", 100],   
    ["IEDUrbanSmall_Remote_Mag", "Small IED (Urban)", 800],   
    ["IEDLandSmall_Remote_Mag", "Small IED (Land)", 800],   
    ["SLAMDirectionalMine_Wire_Mag", "M6 SLAM Mine", 1000],   
    ["IEDUrbanBig_Remote_Mag", "Large IED (Urban)", 1200],   
    ["IEDLandBig_Remote_Mag", "Large IED (Land)", 1200],   
    ["SatchelCharge_Remote_Mag", "Satchel Charge", 1500],   
    ["DemoCharge_Remote_Mag", "Demo Charge", 1000],   
    ["ClaymoreDirectionalMine_Remote_Mag", "Claymore Mine", 800],   
    ["ATMine_Range_Mag", "AT Mine", 1200],   
    ["APERSTripMine_Wire_Mag", "APERS Tripwire Mine", 600],   
    ["APERSMine_Range_Mag", "APERS Mine", 500],   
    ["APERSBoundingMine_Range_Mag", "APERS Bounding Mine", 700]   
            ];   
   
    
   
            createDialog "RscDisplayEmpty";    
            private _display = findDisplay -1;    
   
            private _bg = _display ctrlCreate ["RscText", 1];    
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6];    
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];    
            _bg ctrlCommit 0;    
   
            private _title = _display ctrlCreate ["RscText", 2];    
            _title ctrlSetText "Explosives Shop";    
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
                _listBox lbSetPictureRight [_index, getText (configFile >> "CfgMagazines" >> _class >> "picture")];    
                _listBox lbSetPictureRightColor [_index, [1, 1, 1, 1]];    
            } forEach _equipment;    
   
            private _buyBtn = _display ctrlCreate ["RscButton", 5];    
            _buyBtn ctrlSetText "Purchase Explosive";    
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
} forEach (allMissionObjects "C_man_sport_3_F");   
   
if (isServer) then {    
    fnc_purchaseEquipment = {    
        params ["_player", "_itemClass", "_price"];    
        private _playerUID = getPlayerUID _player;    
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];    
   
        if (_bankMoney >= _price) then {    
            _player addMagazine _itemClass;    
            _bankMoney = _bankMoney - _price;    
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];    
            saveProfileNamespace;    
            [format ["<t size='0.7' color='#00ff00'>Explosive purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
        } else {    
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];    
        };    
    };    
   
    publicVariable "fnc_purchaseEquipment";    
};   





   
{   
    _x addAction ["<t color='#FFD700'>LMG Shop</t>", {   
  private _weapons = [   
   ["LMG_03_F", "LMG-3 6.5mm", 15000, ["200Rnd_556x45_Box_F"]],   
   ["LMG_Mk200_F", "Mk200 6.5mm", 18000, ["200Rnd_65x39_cased_Box"]],   
   ["LMG_Mk200_black_F", "Mk200 Black 6.5mm", 18500, ["200Rnd_65x39_cased_Box"]],   
   ["arifle_MX_SW_F", "MX SW 6.5mm", 12000, ["100Rnd_65x39_caseless_mag"]],   
   ["arifle_MX_SW_Black_F", "MX SW Black 6.5mm", 12500, ["100Rnd_65x39_caseless_mag"]],   
   ["arifle_MX_SW_khk_F", "MX SW Khaki 6.5mm", 12500, ["100Rnd_65x39_caseless_mag"]],   
   ["MMG_01_hex_F", "Navid Hex 9.3mm", 25000, ["150Rnd_93x64_Mag"]],   
   ["MMG_01_tan_F", "Navid Tan 9.3mm", 25000, ["150Rnd_93x64_Mag"]],   
   ["MMG_02_black_F", "SPMG Black .338", 22000, ["130Rnd_338_Mag"]],   
   ["MMG_02_camo_F", "SPMG Camo .338", 22000, ["130Rnd_338_Mag"]],   
   ["MMG_02_sand_F", "SPMG Sand .338", 22000, ["130Rnd_338_Mag"]],   
   ["LMG_Zafir_F", "Zafir 7.62mm", 20000, ["150Rnd_762x54_Box"]]   
  ];   
   
  private _mags = [   
   ["200Rnd_556x45_Box_F", "5.56mm Box", 800],   
   ["200Rnd_65x39_cased_Box", "6.5mm Box", 1000],   
   ["100Rnd_65x39_caseless_mag", "6.5mm Caseless", 600],   
   ["150Rnd_93x64_Mag", "9.3mm Box", 1500],   
   ["130Rnd_338_Mag", ".338 Box", 1200],   
   ["150Rnd_762x54_Box", "7.62mm Box", 1000]   
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
} forEach (allMissionObjects "C_IDAP_Man_AidWorker_02_F");   
   
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
    _x addAction ["<t color='#FFD700'>Sniper Shop</t>", {   
  private _weapons = [   
   ["srifle_DMR_04_F", "ASP-1 Kir 12.7mm", 22000, ["10Rnd_127x54_Mag"]],   
   ["srifle_DMR_04_Tan_F", "ASP-1 Kir Tan 12.7mm", 22500, ["10Rnd_127x54_Mag"]],   
   ["srifle_DMR_07_blk_F", "CMR-76 Black 6.5mm", 18000, ["20Rnd_650x39_Cased_Mag_F"]],   
   ["srifle_DMR_07_ghex_F", "CMR-76 GHEX 6.5mm", 18000, ["20Rnd_650x39_Cased_Mag_F"]],   
   ["srifle_DMR_07_hex_F", "CMR-76 Hex 6.5mm", 18000, ["20Rnd_650x39_Cased_Mag_F"]],   
   ["srifle_DMR_05_blk_F", "Cyrus Black 9.3mm", 24000, ["10Rnd_93x64_DMR_05_Mag"]],   
   ["srifle_DMR_05_hex_F", "Cyrus Hex 9.3mm", 24000, ["10Rnd_93x64_DMR_05_Mag"]],   
   ["srifle_DMR_05_tan_f", "Cyrus Tan 9.3mm", 24000, ["10Rnd_93x64_DMR_05_Mag"]],   
   ["srifle_GM6_F", "GM6 Lynx 12.7mm", 32000, ["5Rnd_127x108_Mag"]],   
   ["srifle_GM6_camo_F", "GM6 Lynx Camo 12.7mm", 32500, ["5Rnd_127x108_Mag"]],   
   ["srifle_GM6_ghex_F", "GM6 Lynx GHEX 12.7mm", 32500, ["5Rnd_127x108_Mag"]],   
   ["srifle_LRR_F", "M320 LRR .408", 30000, ["7Rnd_408_Mag"]],   
   ["srifle_LRR_camo_F", "M320 LRR Camo .408", 30500, ["7Rnd_408_Mag"]],   
   ["srifle_LRR_tna_F", "M320 LRR Tropic .408", 30500, ["7Rnd_408_Mag"]],   
   ["srifle_DMR_02_F", "MAR-10 .338", 28000, ["10Rnd_338_Mag"]],   
   ["srifle_DMR_02_camo_F", "MAR-10 Camo .338", 28500, ["10Rnd_338_Mag"]],   
   ["srifle_DMR_02_sniper_F", "MAR-10 Sand .338", 28500, ["10Rnd_338_Mag"]],   
   ["srifle_DMR_03_F", "Mk-I EMR 7.62mm", 20000, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_03_multicam_F", "Mk-I EMR Camo 7.62mm", 20500, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_03_khaki_F", "Mk-I EMR Khaki 7.62mm", 20500, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_03_tan_F", "Mk-I EMR Tan 7.62mm", 20500, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_03_woodland_F", "Mk-I EMR Woodland 7.62mm", 20500, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_06_camo_F", "Mk14 Camo 7.62mm", 19000, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_06_hunter_F", "Mk14 Hunter 7.62mm", 19000, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_06_olive_F", "Mk14 Olive 7.62mm", 19000, ["20Rnd_762x51_Mag"]],   
   ["srifle_EBR_F", "Mk18 ABR 7.62mm", 21000, ["20Rnd_762x51_Mag"]],   
   ["srifle_DMR_01_F", "Rahim 7.62mm", 18500, ["10Rnd_762x54_Mag"]]   
  ];   
   
  private _mags = [   
   ["10Rnd_127x54_Mag", "12.7mm Mag", 400],   
   ["20Rnd_650x39_Cased_Mag_F", "6.5mm Mag", 300],   
   ["10Rnd_93x64_DMR_05_Mag", "9.3mm Mag", 450],   
   ["5Rnd_127x108_Mag", "12.7mm Mag", 600],   
   ["7Rnd_408_Mag", ".408 Mag", 550],   
   ["10Rnd_338_Mag", ".338 Mag", 500],   
   ["20Rnd_762x51_Mag", "7.62mm Mag", 350],   
   ["10Rnd_762x54_Mag", "7.62mm Mag", 300]   
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
} forEach (allMissionObjects "C_man_p_fugitive_F");   
   
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
    _x addAction ["<t color='#FFD700'>SMG Shop</t>", {   
  private _weapons = [   
   ["SMG_03_black", "P90 Black 5.7mm", 8000, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_camo", "P90 Camo 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_hex", "P90 Hex 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_khaki", "P90 Khaki 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_TR_black", "P90 TR Black 5.7mm", 8500, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_TR_camo", "P90 TR Camo 5.7mm", 8700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_TR_hex", "P90 TR Hex 5.7mm", 8700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03_TR_khaki", "P90 TR Khaki 5.7mm", 8700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_black", "P90C Black 5.7mm", 7500, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_camo", "P90C Camo 5.7mm", 7700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_hex", "P90C Hex 5.7mm", 7700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_khaki", "P90C Khaki 5.7mm", 7700, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_TR_black", "P90C TR Black 5.7mm", 8000, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_TR_camo", "P90C TR Camo 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_TR_hex", "P90C TR Hex 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["SMG_03C_TR_khaki", "P90C TR Khaki 5.7mm", 8200, ["50Rnd_570x28_SMG_03"]],   
   ["hgun_PDW2000_F", "PDW2000 9mm", 5000, ["30Rnd_9x21_Mag"]],   
   ["SMG_05_F", "Protector 9mm", 5500, ["30Rnd_9x21_Mag_SMG_02"]],   
   ["SMG_02_F", "Sting 9mm", 6000, ["30Rnd_9x21_Mag_SMG_02"]],   
   ["SMG_01_F", "Vector .45 ACP", 7000, ["30Rnd_45ACP_Mag_SMG_01"]]   
  ];   
   
  private _mags = [   
   ["50Rnd_570x28_SMG_03", "5.7mm Mag", 300],   
   ["30Rnd_9x21_Mag", "9mm Mag", 150],   
   ["30Rnd_9x21_Mag_SMG_02", "9mm SMG Mag", 200],   
   ["30Rnd_45ACP_Mag_SMG_01", ".45 ACP Mag", 250]   
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
} forEach (allMissionObjects "C_man_hunter_1_F");   
   
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
        "<t color='#FFD700'>Weapon Attachments Shop</t>",    
        {         
            private _weaponAttachments = [    
                ["acc_flashlight", "Flashlight", 100], 
                ["acc_flashlight_pistol", "Pistol Flashlight", 75], 
                ["acc_flashlight_smg_01", "SMG Flashlight", 85], 
                ["acc_pointer_IR", "IR Pointer", 150], 
                ["B_UavTerminal", "UAV Terminal (NATO)", 500], 
                ["Binocular", "Binoculars", 200], 
                ["bipod_01_F_blk", "Bipod Black", 150], 
                ["bipod_01_F_khk", "Bipod Khaki", 150], 
                ["bipod_01_F_mtp", "Bipod MTP", 150], 
                ["bipod_01_F_snd", "Bipod Sand", 150], 
                ["bipod_02_F_arid", "Bipod Arid", 150], 
                ["bipod_02_F_blk", "Bipod Black", 150], 
                ["bipod_02_F_hex", "Bipod Hex", 150], 
                ["bipod_02_F_lush", "Bipod Lush", 150], 
                ["bipod_02_F_tan", "Bipod Tan", 150], 
                ["bipod_03_F_blk", "Bipod Black", 150], 
                ["bipod_03_F_oli", "Bipod Olive", 150], 
                ["C_UavTerminal", "UAV Terminal (Civilian)", 500], 
                ["ChemicalDetector_01_base_F", "Chemical Detector Base", 300], 
                ["ChemicalDetector_01_black_F", "Chemical Detector Black", 300], 
                ["ChemicalDetector_01_olive_F", "Chemical Detector Olive", 300], 
                ["ChemicalDetector_01_tan_F", "Chemical Detector Tan", 300], 
                ["ChemicalDetector_01_watch_F", "Chemical Detector Watch", 300], 
                ["DroneDetector", "Drone Detector", 400], 
                ["FirstAidKit", "First Aid Kit", 100], 
                ["I_E_UavTerminal", "UAV Terminal (LDF)", 500], 
                ["I_UavTerminal", "UAV Terminal (AAF)", 500], 
                ["Integrated_NVG_F", "Integrated NVG", 800], 
                ["Integrated_NVG_TI_0_F", "Integrated NVG TI", 1000], 
                ["Integrated_NVG_TI_1_F", "Integrated NVG TI Enhanced", 1200], 
                ["Item_AntidoteKit_01_F", "Antidote Kit", 200], 
                ["Item_DeconKit_01_F", "Decontamination Kit", 200], 
                ["ItemCompass", "Compass", 50], 
                ["ItemGPS", "GPS", 300], 
                ["ItemMap", "Map", 50], 
                ["ItemRadio", "Radio", 75], 
                ["ItemWatch", "Watch", 50], 
                ["Laserdesignator", "Laser Designator", 1000], 
                ["Laserdesignator_01_khk_F", "Laser Designator Khaki", 1000], 
                ["Laserdesignator_02", "Laser Designator", 1000], 
                ["Laserdesignator_02_ghex_F", "Laser Designator Green Hex", 1000], 
                ["Laserdesignator_03", "Laser Designator", 1000], 
                ["Medikit", "Medikit", 500], 
                ["MineDetector", "Mine Detector", 400], 
                ["muzzle_antenna_01_f", "Antenna 1", 100], 
                ["muzzle_antenna_02_f", "Antenna 2", 100], 
                ["muzzle_antenna_03_f", "Antenna 3", 100], 
                ["muzzle_snds_338_black", "Sound Suppressor (.338) Black", 300], 
                ["muzzle_snds_338_green", "Sound Suppressor (.338) Green", 300], 
                ["muzzle_snds_338_sand", "Sound Suppressor (.338) Sand", 300], 
                ["muzzle_snds_570", "Sound Suppressor 5.7mm", 250], 
                ["muzzle_snds_58_blk_F", "Sound Suppressor 5.8mm Black", 250], 
                ["muzzle_snds_58_ghex_F", "Sound Suppressor 5.8mm Green Hex", 250], 
                ["muzzle_snds_58_hex_F", "Sound Suppressor 5.8mm Hex", 250], 
                ["muzzle_snds_65_TI_blk_F", "Sound Suppressor 6.5mm Black", 300], 
                ["muzzle_snds_65_TI_ghex_F", "Sound Suppressor 6.5mm Green Hex", 300], 
                ["muzzle_snds_65_TI_hex_F", "Sound Suppressor 6.5mm Hex", 300], 
                ["muzzle_snds_93mmg", "Sound Suppressor 9.3mm", 350], 
                ["muzzle_snds_93mmg_tan", "Sound Suppressor 9.3mm Tan", 350], 
                ["muzzle_snds_acp", "Sound Suppressor ACP", 200], 
                ["muzzle_snds_B", "Sound Suppressor B", 300], 
                ["muzzle_snds_H", "Sound Suppressor H", 300], 
                ["muzzle_snds_L", "Sound Suppressor L", 250], 
                ["muzzle_snds_M", "Sound Suppressor M", 300], 
                ["NVGoggles", "NV Goggles", 800], 
                ["NVGoggles_INDEP", "NV Goggles Independent", 800], 
                ["NVGoggles_OPFOR", "NV Goggles OPFOR", 800], 
                ["NVGoggles_tna_F", "NV Goggles Tropic", 800], 
                ["O_NVGoggles_ghex_F", "NV Goggles Green Hex", 800], 
                ["O_NVGoggles_grn_F", "NV Goggles Green", 800], 
                ["O_NVGoggles_hex_F", "NV Goggles Hex", 800], 
                ["O_NVGoggles_urb_F", "NV Goggles Urban", 800], 
                ["O_UavTerminal", "UAV Terminal (CSAT)", 500], 
                ["optic_Aco", "ACO", 250], 
                ["optic_ACO_grn", "ACO Green", 250], 
                ["optic_ACO_grn_smg", "ACO SMG Green", 250], 
                ["optic_Aco_smg", "ACO SMG", 250], 
                ["optic_AMS", "AMS", 400], 
                ["optic_AMS_khk", "AMS Khaki", 400], 
                ["optic_AMS_snd", "AMS Sand", 400], 
                ["optic_Arco", "ARCO", 350], 
                ["optic_DMS", "DMS", 400], 
                ["optic_ERCO_blk_F", "ERCO Black", 375], 
                ["optic_ERCO_khk_F", "ERCO Khaki", 375], 
                ["optic_ERCO_snd_F", "ERCO Sand", 375], 
                ["optic_Hamr", "RCO", 400], 
                ["optic_Holosight", "Holographic", 300], 
                ["optic_LRPS", "LRPS", 500], 
                ["optic_MRCO", "MRCO", 375], 
                ["optic_MRD", "MRD", 200], 
                ["optic_Nightstalker", "Nightstalker", 1000], 
                ["optic_NVS", "NVS", 800], 
                ["optic_SOS", "SOS", 500], 
                ["optic_tws", "TWS", 1200], 
                ["optic_tws_mg", "TWS MG", 1200], 
                ["optic_Yorris", "Yorris", 200], 
                ["Rangefinder", "Rangefinder", 300], 
                ["ToolKit", "Toolkit", 350], 
                ["Zasleh2", "Flash Suppressor", 150] 
            ];     
  
            createDialog "RscDisplayEmpty";     
            private _display = findDisplay -1;     
  
            private _bg = _display ctrlCreate ["RscText", 1];     
            _bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6];     
            _bg ctrlSetBackgroundColor [0, 0, 0, 0.7];     
            _bg ctrlCommit 0;     
  
            private _title = _display ctrlCreate ["RscText", 2];     
            _title ctrlSetText "Weapon Attachments Shop";     
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
            } forEach _weaponAttachments;     
  
            private _buyBtn = _display ctrlCreate ["RscButton", 5];     
            _buyBtn ctrlSetText "Purchase Attachment";     
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
                    [player, _itemClass, _price] remoteExec ["fnc_purchaseWeaponAttachments", 2];     
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
} forEach (allMissionObjects "C_Man_formal_3_F");     
  
if (isServer) then {     
    fnc_purchaseWeaponAttachments = {     
        params ["_player", "_itemClass", "_price"];     
        private _playerUID = getPlayerUID _player;     
        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];     
  
        if (_bankMoney >= _price) then {     
            if (_itemClass select [0,4] == "Item") then {     
                _player linkItem _itemClass;     
            } else {     
                if (_itemClass == "Binocular") then {     
                    _player addWeapon _itemClass;     
                } else {     
                    _player addItem _itemClass;     
                };     
            };     
            _bankMoney = _bankMoney - _price;     
            profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];     
            saveProfileNamespace;     
            [format ["<t size='0.7' color='#00ff00'>Attachment purchased for <t color='#FFFFFF'>$%1</t>. Bank Balance: <t color='#FFFFFF'>$%2</t></t>", _price, _bankMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        } else {     
            ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];     
        };     
    };     
  
    publicVariable "fnc_purchaseWeaponAttachments";     
}; 






{        
    _x addAction ["<t color='#FFD700'>NATO Vehicle Shop</t>", {        
        private _vehicles = [        
            ["B_CTRG_LSV_01_light_F", "CTRG LSV Light", 5000],
            ["B_G_Van_01_fuel_F", "Guerilla Fuel Van", 3250],
            ["B_G_Offroad_01_F", "Guerilla Offroad", 1250],
            ["B_G_Offroad_01_AT_F", "Guerilla Offroad AT", 4500],
            ["B_G_Offroad_01_armed_F", "Guerilla Armed Offroad", 4000],
            ["B_G_Offroad_01_repair_F", "Guerilla Repair Offroad", 3500],
            ["B_G_Quadbike_01_F", "Guerilla Quadbike", 750],
            ["B_G_Van_01_transport_F", "Guerilla Transport Van", 3000],
            ["B_G_Van_02_vehicle_F", "Guerilla Van", 3500],
            ["B_G_Van_02_transport_F", "Guerilla Transport Van II", 3250],
            ["B_Truck_01_mover_F", "HEMTT Mover", 7500],
            ["B_Truck_01_ammo_F", "HEMTT Ammo", 8500],
            ["B_Truck_01_box_F", "HEMTT Box", 8000],
            ["B_Truck_01_cargo_F", "HEMTT Cargo", 8000],
            ["B_Truck_01_flatbed_F", "HEMTT Flatbed", 7750],
            ["B_Truck_01_fuel_F", "HEMTT Fuel", 8250],
            ["B_Truck_01_medical_F", "HEMTT Medical", 8000],
            ["B_Truck_01_Repair_F", "HEMTT Repair", 8500],
            ["B_Truck_01_transport_F", "HEMTT Transport", 7500],
            ["B_Truck_01_covered_F", "HEMTT Covered", 7750],
            ["B_MRAP_01_F", "Hunter", 6000],
            ["B_MRAP_01_gmg_F", "Hunter GMG", 9500],
            ["B_LSV_01_AT_F", "Prowler AT", 9000],
            ["B_LSV_01_armed_F", "Prowler Armed", 8500],
            ["B_Quadbike_01_F", "Military Quad", 7500],
            ["B_APC_Wheeled_01_cannon_F", "AMV-7 Marshall", 15000],
            ["B_APC_Tracked_01_CRV_F", "CRV-6e Bobcat", 16000],
            ["B_APC_Tracked_01_rcws_F", "IFV-6c Panther", 17000],
            ["B_AFV_Wheeled_01_cannon_F", "Rhino MGS", 18000],
            ["B_AFV_Wheeled_01_up_cannon_F", "Rhino MGS UP", 20000],
            ["B_MBT_01_arty_F", "M4 Scorcher", 25000],
            ["B_MBT_01_mlrs_F", "M5 Sandstorm", 27000],
            ["B_T_UGV_01_olive_F", "UGV Stomper", 10000],
            ["B_T_UGV_01_rcws_olive_F", "UGV Stomper RCWS", 15000],
            ["B_MBT_01_cannon_F", "M2A1 Slammer", 22000],
			["B_APC_Tracked_01_AA_F", "Cheetah AA", 18000],
            ["B_MBT_01_TUSK_F", "M2A4 Slammer UP", 24000]           
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
                [player, _vehicleClass, _price] remoteExec ["fnc_purchaseNatoVehicle", 2];        
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
} forEach (allMissionObjects "C_Man_Fisherman_01_F");        
        
if (isServer) then {        
    fnc_purchaseNatoVehicle = {        
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
            
    publicVariable "fnc_purchaseNatoVehicle";
	
};






{        
    _x addAction ["<t color='#FFD700'>CSAT Vehicle Shop</t>", {        
        private _vehicles = [        
            ["O_MRAP_02_F", "Ifrit", 6000],
            ["O_MRAP_02_gmg_F", "Ifrit GMG", 9500],
            ["O_MRAP_02_hmg_F", "Ifrit HMG", 9250],
            ["O_LSV_02_AT_F", "Qilin AT", 9000],
            ["O_LSV_02_armed_F", "Qilin Armed", 8500],
            ["O_LSV_02_unarmed_F", "Qilin", 5000],
            ["O_T_LSV_02_armed_F", "Qilin Armed (Hex)", 8500],
            ["O_T_LSV_02_unarmed_F", "Qilin (Hex)", 5000],
            ["O_T_LSV_02_AT_F", "Qilin AT (Hex)", 9000],
            ["O_Truck_02_covered_F", "Zamak Covered", 7250],
            ["O_Truck_02_transport_F", "Zamak Transport", 7000],
            ["O_Truck_02_box_F", "Zamak Box", 7250],
            ["O_Truck_02_medical_F", "Zamak Medical", 7500],
            ["O_Truck_02_Ammo_F", "Zamak Ammo", 8000],
            ["O_Truck_02_fuel_F", "Zamak Fuel", 7750],
            ["O_Truck_03_transport_F", "Tempest Transport", 7500],
            ["O_Truck_03_covered_F", "Tempest Covered", 7750],
            ["O_Truck_03_repair_F", "Tempest Repair", 8500],
            ["O_Truck_03_ammo_F", "Tempest Ammo", 8500],
            ["O_Truck_03_fuel_F", "Tempest Fuel", 8250],
            ["O_Truck_03_medical_F", "Tempest Medical", 8000],
            ["O_Truck_03_device_F", "Tempest Device", 9000],
            ["O_APC_Tracked_02_cannon_F", "BTR-K Kamysh", 15000],
            ["O_APC_Tracked_02_AA_F", "ZSU-39 Tigris", 17000],
            ["O_APC_Wheeled_02_rcws_v2_F", "MSE-3 Marid", 14000],
            ["O_MBT_02_cannon_F", "T-100 Varsuk", 22000],
            ["O_MBT_04_cannon_F", "T-140 Angara", 24000],
            ["O_MBT_04_command_F", "T-140K Angara", 26000],
            ["O_T_APC_Tracked_02_cannon_ghex_F", "BTR-K Kamysh (Green Hex)", 15000],
            ["O_T_APC_Wheeled_02_rcws_v2_ghex_F", "MSE-3 Marid (Green Hex)", 14000],
            ["O_T_MBT_02_cannon_ghex_F", "T-100 Varsuk (Green Hex)", 22000],
            ["O_T_MBT_04_cannon_F", "T-140 Angara (Green Hex)", 24000],
            ["O_T_MBT_04_command_F", "T-140K Angara (Green Hex)", 26000],
            ["O_UGV_01_F", "UGV Saif", 10000],
            ["O_UGV_01_rcws_F", "UGV Saif RCWS", 15000],
            ["O_G_Offroad_01_F", "CSAT Offroad", 1250],
            ["O_G_Offroad_01_armed_F", "CSAT Armed Offroad", 4000],
            ["O_G_Offroad_01_AT_F", "CSAT Offroad AT", 4500],
            ["O_G_Van_01_transport_F", "CSAT Transport Van", 3000],
            ["O_G_Van_02_vehicle_F", "CSAT Van", 3500],
            ["O_G_Van_02_transport_F", "CSAT Transport Van II", 3250],
            ["O_G_Quadbike_01_F", "CSAT Quadbike", 750]
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
                [player, _vehicleClass, _price] remoteExec ["fnc_purchaseCsatVehicle", 2];        
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
} forEach (allMissionObjects "C_journalist_F");        
        
if (isServer) then {        
    fnc_purchaseCsatVehicle = {        
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
            
    publicVariable "fnc_purchaseCsatVehicle";
	
};






{        
    _x addAction ["<t color='#FFD700'>Guer/AAF Vehicle Shop</t>", {        
        private _vehicles = [        
            ["I_MRAP_03_F", "Strider", 6000],
            ["I_MRAP_03_hmg_F", "Strider HMG", 9250],
            ["I_MRAP_03_gmg_F", "Strider GMG", 9500],
            ["I_APC_tracked_03_cannon_F", "FV-720 Mora", 15000],
            ["I_APC_Wheeled_03_cannon_F", "AFV-4 Gorgon", 14000],
            ["I_LT_01_AA_F", "AWC 302 Nyx AA", 17000],
            ["I_LT_01_AT_F", "AWC 302 Nyx AT", 16000],
            ["I_LT_01_cannon_F", "AWC 302 Nyx Cannon", 15000],
            ["I_LT_01_scout_F", "AWC 302 Nyx Scout", 14000],
            ["I_MBT_03_cannon_F", "MBT-52 Kuma", 22000],
            ["I_UGV_01_F", "UGV Stomper", 10000],
            ["I_UGV_01_rcws_F", "UGV Stomper RCWS", 15000],
            ["I_Truck_02_covered_F", "Zamak Covered", 7250],
            ["I_Truck_02_transport_F", "Zamak Transport", 7000],
            ["I_Truck_02_box_F", "Zamak Box", 7250],
            ["I_Truck_02_medical_F", "Zamak Medical", 7500],
            ["I_Truck_02_ammo_F", "Zamak Ammo", 8000],
            ["I_Truck_02_fuel_F", "Zamak Fuel", 7750],
            ["I_G_Offroad_01_F", "AAF Offroad", 1250],
            ["I_G_Offroad_01_armed_F", "AAF Armed Offroad", 4000],
            ["I_G_Offroad_01_AT_F", "AAF Offroad AT", 4500],
            ["I_G_Van_01_transport_F", "AAF Transport Van", 3000],
            ["I_G_Van_02_vehicle_F", "AAF Van", 3500],
            ["I_G_Van_02_transport_F", "AAF Transport Van II", 3250],
            ["I_G_Quadbike_01_F", "AAF Quadbike", 750]
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
                [player, _vehicleClass, _price] remoteExec ["fnc_purchaseGuerVehicle", 2];        
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
} forEach (allMissionObjects "C_IDAP_Man_AidWorker_05_F");        
        
if (isServer) then {        
    fnc_purchaseGuerVehicle = {        
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
            
    publicVariable "fnc_purchaseGuerVehicle";
	
};

if (isServer) then {        
    stockList = [        
        ["AAPL", 180, 0],        
        ["MSFT", 330, 0],        
        ["GOOGL", 140, 0],        
        ["AMZN", 145, 0],        
        ["NVDA", 480, 0],        
        ["META", 330, 0],        
        ["TSLA", 240, 0],        
        ["JPM", 150, 0],
        ["V", 250, 0],
        ["WMT", 160, 0],
        ["PG", 150, 0],
        ["JNJ", 155, 0],
        ["XOM", 105, 0],
        ["BAC", 30, 0],
        ["PFE", 30, 0],
        ["NFLX", 450, 0],
        ["DIS", 90, 0],
        ["CSCO", 50, 0],
        ["INTC", 35, 0],
        ["AMD", 120, 0],
        ["PYPL", 60, 0],
        ["UBER", 55, 0],
        ["F", 12, 0],
        ["GM", 35, 0],
        ["BA", 220, 0]        
    ];        
    publicVariable "stockList";        
       
    [] spawn {        
        while {true} do {        
            {        
                _x params ["_stockSymbol", "_currentPrice", "_sharesOwned"];        
                private _priceChange = (random 20) - 10;        
                private _updatedPrice = (_currentPrice + _priceChange) max 1;        
                _x set [1, _updatedPrice];        
            } forEach stockList;        
            publicVariable "stockList";        
            sleep 5;        
        };        
    };        
};        

fnc_updateStockDisplay = {        
    params ["_display"];        
    if (!isNull _display) then {        
        private _stockListBox = _display displayCtrl 4;        
        private _balanceText = _display displayCtrl 3;        
        private _playerUID = getPlayerUID player;   
        private _playerStocks = profileNamespace getVariable [_playerUID + "_stocks", []];   
   
        _balanceText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [_playerUID + "_bankMoney", 0]];        
   
        lbClear _stockListBox;        
        {        
            _x params ["_stockSymbol", "_currentPrice"];        
            private _sharesOwned = count (_playerStocks select {(_x select 0) isEqualTo _stockSymbol});   
            private _totalInvestment = 0;   
            private _profitLoss = 0;   
               
            {   
                if ((_x select 0) isEqualTo _stockSymbol) then {   
                    _totalInvestment = _totalInvestment + (_x select 1);   
                    _profitLoss = _profitLoss + (_currentPrice - (_x select 1));   
                };   
            } forEach _playerStocks;   
               
            private _index = _stockListBox lbAdd format["%1 - Current: $%2 | Owned: %3 | P/L: $%4",    
                _stockSymbol, round _currentPrice, _sharesOwned, round _profitLoss];        
            _stockListBox lbSetData [_index, _stockSymbol];        
            _stockListBox lbSetValue [_index, round _currentPrice];        
        } forEach stockList;        
    };        
};        






{        
    _x addAction [        
        "<t color='#FFD700'>Stock Market</t>",        
        {        
            createDialog "RscDisplayEmpty";        
            private _display = findDisplay -1;        
            private _backgroundPanel = _display ctrlCreate ["RscText", 1];        
            _backgroundPanel ctrlSetPosition [0.2, 0.2, 0.8, 0.7];        
            _backgroundPanel ctrlSetBackgroundColor [0, 0, 0, 0.7];        
            _backgroundPanel ctrlCommit 0;        
            
            private _titleText = _display ctrlCreate ["RscText", 2];        
            _titleText ctrlSetText "Stock Market";        
            _titleText ctrlSetPosition [0.2, 0.2, 0.8, 0.05];        
            _titleText ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];        
            _titleText ctrlSetTextColor [1, 1, 1, 1];        
            _titleText ctrlCommit 0;        
            
            private _balanceText = _display ctrlCreate ["RscText", 3];        
            _balanceText ctrlSetPosition [0.225, 0.26, 0.75, 0.05];        
            _balanceText ctrlSetTextColor [0, 1, 0, 1];        
            _balanceText ctrlSetText format["Bank Balance: $%1", profileNamespace getVariable [(getPlayerUID player) + "_bankMoney", 0]];        
            _balanceText ctrlCommit 0;        
            
            private _stockListBox = _display ctrlCreate ["RscListBox", 4];        
            _stockListBox ctrlSetPosition [0.225, 0.32, 0.75, 0.25];        
            _stockListBox ctrlCommit 0;        

            private _updateHandle = [] spawn {        
                private _display = findDisplay -1;        
                while {!isNull _display} do {        
                    [_display] call fnc_updateStockDisplay;        
                    sleep 1;        
                };        
            };        

            _display setVariable ["updateHandle", _updateHandle];        

            {        
                _x params ["_stockSymbol", "_currentPrice"];        
                private _index = _stockListBox lbAdd format["%1 - $%2", _stockSymbol, _currentPrice];        
                _stockListBox lbSetData [_index, _stockSymbol];        
                _stockListBox lbSetValue [_index, _currentPrice];        
            } forEach stockList;        

            private _quantityInput = _display ctrlCreate ["RscEdit", 7];        
            _quantityInput ctrlSetPosition [0.425, 0.58, 0.35, 0.05];        
            _quantityInput ctrlSetText "1";        
            _quantityInput ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];        
            _quantityInput ctrlCommit 0;        

            private _decreaseButton = _display ctrlCreate ["RscButton", 8];        
            _decreaseButton ctrlSetText "-";        
            _decreaseButton ctrlSetPosition [0.325, 0.58, 0.05, 0.05];        
            _decreaseButton ctrlCommit 0;        

            private _increaseButton = _display ctrlCreate ["RscButton", 9];        
            _increaseButton ctrlSetText "+";        
            _increaseButton ctrlSetPosition [0.825, 0.58, 0.05, 0.05];        
            _increaseButton ctrlCommit 0;        

            _decreaseButton ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _quantityInput = _display displayCtrl 7;        
                private _currentQuantity = parseNumber ctrlText _quantityInput;        
                if (_currentQuantity > 1) then {        
                    _quantityInput ctrlSetText str (_currentQuantity - 1);        
                };        
            }];        

            _increaseButton ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _quantityInput = _display displayCtrl 7;        
                private _currentQuantity = parseNumber ctrlText _quantityInput;        
                _quantityInput ctrlSetText str (_currentQuantity + 1);        
            }];        

            private _buyButton = _display ctrlCreate ["RscButton", 5];        
            _buyButton ctrlSetText "Buy";        
            _buyButton ctrlSetPosition [0.325, 0.65, 0.16, 0.05];        
            _buyButton ctrlSetTextColor [0, 1, 0, 1];        
            _buyButton ctrlCommit 0;        

            _buyButton ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _stockListBox = _display displayCtrl 4;        
                private _selectedIndex = lbCurSel _stockListBox;        
                private _quantity = parseNumber ctrlText (_display displayCtrl 7);   
                   
                if (_selectedIndex != -1 && _quantity > 0) then {        
                    private _stockSymbol = _stockListBox lbData _selectedIndex;        
                    private _currentPrice = _stockListBox lbValue _selectedIndex;        
                    private _totalCost = _currentPrice * _quantity;   
                    private _playerUID = getPlayerUID player;        
                    private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];        
                       
                    if (_bankMoney >= _totalCost) then {        
                        _bankMoney = _bankMoney - _totalCost;        
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];        
                           
                        private _playerStocks = profileNamespace getVariable [_playerUID + "_stocks", []];        
                        for "_i" from 1 to _quantity do {   
                            _playerStocks pushBack [_stockSymbol, _currentPrice];        
                        };   
                        profileNamespace setVariable [_playerUID + "_stocks", _playerStocks];        
                        saveProfileNamespace;        
                           
                        [format ["<t size='0.7' color='#00ff00'>Bought %1 shares of %2 for <t color='#FFFFFF'>$%3</t></t>",    
                            _quantity, _stockSymbol, _totalCost], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    } else {        
                        ["<t size='0.7' color='#ff0000'>Not enough money in bank!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    };        
                };        
            }];        

            private _sellButton = _display ctrlCreate ["RscButton", 10];        
            _sellButton ctrlSetText "Sell";        
            _sellButton ctrlSetPosition [0.495, 0.65, 0.16, 0.05];        
            _sellButton ctrlSetTextColor [1, 0.5, 0, 1];        
            _sellButton ctrlCommit 0;        

            _sellButton ctrlAddEventHandler ["ButtonClick", {        
                params ["_ctrl"];        
                private _display = ctrlParent _ctrl;        
                private _stockListBox = _display displayCtrl 4;        
                private _selectedIndex = lbCurSel _stockListBox;        
                private _quantity = parseNumber ctrlText (_display displayCtrl 7);   
                   
                if (_selectedIndex != -1 && _quantity > 0) then {        
                    private _stockSymbol = _stockListBox lbData _selectedIndex;        
                    private _currentPrice = _stockListBox lbValue _selectedIndex;        
                    private _playerUID = getPlayerUID player;        
                    private _playerStocks = profileNamespace getVariable [_playerUID + "_stocks", []];        
                    private _ownedShares = _playerStocks select {(_x select 0) isEqualTo _stockSymbol};   
                       
                    if (count _ownedShares >= _quantity) then {        
                        private _totalValue = _currentPrice * _quantity;   
                        for "_i" from 1 to _quantity do {   
                            private _index = _playerStocks findIf {(_x select 0) isEqualTo _stockSymbol};   
                            if (_index != -1) then {   
                                _playerStocks deleteAt _index;   
                            };   
                        };   
                           
                        profileNamespace setVariable [_playerUID + "_stocks", _playerStocks];        
                        private _bankMoney = profileNamespace getVariable [_playerUID + "_bankMoney", 0];        
                        _bankMoney = _bankMoney + _totalValue;        
                        profileNamespace setVariable [_playerUID + "_bankMoney", _bankMoney];        
                        saveProfileNamespace;        
                           
                        [format ["<t size='0.7' color='#00ff00'>Sold %1 shares of %2 for <t color='#FFFFFF'>$%3</t></t>",    
                            _quantity, _stockSymbol, _totalValue], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    } else {        
                        ["<t size='0.7' color='#ff0000'>You don't own enough shares!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", player];        
                    };        
                };        
            }];        

            private _closeButton = _display ctrlCreate ["RscButton", 6];        
            _closeButton ctrlSetText "Close";        
            _closeButton ctrlSetPosition [0.325, 0.72, 0.35, 0.05];        
            _closeButton ctrlSetTextColor [1, 0, 0, 1];        
            _closeButton ctrlCommit 0;        

            _closeButton ctrlAddEventHandler ["ButtonClick", {        
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
} forEach (allMissionObjects "C_IDAP_Pilot_01_F");
