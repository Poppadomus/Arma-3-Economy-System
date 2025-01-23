[] spawn {
	waitUntil {!isNull player};  
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
	 
		private _marketItems = [ 
			["APPL", "Apple Inc.", 150, 145], 
			["GOOG", "Alphabet Inc.", 2800, 2750], 
			["AMZN", "Amazon.com Inc.", 3200, 3150], 
			["MSFT", "Microsoft Corp.", 300, 295], 
			["TSLA", "Tesla Inc.", 700, 690] 
		]; 
		publicVariable "_marketItems"; 
	};  
	 
	private _atmModels = ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"];  
	 
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
	} forEach (allMissionObjects "Land_CashDesk_F");  
	 
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

	{  
		_x addAction ["<t color='#FFD700'>Weapon Shop</t>", {  
			private _weapons = [  
				["hgun_P07_F", "P07 9mm", 750],  
				["hgun_Pistol_heavy_02_F", "Zubr .45", 1000],  
				["SMG_01_F", "Vector SMG", 2500],  
				["SMG_02_F", "Sting 9mm", 2000],  
				["arifle_Mk20_F", "Mk20 5.56mm", 3500],  
				["arifle_TRG20_F", "TRG-20 5.56mm", 3000],  
				["arifle_Katiba_F", "Katiba 6.5mm", 4000],  
				["srifle_DMR_01_F", "Rahim 7.62mm", 6000],  
				["LMG_Mk200_F", "Mk200 6.5mm", 8000]  
			];  
			  
			createDialog "RscDisplayEmpty";  
			private _display = findDisplay -1;  
			private _bg = _display ctrlCreate ["RscText", 1];  
			_bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6];  
			_bg ctrlSetBackgroundColor [0, 0, 0, 0.7];  
			_bg ctrlCommit 0;  
			  
			private _title = _display ctrlCreate ["RscText", 2];  
			_title ctrlSetText "Weapon Shop";  
			_title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];  
			_title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];  
			_title ctrlSetTextColor [1, 1, 1, 1];  
			_title ctrlCommit 0;  
	 
			private _cashText = _display ctrlCreate ["RscText", 3];  
			_cashText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];  
			_cashText ctrlSetTextColor [0, 1, 0, 1];  
			_cashText ctrlSetText format["Cash: $%1", profileNamespace getVariable [(getPlayerUID player) + "_cashMoney", 0]];  
			_cashText ctrlCommit 0;  
	 
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
			} forEach _weapons;  
	 
			private _buyBtn = _display ctrlCreate ["RscButton", 5];  
			_buyBtn ctrlSetText "Purchase Weapon";  
			_buyBtn ctrlSetPosition [0.325, 0.64, 0.35, 0.05];  
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
			  
			private _closeBtn = _display ctrlCreate ["RscButton", 6];  
			_closeBtn ctrlSetText "Close";  
			_closeBtn ctrlSetPosition [0.325, 0.71, 0.35, 0.05];  
			_closeBtn ctrlSetTextColor [1, 0, 0, 1];  
			_closeBtn ctrlCommit 0;  
			  
			_closeBtn ctrlAddEventHandler ["ButtonClick", {  
				closeDialog 0;  
			}];  
		}, [], 1.5, true, true, "", "", 3];  
	} forEach (allMissionObjects "Land_Ammobox_rounds_F");  
	 
	if (isServer) then {  
		fnc_purchaseWeapon = {  
			params ["_player", "_weaponClass", "_price"];  
			private _playerUID = getPlayerUID _player;  
			private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];  
			  
			if (_cashMoney >= _price) then {  
				_cashMoney = _cashMoney - _price;  
				profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];  
				saveProfileNamespace;  
				  
				_player addWeapon _weaponClass;  
				private _magazineClass = (getArray (configFile >> "CfgWeapons" >> _weaponClass >> "magazines")) select 0;  
				_player addMagazines [_magazineClass, 3];  
				  
				[format ["<t size='0.7' color='#00ff00'>Weapon purchased for <t color='#FFFFFF'>$%1</t>. Cash: <t color='#FFFFFF'>$%2</t></t>", _price, _cashMoney], -1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			} else {  
				["<t size='0.7' color='#ff0000'>Not enough cash!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			};  
		};  
		  
		publicVariable "fnc_purchaseWeapon";  
	};  
	 
	{   
		_x addAction ["<t color='#FFD700'>Stock Market</t>", {   
			waitUntil {!isNil "_marketItems"};   
			createDialog "RscDisplayEmpty";   
			private _display = findDisplay -1;   
			if (isNull _display) exitWith {};  
			  
			private _bg = _display ctrlCreate ["RscText", 1];   
			_bg ctrlSetPosition [0.3, 0.2, 0.4, 0.6];   
			_bg ctrlSetBackgroundColor [0, 0, 0, 0.7];   
			_bg ctrlCommit 0;   
			  
			private _title = _display ctrlCreate ["RscText", 2];   
			_title ctrlSetText "Stock Market";   
			_title ctrlSetPosition [0.3, 0.2, 0.4, 0.05];   
			_title ctrlSetBackgroundColor [0.1, 0.1, 0.3, 1];   
			_title ctrlSetTextColor [1, 1, 1, 1];   
			_title ctrlCommit 0;   
	  
			private _cashText = _display ctrlCreate ["RscText", 3];   
			_cashText ctrlSetPosition [0.325, 0.26, 0.35, 0.05];   
			_cashText ctrlSetTextColor [0, 1, 0, 1];   
			_cashText ctrlSetText format["Cash: $%1", profileNamespace getVariable [(getPlayerUID player) + "_cashMoney", 0]];   
			_cashText ctrlCommit 0;   
	  
			private _listBox = _display ctrlCreate ["RscListBox", 4];   
			_listBox ctrlSetPosition [0.325, 0.32, 0.35, 0.3];   
			_listBox ctrlCommit 0;   
	  
			{   
				_x params ["_stockTicker", "_stockName", "_buyPrice", "_sellPrice"];   
				private _index = _listBox lbAdd format["%1 (%2) - Buy: $%3 | Sell: $%4", _stockName, _stockTicker, _buyPrice, _sellPrice];   
				_listBox lbSetData [_index, _stockTicker];   
				_listBox lbSetValue [_index, _buyPrice];   
				_listBox lbSetTextRight [_index, str _sellPrice];   
			} forEach _marketItems;   
	  
			private _amountInput = _display ctrlCreate ["RscEdit", 5];   
			_amountInput ctrlSetPosition [0.325, 0.64, 0.35, 0.05];   
			_amountInput ctrlSetText "1";   
			_amountInput ctrlSetBackgroundColor [0.2, 0.2, 0.2, 1];   
			_amountInput ctrlCommit 0;   
	  
			private _buyBtn = _display ctrlCreate ["RscButton", 6];   
			_buyBtn ctrlSetText "Buy";   
			_buyBtn ctrlSetPosition [0.325, 0.71, 0.17, 0.05];   
			_buyBtn ctrlSetTextColor [0, 1, 0, 1];   
			_buyBtn ctrlCommit 0;   
			   
			_buyBtn ctrlAddEventHandler ["ButtonClick", {   
				params ["_ctrl"];   
				private _display = ctrlParent _ctrl;   
				private _listBox = _display displayCtrl 4;   
				private _selectedIndex = lbCurSel _listBox;   
				private _amount = parseNumber ctrlText (_display displayCtrl 5);   
				  
				if (_selectedIndex != -1 && _amount > 0) then {   
					private _stockTicker = _listBox lbData _selectedIndex;   
					private _price = _listBox lbValue _selectedIndex;   
					[player, _stockTicker, _amount, _price] remoteExec ["fnc_buyShares", 2];   
				};   
			}];   
	  
			private _sellBtn = _display ctrlCreate ["RscButton", 7];   
			_sellBtn ctrlSetText "Sell";   
			_sellBtn ctrlSetPosition [0.505, 0.71, 0.17, 0.05];   
			_sellBtn ctrlSetTextColor [1, 0.5, 0, 1];   
			_sellBtn ctrlCommit 0;   
			   
			_sellBtn ctrlAddEventHandler ["ButtonClick", {   
				params ["_ctrl"];   
				private _display = ctrlParent _ctrl;   
				private _listBox = _display displayCtrl 4;   
				private _selectedIndex = lbCurSel _listBox;   
				private _amount = parseNumber ctrlText (_display displayCtrl 5);   
				  
				if (_selectedIndex != -1 && _amount > 0) then {   
					private _stockTicker = _listBox lbData _selectedIndex;   
					private _sellPrice = parseNumber (_listBox lbTextRight _selectedIndex);   
					[player, _stockTicker, _amount, _sellPrice] remoteExec ["fnc_sellShares", 2];   
				};   
			}];   
	  
			private _closeBtn = _display ctrlCreate ["RscButton", 8];   
			_closeBtn ctrlSetText "Close";   
			_closeBtn ctrlSetPosition [0.325, 0.78, 0.35, 0.05];   
			_closeBtn ctrlSetTextColor [1, 0, 0, 1];   
			_closeBtn ctrlCommit 0;   
			   
			_closeBtn ctrlAddEventHandler ["ButtonClick", {   
				closeDialog 0;   
			}];   
		}, [], 1.5, true, true, "", "", 3];   
	} forEach (allMissionObjects "Land_MultiScreenComputer_01_sand_F");   
	  
	if (isServer) then {  
		fnc_buyShares = {  
			params ["_player", "_stockTicker", "_amount", "_price"];  
			private _playerUID = getPlayerUID _player;  
			private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];  
			private _totalCost = _price * _amount;  
			  
			if (_cashMoney >= _totalCost) then {  
				_cashMoney = _cashMoney - _totalCost;  
				profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];  
				  
				private _portfolio = profileNamespace getVariable [_playerUID + "_portfolio", createHashMap];  
				private _currentShares = _portfolio getOrDefault [_stockTicker, 0];  
				_portfolio set [_stockTicker, _currentShares + _amount];  
				profileNamespace setVariable [_playerUID + "_portfolio", _portfolio];  
				  
				saveProfileNamespace;  
				  
				[format ["<t size='0.7' color='#00ff00'>Bought %3 shares of %4 for <t color='#FFFFFF'>$%1</t>. Cash: <t color='#FFFFFF'>$%2</t></t>",   
					_totalCost, _cashMoney, _amount, (_marketItems select (_marketItems findIf {_x select 0 == _stockTicker})) select 1],   
					-1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			} else {  
				["<t size='0.7' color='#ff0000'>Not enough cash!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			};  
		};  
	  
		fnc_sellShares = {  
			params ["_player", "_stockTicker", "_amount", "_sellPrice"];  
			private _playerUID = getPlayerUID _player;  
			private _portfolio = profileNamespace getVariable [_playerUID + "_portfolio", createHashMap];  
			private _currentShares = _portfolio getOrDefault [_stockTicker, 0];  
			  
			if (_currentShares >= _amount) then {  
				private _totalEarnings = _sellPrice * _amount;  
				private _cashMoney = profileNamespace getVariable [_playerUID + "_cashMoney", 0];  
				  
				_cashMoney = _cashMoney + _totalEarnings;  
				_portfolio set [_stockTicker, _currentShares - _amount];  
				  
				profileNamespace setVariable [_playerUID + "_cashMoney", _cashMoney];  
				profileNamespace setVariable [_playerUID + "_portfolio", _portfolio];  
				saveProfileNamespace;  
				  
				[format ["<t size='0.7' color='#ffa500'>Sold %3 shares of %4 for <t color='#FFFFFF'>$%1</t>. Cash: <t color='#FFFFFF'>$%2</t></t>",   
					_totalEarnings, _cashMoney, _amount, (_marketItems select (_marketItems findIf {_x select 0 == _stockTicker})) select 1],   
					-1, 0.85, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			} else {  
				["<t size='0.7' color='#ff0000'>Not enough shares!</t>", -1, 0.95, 4, 1] remoteExec ["BIS_fnc_dynamicText", _player];  
			};  
		};  
	  
		publicVariable "fnc_buyShares";  
		publicVariable "fnc_sellShares";  
	};
}; 