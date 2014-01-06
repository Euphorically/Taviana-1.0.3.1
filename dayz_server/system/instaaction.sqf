while {true} do {
	if (isNil _firstStartAction) then {
		format ['CHILD:999:DELETE FROM `InstaActions`:[1]:'] call server_hiveWrite;
		_firstStartAction = '1';
	};
	sleep 5;
	if (isServer and !(isNil "sm_done")) then {	
		_key = 'CHILD:999:SELECT `id`, `clientSide`, `execCode`, `repeatAction`, `description` FROM `InstaActions` ORDER BY `id` ASC:[1]:';
		_result = _key call server_hiveReadWriteLarge;
		
		_status  = _result select 0;
		
		if (_status == 'CustomStreamStart') then {
			_numResults = _result select 1;
			_actionsArr = [];
			for '_i' from 1 to _numResults do {
				_actionsArr set [count _actionsArr, _key call server_hiveReadWrite];
			};
			{
				_rAction = compile (_x select 2);
				_clientSide = _x select 1;
				_repeatAction = _x select 3;
				_description = _x select 4;
				if (_clientSide == 1) then {
					[nil,nil, rSpawn, [], _rAction] call RE;
				} else {
					[] spawn _rAction;
				};
				if (_repeatAction == 0) then {
					diag_log("InstaActions: Executed non-repeating action - clientSide " + str(_clientSide) + " - " + str(_description));
					format ['CHILD:999:DELETE FROM `InstaActions` where `id` = ?:[%1]:', _x select 0] call server_hiveWrite;
				} else {
					diag_log("InstaActions: Executed repeating action - clientSide " + str(_clientSide) + " - " + str(_description));
				};
			} foreach _actionsArr;
		};
	};
};