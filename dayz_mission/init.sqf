/*	
	For DayZ Epoch
	Addons Credits: Jetski Yanahui by Kol9yN, Zakat, Gerasimow9, YuraPetrov, zGuba, A.Karagod, IceBreakr, Sahbazz
*/
startLoadingScreen ["","RscDisplayLoadCustom"];
cutText ["","BLACK OUT"];
enableSaving [false, false];

//REALLY IMPORTANT VALUES
dayZ_instance =	1473;					//The instance
dayzHiveRequest = [];
initialized = false;
dayz_previousID = 0;

// Enabling this option will disable the instant map features involving player healing and loadout changes
dayz_REsec = 0; // DayZ RE Security / 1 = enabled // 0 = disabled

//disable greeting menu 
player setVariable ["BIS_noCoreConversations", true];
//disable radio messages to be heard and shown in the left lower corner of the screen
enableRadio false;
// May prevent "how are you civillian?" messages from NPC
enableSentences false;

// DayZ Epoch config
spawnShoremode = 0; // Default = 1 (on shore)
spawnArea= 1500; // Default = 1500
MaxHeliCrashes= 30; // Default = 5
MaxVehicleLimit = 800; // Default = 50
MaxDynamicDebris = 300; // Default = 100
dayz_MapArea = 14000; // Default = 10000
dayz_maxLocalZombies = 20; // Default = 30 
DZE_teleport = [25000,25000,25000,25000,25000];
dayz_paraSpawn = false;
DZE_DeathMsgGlobal = true; // Default = false

dayz_minpos = -1; 
dayz_maxpos = 16000;

dayz_sellDistance_vehicle = 20;
dayz_sellDistance_boat = 30;
dayz_sellDistance_air = 40;

dayz_maxAnimals = 8; // Default: 8
dayz_tameDogs = true;
DynamicVehicleDamageLow = 0; // Default: 0
DynamicVehicleDamageHigh = 85; // Default: 100
DynamicVehicleFuelLow = 0;
DynamicVehicleFuelHigh = 35;

DZE_vehicleAmmo = 1; //Default = 0, deletes ammo from vehicles with machine guns every restart if set to 0.
DZE_BackpackGuard = false; //Default = True, deletes backpack contents if logging out or losing connection beside another player if set to true.
DZE_BuildingLimit = 300; //Default = 150, decides how many objects can be built on the server before allowing any others to be built. Change value for more buildings.
DZE_TRADER_SPAWNMODE = false; //Vehicles bought with traders will parachute in instead of just spawning on the ground.
EpochEvents = [["any","any","any","any",30,"crash_spawner"],["any","any","any","any",0,"crash_spawner"],["any","any","any","any",15,"supply_drop"]];
dayz_fullMoonNights = true;

//Load in compiled functions
//call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";				//Initilize the Variables (IMPORTANT: Must happen very early)
call compile preprocessFileLineNumbers "ATPExclusion\variables.sqf";
progressLoadingScreen 0.1;
//call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\publicEH.sqf";				//Initilize the publicVariable event handlers
call compile preprocessFileLineNumbers "ATPExclusion\publicEH.sqf";
progressLoadingScreen 0.2;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\medical\setup_functions_med.sqf";	//Functions used by CLIENT for medical
progressLoadingScreen 0.4;
//call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";				//Compile regular functions
call compile preprocessFileLineNumbers "custom\compiles.sqf";        //Self Blood Bag Addition
progressLoadingScreen 0.5;
call compile preprocessFileLineNumbers "server_traders.sqf";				//Compile trader configs
progressLoadingScreen 1.0;

"filmic" setToneMappingParams [0.153, 0.357, 0.231, 0.1573, 0.011, 3.750, 6, 4]; setToneMapping "Filmic";
	
if (isServer) then {
	call compile preprocessFileLineNumbers "\z\addons\dayz_server\missions\DayZ_Epoch_13.Tavi\dynamic_vehicle.sqf";
	//Compile vehicle configs
	
	// Add trader citys
	_nil = [] execVM "\z\addons\dayz_server\missions\DayZ_Epoch_13.Tavi\mission.sqf";
	_serverMonitor = 	[] execVM "\z\addons\dayz_code\system\server_monitor.sqf";
};

if (!isDedicated) then {
	//Conduct map operations
	0 fadeSound 0;
	waitUntil {!isNil "dayz_loadScreenMsg"};
	dayz_loadScreenMsg = (localize "STR_AUTHENTICATING");
	
	//Run the player monitor
	_id = player addEventHandler ["Respawn", {_id = [] spawn player_death;}];
	_playerMonitor = 	[] execVM "\z\addons\dayz_code\system\player_monitor.sqf";	
	
	// Anti Hack 
	if (true) then {
		[] execVM "ATPExclusion\antihack.sqf";
	};
	
	//Lights
	if (true) then {
		//[0,0,true,true,true,58,280,600,[0.698, 0.556, 0.419],"Generator_DZ",0.1] execVM "\z\addons\dayz_code\compile\local_lights_init.sqf";
	};
};

///////////////////////////////////////////////////////////////////////////////////////////
// Sarge AI Area 

call compile preprocessFileLineNumbers "addons\UPSMON\scripts\Init_UPSMON.sqf";				// UPSMON (Needed for Sarge)
call compile preprocessfile "addons\SHK_pos\shk_pos_init.sqf";								// SHK (Needed for Sarge)
[] ExecVM "addons\SARGE\SAR_AI_init.sqf";													// SARGE AI - Roaming AI Survivor, Military and Bandit Groups

// For Custom Configuration see addons/SARGE/SAR_config.sqf
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// Logistics Area

[] ExecVM "custom\kh_actions.sqf";															// Refuel Script  
[] ExecVM "R3F_ARTY_AND_LOG\init.sqf";														// R3F Logistics

// For more Refuel Locations add object classes to Line 14 of custom\kh_actions.sqf
// Limited Towing/Lifting/Cargo - See R3F_ARTY_AND_LOG\R3F_LOG\config.sqf
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
// Admin Tools added by Traffiq
[] execVM "admintools\Activate.sqf";												 	// In-game Admin Tool Menu.
//[] execVM "playerstats.sqf";                                                         // In-game Debug Monitor
[] execVM "custom_monitor.sqf"; 
//
/////////////////////////////////////////////////////////////////////////////////////////

if (dayz_REsec == 1) then {
	#include "\z\addons\dayz_code\system\REsec.sqf"
};

//Start Dynamic Weather
if(true) then {
	execVM "\z\addons\dayz_code\external\DynamicWeatherEffects.sqf";
};

#include "\z\addons\dayz_code\system\BIS_Effects\init.sqf"
