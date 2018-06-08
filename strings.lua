local DLC_STRINGS =
{
	PROGRAMS =
	{
		AXE =
		{
			NAME = "AXE",
			DESC = "Halves firewalls (rounded down) on all devices within a 4 tile radius of targeted tile.",
			SHORT_DESC = "USE AXE",
			HUD_DESC = "BREAK HALF OF FIREWALLS\n4 TILE RADIUS",
			TIP_DESC = "BREAK HALF OF FIREWALLS FOR <c:77FF77>{1} PWR</c>",
		},

		BREACH = 
		{
			NAME = "BREACH",
			DESC = "Breaks 1 firewall, +1 for every use of this program this turn. Additional count resets next turn.",
			SHORT_DESC = "BREACH FIREWALL",
			HUD_DESC = "BREAKS FIREWALLS\nINCREASED EFFICIENCY WITH REPEATED USE",
			TIP_DESC = "BREAKS <c:FF8411>1 FIREWALL</c>. COST: <c:77FF77>{1} PWR</c>",
			TIP_DESC2 = "BREAKS <c:FF8411>%i FIREWALLS</c>. COST: <c:77FF77>{1} PWR</c>",		
		},

		BREACH_2 = 
		{
			NAME = "BREACH 2.0",
			DESC = "Breaks 1 firewall, +1 for every use of this program this turn. Additional count resets next turn.",
			SHORT_DESC = "BREACH FIREWALL",
			HUD_DESC = "BREAKS FIREWALLS\nINCREASED EFFICIENCY WITH REPEATED USE",
			TIP_DESC = "BREAKS <c:FF8411>1 FIREWALL</c>. COST: <c:77FF77>{1} PWR</c>",
			TIP_DESC2 = "BREAKS <c:FF8411>%i FIREWALLS</c>. COST: <c:77FF77>{1} PWR</c>",		
		},

		CONDENSE = 
		{
			NAME = "CAPACITOR",
			DESC = "Gain 10 PWR, lose 5 PWR capacity.\nPASSIVE: +5 PWR capacity.",
			SHORT_DESC = "DISCHARGE CAPACITOR",
			HUD_DESC = "TRADE 5 PWR CAPACITY FOR 10 PWR\nTOTAL PWR CAPACITY +5",
			WARNING = "PWR CAPACITY TOO LOW",
		},

		CROSSFEED = 
		{
			NAME = "CROSSFEED",
			DESC = "Each turn, transfer 1 firewall from source to target device and gain 2 PWR. On cooldown while active.",
			SHORT_DESC = "SELECT SOURCE",
			SHORT_DESC2 = "SELECT TARGET",
			HUD_DESC = "MODE 1: SELECT SOURCE OR\nREMOVE DESIGNATION",
			HUD_DESC2 = "MODE 2: SELECT TARGET OR\nREMOVE DESIGNATION",
			TIP_DESC = "SELECT SOURCE OR REMOVE DESIGNATION FOR <c:77FF77>{1} PWR</c>",
			TIP_DESC2 = "SELECT TARGET OR REMOVE DESIGNATION FOR <c:77FF77>{1} PWR</c>",
			WARNING = "CROSSFEED\n+2 PWR",
		},

		FADE =
		{
			NAME = "FADE",
			DESC = "Targets an agent. Cloak selected target for 1 turn. 9 turn cooldown.",
			SHORT_DESC = "INVISIBILITY",
			HUD_DESC = "CLOAK TARGET",
			TIP_DESC = "CLOAK THIS TARGET FOR {1} PWR",
		},

		FAUST =
		{
			NAME = "FAUST",
			DESC = "Gain 2 PWR/turn. If PWR stored is a multiple of 5 at start of player's turn, install a random Daemon.",
			SHORT_DESC = "AUTO GENERATE PWR AND DAEMONS",	
			HUD_DESC = "GAIN 2/TURN, IF PWR % 5 = 0 AT TURN START INSTALL DAEMON",
			WARNING = "FAUST\n+ 2 PWR",
		},

		FLAIL = 
		{
			NAME = "FLAIL",
			DESC = "Reduces first target's firewalls by the amount of firewalls on second target. Firewall/PWR ratio 1:1.5.",
			SHORT_DESC = "SELECT TARGET",
			SHORT_DESC2 = "SELECT BREAKER",
			HUD_DESC = "MODE 1: SELECT TARGET OR\nREMOVE DESIGNATION",
			HUD_DESC2 = "MODE 2: SELECT BREAKER OR\nREMOVE DESIGNATION",
			TIP_DESC = "SELECT TARGET OR REMOVE DESIGNATION",
			TIP_DESC2 = "BREAK FIREWALLS ON TARGET</c> FOR <c:77FF77>{1} PWR</c> OR REMOVE DESIGNATION",
		},

		FISSION =
		{
			NAME = "FISSION",
			DESC = "Gain 6 PWR. 8 turn cooldown. Capturing mainframe device reduces cooldown by 1.",
			SHORT_DESC = "ACTIVATE FISSION",
			HUD_DESC = "GAIN 6 PWR. REDUCE COOLDOWN WHEN CAPTURING DEVICES.",
			WARNING = "FISSION\n+6 PWR",
		},

		FORTIFY =
		{
			NAME = "FORTIFY",
			DESC = "Prevents recapturing of mainframe devices for 1 PWR after fully breaking through all firewalls. PASSIVE",
			SHORT_DESC = "RECAPTURE PREVENTION",
			HUD_DESC = "PREVENTS RECAPTURING OF MAINFRAME DEVICES",
			WARNING = "FORTIFY\n-1 PWR",
		},

		GREED =
		{
			NAME = "GREED",
			DESC = "Targets closed safe. Increase cash held by 'Alarm Level * 20%' once per safe. 6 turn cooldown.",
			SHORT_DESC = "BE GREEDY",
			HUD_DESC = "INCREASES CR IN SAFES",
			TIP_DESC = "INCREASE CR STORED FOR {1} PWR",
		},

		HEARTBREAKER =
		{
			NAME = "HEARTBREAKER",
			DESC = "Targets a guard. Disables Heart Monitors. Downgrades Improved Heart Monitors. 4 turn cooldown.",
			SHORT_DESC = "DISABLE HEART MONITOR",
			HUD_DESC = "DISABLE HEART MONITOR",
			TIP_DESC = "DISABLE HEART MONITOR FOR {1} PWR",
		},

		HUSHPUPPY_PWR =
		{
			NAME = "HUSHPUPPY V.PWR",
			DESC = "Disables all PWR subroutines of hostile AI for 3 turns. 5 turn cooldown.",
			SHORT_DESC = "DISABLE SUBROUTINES",
			HUD_DESC = "DISABLE PWR SUBROUTINES",
			WARNING = "HUSHPUPPY V.PWR\nDisabled PWR subroutines.",
		},

		HUSHPUPPY_PRO =
		{
			NAME = "HUSHPUPPY V.PRO",
			DESC = "Disables all PROACTIVE subroutines of hostile AI for 3 turns. 5 turn cooldown.",
			SHORT_DESC = "DISABLE SUBROUTINES",
			HUD_DESC = "DISABLE PRO SUBROUTINES",
			WARNING = "HUSHPUPPY V.PRO\nDisabled PROACTIVE subroutines.",
		},

		HUSHPUPPY_REA =
		{
			NAME = "HUSHPUPPY V.REA",
			DESC = "Disables all REACTIVE subroutines of hostile AI for 3 turns. 5 turn cooldown.",
			SHORT_DESC = "DISABLE SUBROUTINES",
			HUD_DESC = "DISABLE REA SUBROUTINES",
			WARNING = "HUSHPUPPY V.REA\nDisabled REACTIVE subroutines.",
		},

		LOTTERY = 
		{
			NAME = "LOTTERY",
			DESC = "Installs a random Algorithm. 8 turn cooldown.",
			SHORT_DESC = "ACTIVATE LOTTERY",
			HUD_DESC = "INSTALL RANDOM ALGORITHM",
		},

		LEECH =
		{
			NAME = "PWR LEECH",
			DESC = "Drains up to 4 PWR from hostile A.I. and transfers it to Incognita. 5 turn cooldown.",
			SHORT_DESC = "LEECH PWR",
			HUD_DESC = "TRANSFERS PWR FROM AI TO YOU",
			WARNING = "PWR LEECH\n+%i PWR",
		},

		OMNIWRENCH =
		{
			NAME = "OMNI WRENCH",
			DESC = "Completely break any firewall at a PWR cost equal to number of firewalls. 1 Turn cooldown.",
			SHORT_DESC = "USE OMNI WRENCH",
			HUD_DESC = "BREAK ANY FIREWALL\nCOST EQUAL TO FIREWALL AMOUNT",
			TIP_DESC = "BREAK ALL FIREWALLS",
		},

		OVERVIEW =
		{
			NAME = "OVERVIEW",
			DESC = "Install a remote camera on a target. Subsequent uses remove previous camera. 4 turn cooldown.",
			SHORT_DESC = "INSTALL CAMERA",
			HUD_DESC = "CURRENT TARGET:\n%s",
			TIP_DESC = "INSTALLS REMOTE CAMERA FOR {1} PWR",
			WARNING = "NONE",
		},

		NOSFERATU = 
		{
			NAME = "NOSFERATU",
			DESC = "PASSIVE: Gain X PWR at turn start while pinning guards. X = 1 + number of guards pinned.",
			SHORT_DESC = "GAIN PWR FOR PINNING",
			HUD_DESC = "GAIN PWR FOR PINNING UNITS",
			WARNING = "NOSFERATU\n+%i PWR",		
		},

		POWERSURGE = 
		{
			NAME = "POWER SURGE",
			DESC = "Gain 1 PWR after completely breaking a firewall. PASSIVE",
			SHORT_DESC = "BREAK FIREWALL TO ACTIVATE",
			HUD_DESC = "GAIN 1 PWR AFTER COMPLETELY BREAKING A FIREWALL",
			WARNING = "POWER SURGE\n+1 PWR",		
		},

		PWR_MANAGER =
		{
			DESC = "Increases the agency's starting PWR by 4 and maximum PWR capacity by 5.",
			SHORT_DESC = "INCREASE STARTING PWR AND PWR CAPACITY",
			HUD_DESC = "+4 STARTING PWR\n+5 PWR CAPACITY",
		},	
		
		PWR_MANAGER_2 =
		{
			DESC = "Increases the agency's starting PWR by 6 and maximum PWR capacity by 10.",
			SHORT_DESC = "INCREASE STARTING PWR AND PWR CAPACITY",
			HUD_DESC = "+6 STARTING PWR\n+10 PWR CAPACITY",
		},

		POWER_DRIP =
		{
			NAME = "POWER DRIP",
			DESC = "Gain 1 PWR/turn. Gain extra 1 PWR/turn if Alarm Level is below 1. PASSIVE",
			SHORT_DESC = "AUTO GENERATE PWR",
			HUD_DESC = "+1 PWR/TURN OR +2 PWR/TURN WHEN ALARM LEVEL BELOW 1",
			WARNING = "POWER DRIP\n%i PWR",
		},

		PWRUPLINK = 
		{
			NAME = "POWER UPLINK",
			DESC = "Create uplink on a mainframe device. +1 PWR/turn per active uplink. Max 4, 5 turn cooldown.",
			SHORT_DESC = "CREATE UPLINK",
			HUD_DESC = "CREATE POWER UPLINK ON MAINFRAME DEVICE\nMAX UPLINKS: 4",
			TIP_DESC = "CREATE UPLINK FOR <c:77FF77>{1} PWR</c>",
			WARNING = "POWER UPLINK\n+%i PWR",
		},

		RALLY = 
		{
			NAME = "RALLY",
			DESC = "Break 2 firewalls. 1 turn cooldown, resets when any guard is KO'ed or killed.",
			SHORT_DESC = "SELECT TARGET",
			HUD_DESC = "BREAKS 2 FIREWALLS. COOLDOWN RESETS ON GUARD KO/KILL",
			TIP_DESC = "BREAK 2 FIREWALLS ON TARGET FOR <c:77FF77>{1} PWR</c>",
			WARNING = "RALLY\nCOOLDOWN RESET",
		},

		REFLECT = 
		{
			NAME = "REFLECT",
			DESC = "PASSIVE MODE: Reversal chance +10%.\nACTIVE MODE: Reverse next DAEMON.\nStarts on cooldown.",
			SHORT_DESC = "SWITCH TO ACTIVE MODE",
			SHORT_DESC2 = "SWITCH TO PASSIVE MODE",
			SHORT_DESC3 = "ON COOLDOWN",
			HUD_DESC = "PASSIVE MODE\nREVERSAL CHANCE +10%",
			HUD_DESC2 = "ACTIVE MODE\nREVERSE DAEMON FOR 8 PWR",
			HUD_DESC3 = "PASSIVE MODE\nREVERSAL CHANCE INACTIVE",
		},

		ROOT =
		{
			DESC = "Generate +2 PWR per turn. All programs cost 1 more PWR. PASSIVE",
			SHORT_DESC = "AUTO GENERATE PWR",
			HUD_DESC = "+2 PWR PER TURN.\nPROGRAMS COST +1 PWR",
			WARNING = "ROOT\n+2 PWR",
		},

		SEARCH = 
		{
			NAME = "SEARCH",
			DESC = "Reveal random database. 2 turn cooldown.",
			SHORT_DESC = "REVEAL DATABASE",
			HUD_DESC = "REVEAL RANDOM DATABASE",
			WARNING = "NO UNDISCOVERED\nDATABASES LEFT",
		},
		SONAR = 
		{
			NAME = "SONAR",
			DESC = "Reveal area within 5 tile radius around targeted tile. 4 turn cooldown.",
			SHORT_DESC = "REVEAL FACILITY AREA",
			HUD_DESC = "REVEAL FACILITY AREA",
			TIP_DESC = "REVEAL HIGHLIGHTED AREA FOR <c:77FF77>{1} PWR</c>",
		},			
	},

	DAEMONS =
	{
		ALERT =
		{
			NAME = "ALERT",
			DESC = "All guards gain 4 AP. One random guard goes into hunting state.",
			SHORT_DESC = "INCREASED GUARD MOBILITY",
			ACTIVE_DESC = "ONE GUARD STARTS HUNTING\nALL GUARDS GAIN 4 AP FOR {1} {1:TURN|TURNS}",
		},

		ALERTV2 =
		{
			NAME = "ALERT 2.0",
			DESC = "All guards gain 6 AP.",
			SHORT_DESC = "INCREASED GUARD MOBILITY",
			ACTIVE_DESC = "ALL GUARDS GAIN 6 AP",
		},

		BLINDFOLD =
		{
			NAME = "BLINDFOLD",
			DESC = "Agents cannot peek.",
			SHORT_DESC = "NO PEEKING",
			ACTIVE_DESC = "AGENTS CANNOT PEEK FOR {1} {1:TURN|TURNS}",
		},

		CHAIN =
		{
			NAME = "CHAIN",
			DESC = "Alerting or killing a guard will install a random Daemon.",
			SHORT_DESC = "NEW DAEMON SPAWN TRIGGERS",
			ACTIVE_DESC = "GUARDS INSTALL A DAEMON WHEN ALERTED OR KILLED. EFFECT LASTS {1} {1:TURN|TURNS}",
		},

		CHAINV2 =
		{
			NAME = "CHAIN 2.0",
			DESC = "Alerting or killing a guard will install a random Daemon.",
			SHORT_DESC = "NEW DAEMON SPAWN TRIGGERS",
			ACTIVE_DESC = "GUARDS INSTALL A DAEMON WHEN ALERTED OR KILLED",
		},

		CLOCK =
		{
			NAME = "CLOCK",
			DESC = "Increases cooldown of all programs by 1.",
			SHORT_DESC = "INCREASED PROGRAM COOLDOWNS",
			ACTIVE_DESC = "PROGRAM COOLDOWNS INCREASED BY 1 FOR {1} {1:TURN|TURNS}",
		},

		CLOCKV2 =
		{
			NAME = "CLOCK 2.0",
			DESC = "Increases cooldown of all programs by 1.",
			SHORT_DESC = "INCREASED PROGRAM COOLDOWNS",
			ACTIVE_DESC = "PROGRAM COOLDOWNS INCREASED BY 1",
		},

		DISARM =
		{
			NAME = "DISARM",
			DESC = "Agents lose one attack action for the duration of this Daemon.",
			SHORT_DESC = "DISABLES AGENTS ATTACK",
			ACTIVE_DESC = "AGENTS LOSE ONE ATTACK ACTION FOR {1} {1:TURN|TURNS}",
		},

		DISARMV2 =
		{
			NAME = "DISARM 2.0",
			DESC = "Agents lose one attack action for the duration of this Daemon.",
			SHORT_DESC = "DISABLES AGENTS ATTACK",
			ACTIVE_DESC = "AGENTS LOSE ONE ATTACK ACTION",
		},

		GATEKEEPER =
		{
			NAME = "GATEKEEPER",
			DESC = "Exit elevator is closed for the duration of this Daemon.",
			SHORT_DESC = "EXIT LOCK",
			ACTIVE_DESC = "EXIT ELEVATOR IS LOCKED FOR {1} {1:TURN|TURNS}",
		},

		INSPECT =
		{
			NAME = "INSPECT",
			DESC = "Changes guard patrols.",
			SHORT_DESC = "GUARD PATROLS CHANGE",
			ACTIVE_DESC = "GUARDS CHANGE PATROL ROUTES",
		},

		LOCKDOWN =
		{
			NAME = "LOCKDOWN",
			DESC = "Opening a door increases Alarm Level by 1 and prompts a guard to investigate.",
			SHORT_DESC = "FACILITY LOCKDOWN",
			ACTIVE_DESC = "OPENING DOORS WILL TRIGGER AN ALARM",
			WARNING = "LOCKDOWN DAEMON\nGUARD ALERTED",
		},

		LOCKDOWNV2 =
		{
			NAME = "TERMINATION PROTOCOL",
			DESC = "Using a door prompts a guard to investigate. Agents also lose 1 attack action.",
			SHORT_DESC = "FACILITY LOCKDOWN",
			ACTIVE_DESC = "USING DOORS WILL TRIGGER AN ALARM, AGENTS LOSE ONE ATTACK ACTION\n",
			WARNING = "FACILITY LOCKDOWN\nGUARD ALERTED",
		},

		MODULATEV2 =
		{
			NAME = "MODULATE 2.0",
			DESC = "Programs cost +2 PWR to use.",
			SHORT_DESC = "PWR COST",
			ACTIVE_DESC = "+2 PWR COST TO PROGRAMS",
		},

		OWL =
		{
			NAME = "OWL",
			DESC = "Guards have extended vision range (+3 tiles) and arc (+30 degrees).",
			SHORT_DESC = "GUARD SIGHT IMPROVEMENT",
			ACTIVE_DESC = "GUARDS HAVE PERMANENTLY EXTENDED VISION RANGE (+3) AND ARC (+30*)",
		},

		OWLV2 =
		{
			NAME = "OWL 2.0",
			DESC = "Guards have extended vision range (+2 tiles) and arc (+45 degrees).",
			SHORT_DESC = "GUARDS SIGHT IMPROVEMENT",
			ACTIVE_DESC = "GUARDS HAVE EXTENDED VISION RANGE (+2) AND ARC (+45*)",
		},

		POISON =
		{
			NAME = "POISON",
			DESC = "Tag a random agent. When this Daemon expires, tagged agent will be KO for 2 turns.",
			SHORT_DESC = "KO TAGGED AGENT",
			ACTIVE_DESC = "KO TAGGED AGENT IN {1} {1:TURN|TURNS} FOR 2 TURNS",
		},

		POISONV2 =
		{
			NAME = "POISON 2.0",
			DESC = "Each alarm level, tagged agent will be KO for 2 turns then another random agent will be tagged.",
			SHORT_DESC = "PERIODICALLY KO TAGGED AGENT",
			ACTIVE_DESC = "KO TAGGED AGENT FOR 2 TURNS EVERY ALARM LEVEL",
		},

		PULSE =
		{
			NAME = "PULSE",
			DESC = "Short-circuits items and augments, adding 3 to all cooldowns.",
			SHORT_DESC = "INCREASED ITEM COOLDOWNS",
			ACTIVE_DESC = "ITEM AND AUGMENT COOLDOWNS INCREASED BY 3 FOR {1} {1:TURN|TURNS}",
		},

		PULSEV2 =
		{
			NAME = "PULSE 2.0",
			DESC = "Short-circuits items and augments, adding 3 to all cooldowns.",
			SHORT_DESC = "INCREASED ITEM COOLDOWNS",
			ACTIVE_DESC = "ITEM AND AUGMENT COOLDOWNS INCREASED BY 3",
		},

		SHACKLES =
		{
			NAME = "SHACKLES",
			DESC = "Agents make noise with a 4 tile radius while moving.",
			SHORT_DESC = "HEAVY FEET",
			ACTIVE_DESC = "AGENTS MAKE NOISE WHILE MOVING FOR {1} {1:TURN|TURNS}",
		},

		SHORT =
		{
			NAME = "SHORT",
			DESC = "Decreases PWR capacity.",
			DESC2 = "Decreases PWR capacity by {1}.",
			SHORT_DESC = "LOWER PWR CAPACITY",
			ACTIVE_DESC = "MAX PWR CAPACITY -{2} FOR {1} {1:TURN|TURNS}",
		},

		SHORTV2 =
		{
			NAME = "SHORT 2.0",
			DESC = "Decreases PWR capacity by 10. Further decreases PWR capacity by 1 for each alarm level.",
			SHORT_DESC = "LOWER PWR CAPACITY",
			ACTIVE_DESC = "MAX PWR CAPACITY -10 AND -1 FOR EACH ALARM LEVEL",
		},

		SLEEP =
		{
			NAME = "SLEEP",
			DESC = "Next player's turn is skipped.",
			SHORT_DESC = "SKIP TURN",
			ACTIVE_DESC = "SKIP PLAYER'S NEXT TURN",
		},

		--AI PROGRAMS

		ASSEMBLY =
		{
			NAME = "COUNTERINTELLIGENCE A.I.",
			DESC = "",
			SHORT_DESC = "",
			ACTIVE_DESC = "",
		},

	},

	AI =
	{
		UNKNOWN = "UNKNOWN SUBROUTINE",
		UNKNOWN_DESC = "UNKNOWN SUBROUTINE:\nHostile AI action detected.",
		UNKNOWN_TIP = "???",
		PWR = "PWR: %i/%i",
		PWR_UNKNOWN = "PWR: ???/???",
		SUPPRESSED = "SUPPRESSED",
		SUPPRESSED_DESC = "All subroutines from this category are suppressed, and won't trigger.",

		--PWR
		TERMINAL_LINK = "TERMINAL LINK [PWR]",
		TERMINAL_LINK_DESC = "TERMINAL LINK:\n+%i PWR for Corp.",
		TERMINAL_LINK_TIP = "PASSIVE: +1 PWR for every uncaptured Console.",

		FEEDBACK_GRID = "FEEDBACK GRID [PWR]",
		FEEDBACK_GRID_DESC = "FEEDBACK GRID:\n+%i PWR for Corp.",
		FEEDBACK_GRID_TIP = "PASSIVE: +1 PWR for every 4 captured devices (rounded up).",

		SOUNDWEAVE = "SOUNDWEAVE [PWR]",
		SOUNDWEAVE_DESC = "SOUNDWEAVE:\n+%i PWR for Corp.",
		SOUNDWEAVE_TIP = "PASSIVE: +1 PWR for every 2 uncaptured Sound Bugs (rounded down).",

		OPTIC_DOWNLINK = "OPTIC DOWNLINK [PWR]",
		OPTIC_DOWNLINK_DESC = "OPTIC DOWNLINK:\n+%i PWR for Corp.",
		OPTIC_DOWNLINK_TIP = "PASSIVE: +1 PWR for every 2 captured Cameras (rounded down).",

		DAEMON_CLUSTER = "DAEMON CLUSTER [PWR]",
		DAEMON_CLUSTER_DESC = "DAEMON CLUSTER:\n+%i PWR for Corp.",
		DAEMON_CLUSTER_TIP = "PASSIVE: +1 PWR for every 3 Daemons on mainframe devices (rounded up).",

		ALARM_SYNCHRONIZER = "ALARM SYNCHRONIZER [PWR]",
		ALARM_SYNCHRONIZER_DESC = "ALARM SYNCHRONIZER:\n+%i PWR for Corp.",
		ALARM_SYNCHRONIZER_TIP = "PASSIVE: +1 PWR for every 2 Alarm Levels each turn (rounded up).",

		COUNTERWEIGHT = "COUNTERWEIGHT [PWR]",
		COUNTERWEIGHT_DESC = "COUNTERWEIGHT:\n+%i PWR for Corp.",
		COUNTERWEIGHT_TIP = "PASSIVE: +1 PWR for every 2 captured Pressure Sensors (rounded up).",

		LEECH = "PWR LEECH [PWR]",
		LEECH_DESC = "PWR LEECH: +%i PWR for Corp.\nINCOGNITA: -%i PWR.",
		LEECH_TIP = "PASSIVE: +2 PWR for every 1 PWR drained from Incognita.",

		CYCLONE = "CYCLONE [PWR]",
		CYCLONE_DESC = "CYCLONE:\n+%i PWR for Corp.",
		CYCLONE_TIP = "PASSIVE: +1 PWR for every 5 AP spent by agents this turn (rounded down).",

		DIRECT_FEED = "DIRECT FEED [PWR]",
		DIRECT_FEED_DESC = "DIRECT FEED:\n+%i PWR for Corp.",
		DIRECT_FEED_TIP = "PASSIVE: Generates PWR equal to hacked firewalls.",

		GENERATOR = "GENERATOR [PWR]",
		GENERATOR_DESC = "GENERATOR:\n+%i PWR for Corp.",
		GENERATOR_TIP = "PASSIVE: +2 PWR per turn.",

		--Proactive

		BUCKLER = "BUCKLER [PRO](CD: %s/%s)",
		BUCKLER_DESC = "BUCKLER: Raised\nfirewalls on %s by 1.",
		BUCKLER_TIP = "Raises firewalls on objects by 1 for 2 PWR.",

		HEATER = "HEATER [PRO](CD: %s/%s)",
		HEATER_DESC = "HEATER: Raised\nfirewalls on %s by %i.",
		HEATER_TIP = "Raises firewalls on objects by (PWR/5, rounded up) for 3 PWR.",

		KITE = "KITE [PRO](CD: %s/%s)",
		KITE_DESC = "KITE: Raised firewalls\naround %s by 1.",
		KITE_TIP = "Raises firewalls in a radius of 3 around and including target object by 1 for 3 PWR.",

		PAVISE = "PAVISE [PRO](CD: %s/%s)",
		PAVISE_DESC = "PAVISE: Doubled\nfirewalls on %s.",
		PAVISE_TIP = "Doubles firewalls on objects for 5 PWR.",

		TARGE = "TARGE [PRO](CD: %s/%s)",
		TARGE_DESC = "TARGE: Raised\nfirewalls on %ss by 1.",
		TARGE_TIP = "Raises firewalls on objects of the same type by 1 for 5 PWR.",

		SAFE_MODE = "SAFE MODE [PRO](CD: %s/%s)",
		SAFE_MODE_DESC = "SAFE MODE: Rebooted\nshops and server terminals.",
		SAFE_MODE_TIP = "Reboots all Nanofabs and Server Terminals for 3 turns. 3 PWR cost.",

		OBFUSCATE = "OBFUSCATE [PRO](CD: %s/%s)",
		OBFUSCATE_DESC = "OBFUSCATE: Removed T.A.G.\nfrom %s.",
		OBFUSCATE_TIP = "Removes a T.A.G. from a guard and generates 1 PWR. 0 PWR cost.",

		PHASE_SHIFT = "PHASE SHIFT [PRO](CD: %s/%s)",
		PHASE_SHIFT_DESC = "PHASE SHIFT:\nTeleporting %s.",
		PHASE_SHIFT_TIP = "Teleports a guard to or adjacent to his interest point. 4 PWR cost.",

		PING = "PING [PRO](CD: %s/%s)",
		PING_DESC = "PING: Sound emitted\nat all agent's locations.",
		PING_TIP = "Emits sound at all agent's locations for 4 PWR.",

		CHITON = "CHITON [PRO](CD: %s/%s)",
		CHITON_DESC = "CHITON: Raised\narmor on %s.",
		CHITON_TIP = "Raises armor of a guard by 1 for 6 PWR.",

		FRACTAL = "FRACTAL [PRO](CD: %s/%s)",
		FRACTAL_DESC = "FRACTAL: Installed Daemon\non %s.",
		FRACTAL_TIP = "Installs Daemons on devices for 4 PWR.",

		BLOWFISH = "BLOWFISH [PRO](CD: %s/%s)",
		BLOWFISH_DESC = "BLOWFISH:\n Alarm +%i.",
		BLOWFISH_TIP = "Raises alarm by 1 for 3 PWR.",

		BLIZZARD = "BLIZZARD [PRO](CD: %s/%s)",
		BLIZZARD_DESC = "BLIZZARD: All Agent's\nAP is reduced by 2.",
		BLIZZARD_TIP = "Reduces AP of all agents by 2 to a Min of 4 for 4 PWR.",

		ECHO = "ECHO [PRO](CD: %s/%s)",
		ECHO_DESC = "ECHO:\n Rebooted a device.",
		ECHO_TIP = "Reboots a device for 4 PWR.",

		REROUTE = "REROUTE [PRO](CD: %s/%s)",
		REROUTE_DESC = "REROUTE:\nChanged guard patrols.",
		REROUTE_TIP = "Changes guard patrols for 5 PWR.",

		PINPOINT = "PINPOINT [PRO](CD: %s/%s)",
		PINPOINT_DESC = "PINPOINT: %s\ndetected and AP halved.",
		PINPOINT_TIP = "Halves AP of an agent and relays position to security. 4 PWR cost.",

		NULL_PULSE = "NULL PULSE [PRO](CD: %s/%s)",
		NULL_PULSE_DESC = "NULL PULSE: Installed\n'NULL ZONE' on %s",
		NULL_PULSE_TIP = "Target gains 'NULL ZONE' ability, 4 tile range. 3 PWR cost.",

		TREATY = "TREATY [PRO](CD: %s/%s)",
		TREATY_DESC = "TREATY: Incognita\nlocked for 3 turns.",
		TREATY_TIP = "Disables Incognita for 3 turns. 5 PWR cost.",

		SUPERVISION = "SUPERVISION [PRO](CD: %s/%s)",
		SUPERVISION_DESC = "SUPERVISION: %s\nis immune to hacking.",
		SUPERVISION_TIP = "Affected Camera cannot be hacked until AI cooldown expires. 1 PWR cost.",

		RECALIBRATE = "RECALIBRATE [PRO](CD: %s/%s)",
		RECALIBRATE_DESC = "RECALIBRATE:\nRebooting all Sound Bugs.",
		RECALIBRATE_TIP = "Recaptures all captured Sound Bugs for 4 PWR.",

		FIEND = "FIEND [PRO](CD: %s/%s)",
		FIEND_DESC = "FIEND: Program slot %i disabled.",
		FIEND_TIP = "Disables Incognita program for 2 PWR.",

		BUNKER = "BUNKER [PRO](CD: %s/%s)",
		BUNKER_DESC = "BUNKER: Raised\nall firewalls by 1.",
		BUNKER_TIP = "Raises all firewalls by 1. 8 PWR cost.",

		--REACTIVE

		PAWN = "PAWN [REA](CD: %s/%s)",
		PAWN_DESC = "PAWN: Reinforced\n firewalls on %s.",
		PAWN_TIP = "Reinforces broken firewalls by 1. 2 PWR cost.",

		ROOK = "ROOK [REA](CD: %s/%s)",
		ROOK_DESC = "ROOK: Swapped\nfirewalls with %s.",
		ROOK_TIP = "After breaking a firewall, swaps firewalls with another device for 3 PWR.",

		KNIGHT = "KNIGHT [REA](CD: %s/%s)",
		KNIGHT_DESC = "KNIGHT: Reinforced\n firewalls around %s.",
		KNIGHT_TIP = "Raises firewalls by 2 around hacked device in a 2 tile radius. 4 PWR cost.",

		BISHOP = "BISHOP [REA](CD: %s/%s)",
		BISHOP_DESC = "BISHOP: Reinforced\n firewalls on %s.",
		BISHOP_TIP = "Reinforces broken firewalls by (PWR /5 , rounded up). 4 PWR cost.",

		QUEEN = "QUEEN [REA](CD: %s/%s)",
		QUEEN_DESC = "QUEEN: Reinforced\n firewalls on all %ss.",
		QUEEN_TIP = "Raises firewalls by 1 on all devices of the same type as the one hacked. 5 PWR cost.",

		KING = "KING [REA](CD: %s/%s)",
		KING_DESC = "KING: Reinforced\n firewalls on %s.",
		KING_TIP = "Reinforces broken firewalls by doubling remaining value. 4 PWR cost.",

		BACKUP_PROTOCOLS = "BACKUP PROTOCOLS [REA](CD: %s/%s)",
		BACKUP_PROTOCOLS_DESC = "BACKUP PROTOCOLS: Called in a guard.",
		BACKUP_PROTOCOLS_TIP = "Calls in a guard when another is alerted or killed for 5 PWR.",

		ELECTROSHOCK = "ELECTROSHOCK [REA](CD: %s/%s)",
		ELECTROSHOCK_DESC = "ELECTROSHOCK:\n %s knocked out.",
		ELECTROSHOCK_TIP = "KO agent opening any container object for 3 turns. 5 PWR cost.",

		HASHED_CRYPTO = "HASHED CRYPTO [REA](CD: %s/%s)",
		HASHED_CRYPTO_DESC = "HASHED CRYPTO: Safes\ncontain 50% less CR.",
		HASHED_CRYPTO_TIP = "Opening any container object halves credits in all Safes.",

		PAYWALL = "PAYWALL [REA](CD: %s/%s)",
		PAYWALL_DESC = "PAYWALL: Nanofabricator\nitem cost +25%.",
		PAYWALL_TIP = "Increases item costs in Nanofabricators by 25% when an item is bought. 2 PWR cost.",

		CIRCUIT_BREAKER = "CIRCUIT BREAKER [REA](CD: %s/%s)",
		CIRCUIT_BREAKER_DESC = "CIRCUIT BREAKER:\nGuard notified",
		CIRCUIT_BREAKER_TIP = "Using a Console will draw the attention of a guard. 2 PWR cost.",

		SAFEGUARD = "SAFEGUARD [REA](CD: %s/%s)",
		SAFEGUARD_DESC = "SAFEGUARD:\nRebooted a Console.",
		SAFEGUARD_TIP = "When a Console is used, reboots another one for 4 turns. 3 PWR cost.",

		SUBTERFUGE = "SUBTERFUGE [REA](CD: %s/%s)",
		SUBTERFUGE_DESC = "SUBTERFUGE: Drained\nAP of %s.",
		SUBTERFUGE_TIP = "Drains all AP from agents caught by a Camera. 4 PWR cost.",

		VERIFY = "VERIFY [REA](CD: %s/%s)",
		VERIFY_DESC = "VERIFY: +1 Max AP\nfor %s.",
		VERIFY_TIP = "Creating an interest point will increase the max AP of that guard by 1. 3 PWR cost.",

		SCANNER_SWEEP = "SCANNER SWEEP [REA](CD: %s/%s)",
		SCANNER_SWEEP_DESC = "SCANNER SWEEP: 180* peripheral\nvision for %s.",
		SCANNER_SWEEP_TIP = "Creating an interest point will set that guard's peripheral vision arc to 180* for 1 turn. 2 PWR cost.",

		SPEED_BUMP = "SPEED BUMP [REA](CD: %s/%s)",
		SPEED_BUMP_DESC = "SPEED BUMP: -2 AP\nfor %s.",
		SPEED_BUMP_TIP = "Agents opening a door lose 2 AP. 3 PWR cost.",

		BLOCKADE = "BLOCKADE [REA](CD: %s/%s)",
		BLOCKADE_DESC = "BLOCKADE: %s\nsent to guard that door.",
		BLOCKADE_TIP = "Opening a door sends a guard to block that door. 2 PWR cost.",

		SENTINEL = "SENTINEL [REA](CD: %s/%s)",
		SENTINEL_DESC = "SENTINEL:\nTurning turret.",
		SENTINEL_TIP = "Turrets turn to face an agent when they step within 3 tiles of it. 3 PWR cost.",

		FAKEOUT = "FAKEOUT [REA](CD: %s/%s)",
		FAKEOUT_DESC = "FAKEOUT: Daemon shuffled\non %s.",
		FAKEOUT_TIP = "Shuffle known Daemon when capturing a device. 2 PWR cost.",

		FAILSAFE = "FAILSAFE [REA](CD: %s/%s)",
		FAILSAFE_DESC = "FAILSAFE: Guard sent to\ninvestigate %s.",
		FAILSAFE_TIP = "Capturing a Drone will send another guard to investigate for 3 PWR.",

		TERMINATE = "TERMINATE [REA](CD: %s/%s)",
		TERMINATE_DESC = "TERMINATE: %s\nskips OVERWATCH.",
		TERMINATE_TIP = "Guards skip Overwatch for 6 PWR. 4 turn cooldown.",

		--UTILITY
		JAMMER = "JAMMER [ENH]",
		JAMMER_DESC = "JAMMER: Cannot hack\n%s.",
		JAMMER_TIP = "PASSIVE: Breaking a firewall makes that device immune to hacking. Applies to most recently hacked device.",

		PADLOCK = "PADLOCK [ENH]",
		PADLOCK_DESC = "PADLOCK:\nDoors locked.",
		PADLOCK_TIP = "PASSIVE: Locks all unlocked Security Doors every turn.",

		TAG_DOWNLINK = "T.A.G. DOWNLINK [ENH]",
		TAG_DOWNLINK_DESC = "T.A.G. DOWNLINK:\n %i PWR drained from Incognita.",
		TAG_DOWNLINK_TIP = "PASSIVE: Drain 1 PWR from Incognita for each tagged guard every turn.",

		DEFECTIVE_TAG = "DEFECTIVE T.A.G. [ENH]",
		DEFECTIVE_TAG_DESC = "DEFECTIVE T.A.G:\n+4 AP for tagged guards.",
		DEFECTIVE_TAG_TIP = "PASSIVE: +4 AP for tagged guards. Applies when turn starts.",

		TRANSLOCATOR_EQUIPMENT = "TRANSLOCATOR EQUIPMENT [ENH]",
		TRANSLOCATOR_EQUIPMENT_TIP = "PASSIVE: Some guards are equipped with Translocator Grenades.",

		PROXIMAL = "PROXIMAL [ENH]",
		PROXIMAL_DESC = "PROXIMAL:\nPickpocketed %s.",
		PROXIMAL_TIP = "PASSIVE: Pickpocketing a guard makes him turn towards an agent.",

		SNARE_EQUIPMENT = "SNARE EQUIPMENT [ENH]",
		SNARE_EQUIPMENT_TIP = "PASSIVE: All guards are equipped with Snare Grenades.",

		NETWORKED_CONSCIOUSNESS = "NETWORKED CONSCIOUSNESS [ENH]",
		NETWORKED_CONSCIOUSNESS_TIP = "PASSIVE: All guards have CONSCIOUSNESS MONITOR, raising alarm when KO'ed.",

		EM_SHIELDING = "EM SHIELDING [ENH]",
		EM_SHIELDING_TIP = "PASSIVE: All devices have 'MAGNETIC REINFORCEMENT', making them EMP resilient.",

		SHOCK_GROUNDING = "ANTI-SHOCK GROUNDING [ENH]",
		SHOCK_GROUNDING_TIP = "PASSIVE: All human guards cannot be KO'ed.",

		VIDEO_COPROCESSORS = "VIDEO CO-PROCESSORS [ENH]",
		VIDEO_COPROCESSORS_TIP = "PASSIVE: All human guards have 'ULTRAVIOLET SPECTROMETER', detecting cloaked agents.",

		EMERGENCY_SHUTDOWN = "EMERGENCY SHUTDOWN [ENH]",
		EMERGENCY_SHUTDOWN_DESC = "EMERGENCY SHUTDOWN:\n Console turned off.",
		EMERGENCY_SHUTDOWN_TIP = "PASSIVE: Permanently turns off Consoles used to counter AI.",
	},

	REVERSE_DAEMONS =
	{
		AGGRESSION =
		{
			NAME = "AGGRESSION",
			DESC = "All agents have an extra attack.",
			SHORT_DESC = "INCREASE AMOUNT OF ATTACKS",
			ACTIVE_DESC = "ALL AGENTS HAVE AN EXTRA ATTACK FOR {1} {1:TURN|TURNS}",
		},

		BATTERY =
		{
			NAME = "BATTERY",
			DESC = "Increases PWR capacity by 5 until the end of the mission. Gain 4 PWR.",
			SHORT_DESC = "RAISE PWR CAPACITY",
			ACTIVE_DESC = "MAX PWR CAPACITY +5\nGAIN 4 PWR",
		},

		CHARGER =
		{
			NAME = "RECHARGE",
			DESC = "Reduces cooldowns of all items by 1 to a minimum of 2 turns.",
			SHORT_DESC = "DECREASED ITEM COOLDOWNS",
			ACTIVE_DESC = "ITEM COOLDOWNS DECREASED BY 1 (MIN 2) FOR {1} {1:TURN|TURNS}",
		},

		CONFUSION =
		{
			NAME = "CONFUSION",
			DESC = "The next corporation turn is skipped.",
			SHORT_DESC = "SKIP TURN",
			ACTIVE_DESC = "SKIP CORPORATION'S NEXT TURN",
		},

		FORTUNE =
		{
			NAME = "FORTUNE",
			DESC = "Increases amount of Credits stored in closed safes by 50%.",
			SHORT_DESC = "STORAGE INCREASE",
			ACTIVE_DESC = "SAFES STORE +50% CREDITS FOR {1} {1:TURN|TURNS}",
		},

		OPTIMIZE =
		{
			NAME = "OPTIMIZE",
			DESC = "Reduces cooldowns of all programs by 1 to a minimum of 1.",
			SHORT_DESC = "REDUCE PROGRAM COOLDOWNS",
			ACTIVE_DESC = "REDUCE PROGRAM COOLDOWNS BY 1 (MIN 1) FOR {1} {1:TURN|TURNS}",
		},

		ROLLBACK =
		{
			NAME = "ROLLBACK",
			DESC = "Decrement Alarm Level by 2.",
			SHORT_DESC = "LOWER ALARM",
			ACTIVE_DESC = "DECREMENT ALARM LEVEL BY 2",
		},

		SMOKESCREEN =
		{
			NAME = "SMOKESCREEN",
			DESC = "Reduces vision range of guards by 4 tiles.",
			SHORT_DESC = "GUARD VISION REDUCTION",
			ACTIVE_DESC = "GUARDS HAVE PERMANENTLY REDUCED VISION RANGE BY 2 TILES",
		},

		TURBINE =
		{
			NAME = "TURBINE",
			DESC = "Gain 2 PWR at start of the turn.",
			SHORT_DESC = "GENERATE PWR",
			ACTIVE_DESC = "GAIN 2 PWR PER TURN FOR {1} {1:TURN|TURNS}",
			WARNING = "TURBINE\n+2 PWR",
		},
	},

	PROPS =
	{
		EXTRA_SERVER_TERMINAL = "Auxiliary Server Terminal",
	},

	OPTIONS =
	{
		ENABLE_PROGRAMS = "EXTENDED PROGRAMS",
		ENABLE_PROGRAMS_TIP = "<c:FF8411>EXTENDED PROGRAMS</c>\nEnable new programs:\nAxe\nBreach (2.0)\nCapacitor\nCrossFeed\nFlail\nFission\nFortify\nLottery\nOmni Wrench\nNosferatu\nPower Surge\nPower Uplink\nRally\nReflect\nSearch\nSonar",

		ENABLE_DAEMONS = "EXTENDED DAEMONS",
		ENABLE_DAEMONS_TIP = "<c:FF8411>EXTENDED DAEMONS</c>\nEnable new Daemons:\nAlert\nBlindfold\nChain (2.0)\nClock (2.0)\nDisarm (2.0)\nGatekeeper\nInspect\nOwl\nPoison (2.0)\nPulse\nShackles\nShort (2.0)\nSleep",

		ENABLE_ALGORITHMS = "EXTENDED ALGORITHMS",
		ENABLE_ALGORITHMS_TIP = "<c:FF8411>EXTENDED ALGORITHMS</c>\nEnable new Algorithms:\nAggression\nBattery\nCharge\nConfusion\nOptimize\nRollback\nSmokescreen\nTurbine",

		ENABLE_ALARMS = "EXTENDED ALARMS",
		ENABLE_ALARMS_TIP = "<c:FF8411>EXTENDED ALARMS</c>\nChanges alarm tracker.\n\nDISABLED: 6 alarm levels and 5 increments per level. (Default)\n\nNORMAL: 8 alarm levels and 5 increments per level, alarm stages are significantly harder.\n\nHARD: 8 alarm levels and 4 increments per level, alarm stages are significantly harder.",
		ENABLE_ALARMS_TRUE_2 = "HARD",
		ENABLE_ALARMS_TRUE = "NORMAL",
		ENABLE_ALARMS_FALSE = "DISABLED",

		ENABLE_SHOP = "BASE GAME CHANGES",
		ENABLE_SHOP_TIP = "<c:FF8411>BASE GAME CHANGES</c>\nPower Drip: +1 extra PWR/turn if Alarm Level < 1.\nFaust: Spawns Daemon if PWR stored is a multiple of 5 at turn start.\nRoot: +2 PWR/turn, program PWR costs +1.\nFortune increases credits in safes by 50%.\nPulse 2.0 and Modulate 2.0 are now permanent.\nAbacus programs also increase max PWR.\nNew Auxiliary Server Terminal with 4 programs.\nPrimary Server Terminals has 6 programs.",

		ENABLE_RARITY = "PROGRAM RARITY REBALANCE",
		ENABLE_RARITY_TIP = "<c:FF8411>PROGRAM RARITY REBALANCE</c>\nAll programs can be found in stores.\nProgram rarity rebalanced.\nPrimary Servers contain offensive programs.\nSecondary Servers contain utility programs.",

		ENABLE_WHEEL = "ALARM WHEEL GFX",
		ENABLE_WHEEL_TIP = "<c:FF8411>ALARM WHEEL GFX</c>\nReplaces alarm wheel graphic. Recommended if 'EXTENDED ALARMS' option is set to 'HARD'.",

		ENABLE_COUNTER_AI = "COUNTERINTELLIGENCE AI",
		ENABLE_COUNTER_AI_TIP = "<c:FF8411>COUNTERINTELLIGENCE AI</c>\nEach corporation brings their own counterintelligence A.I. to the table, that follows the same gameplay rules as Incognita: it's an intangible entity with a PWR pool and a set of programs dependent on corporation. Will protect the mainframe depending on its program setup. Setting adds all new tools required to deal with the new threat, including specialized programs and Console-focused events.\n\nSelect difficulty level from where AIs starts appearing.",
		ENABLE_COUNTER_AI_DISABLED = "DISABLED",
		ENABLE_COUNTER_AI_OMNI = "OMNI ONLY",

		ENDLESS_DAEMONS = "ENDLESS DAEMONS",
		ENDLESS_DAEMONS_TIP = "<c:FF8411>ENDLESS DAEMONS</c>\nSet day when 2.0 Daemons start appearing in Endless mode.",
		ENDLESS_DAEMONS_DISABLED = "DISABLED",
	},

	UI =
	{
		TARGET_PWRUPLINK = "POWER UPLINK ACTIVE",
		TARGET_CROSSFEED_S = "CROSSFEED SOURCE",
		TARGET_CROSSFEED_T = "CROSSFEED TARGET",
		TARGET_FLAIL = "FLAIL TARGET",

		HIJACK_CONSOLE_DESC = "Hack this console to reclaim its PWR. Reveals one subroutine of active AI. ",
		HIJACK_CONSOLE_DESC_CONVERT_TO_CRED = "Use {1} to convert this console's PWR to credits. Reveals one subroutine of active AI.",
		
		GREED = "GREED BOOST",
		GREED_DESC = "Amount of cash increased by {1}%",
		GREED_BOOST = "INCREASED CASH AMOUNT",

		MONITOR_DOWNGRADED = "DOWNGRADED HEART MONITOR",
		JAMMED = "JAMMED BY A.I.",

		REASON_NOT_HIJACKED = "CONSOLE NOT HIJACKED",
		REASON_NO_AI = "A.I. NOT ACTIVE",
		REASON_NO_AI_ROUTINE = "NOTHING TO DISABLE",
		REASON_DIRECTION = "STAND IN FRONT OF THE CONSOLE",
		REASON_ALREADY_SUPPRESSED = "ALREADY SUPPRESSED",

		AI_COMBAT = "A.I. ACCESS",
		AI_SKILL = "SKILL ENHANCEMENT",
		AI_SKILL_DELAY = "Each level of HACKING skill above 2 reduces Console reboot time by 1 turn.",
		AI_SKILL_PWR = "Each level of HACKING skill above 3 increases transfered PWR by 2.",
		AI_SCAN = "ACQUIRE READINGS",
		AI_SCAN_DESC = "Get PWR and cooldown readings for A.I. Lasts until end of turn. Costs 1 PWR. Removes 'Fiend' program lock.",
		AI_DELAY = "DELAY SUBROUTINES",
		AI_DELAY_DESC = "Delay activation of subroutines by 1 turn. Costs 1 PWR. Reboots Console for [5 TURNS] - [%i BONUS].",
		AI_PWR = "TRANSFER PWR",
		AI_PWR_DESC = "Drain 5 PWR from A.I. Transfer [%i] of it to Incognita. Reboots Console for 4 turns.",
		AI_DISABLE = "DISABLE SUBROUTINE",
		AI_DISABLE_DESC = "Disables one of the AI subroutines with a corresponding symbol. Costs 10 PWR.",

		TRANSLOCATOR_GRENADE = "TRANSLOCATOR GRENADE",
		TRANSLOCATOR_GRENADE_DESC = "Teleports user to its location when thrown.",

		SNARE_GRENADE = "SNARE GRENADE",
		SNARE_GRENADE_DESC = "Teleports agents in a 3 tile radius toward its location.",

		FORTIFY = "DEVICE FORTIFIED",
		FORTIFY_DESC = "This mainframe device is protected from recapturing.",

		ICEBREAK = "POWER UPLINK",
		ICEBREAK_DESC = "Generates 1 PWR at the start of each turn. Uplink disappears if device is hacked or EMP'ed.",

		CROSSFEED_SOURCE = "CROSSFEED SOURCE",
		CROSSFEED_SOURCE_DESC = "Lowers firewalls by 1 at the start of next turn. Crossfeed links disappear if either device is hacked or EMP'ed.",

		CROSSFEED_TARGET = "CROSSFEED TARGET",
		CROSSFEED_TARGET_DESC = "Raises firewalls by 1 at the start of next turn. Crossfeed links disappear if either device is hacked or EMP'ed.",

		FLAIL_TARGET = "FLAIL TARGET",
		FLAIL_TARGET_DESC = "This device is a target of Flail. Designation disappears if device is hacked or EMP'ed.",

		BLINDFOLD = "BLINDFOLD",
		BLINDFOLD_DESC = "Daemon prevents peeking.",

		POISON = "POISONED",
		POISON_DESC = "KO this agent when Poison Daemon triggers.",

		NULL_ZONE = "NULL ZONE",
		NULL_ZONE_DESC = "This device emits a field which blocks hacking of firewalls in a range of {1} {1:tile|tiles}.",

		ALARM_OWL = "The corporation is activating additional cameras. You have one turn before they are fully activated. {1: |All guards have extended vision range and arc.}",
		ALARM_SPEED = "The corporation has boosted guard speed. All guards have +6 AP. Enforcer units have arrived.",
		ALARM_OWL_SPEED = "The corporation has boosted guard perception and speed. All guards have +6 AP, extended vision range and arc.",
		ALARM_GUARDBUFF = "The corporation has boosted guard defence. All guards have +1 ARMOR and +1 KO RESIST. Enforcer units have arrived.",
		ALARM_REBOOT = "The corporation has ordered a mainframe reboot. %i devices have been rebooted.",
		ALARM_LOCKDOWN = "The corporation has ordered a total facility lockdown. All doors are alarmed and agents lose one attack action. Get your agents out of here Operator!",

		ALARM_NEXT_OWL = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nGuard vision range and arc will increase.",
		ALARM_NEXT_SPEED = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nGuard AP will increase. 2 Enforcers will arrive.",
		ALARM_NEXT_OWL_SPEED = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nGuard AP, vision range and arc will increase.",
		ALARM_NEXT_GUARDBUFFS = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nGuard ARMOR and KO resistance will be increased. 2 Enforcers will arrive.",
		ALARM_NEXT_REBOOT = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nThe majority of mainframe devices will be rebooted.",
		ALARM_NEXT_LOCKDOWN = "\n\n<c:F4FF78>NEXT SECURITY MEASURE:</>\nTotal facility lockdown will be ordered.",
	},

	LOGS =
	{
		LOG01_FILE = "Hostile A.I. Operation",
		LOG01_TITLE = "Central Briefing Log 12413943A93T4",
		LOG01 = [[<c:62B3B3>After some intense study and many field encounters, we have deciphered the framework and behaviour of the hostile A.I.s that you've encountered, Operator. Here's a basic rundown:

			- The A.I. has its own PWR pool, like Incognita, and uses it to execute subroutines. Each subroutine has its own cooldowns.

			- Each A.I. has a certain number of slots for subroutines. The amount of each type is dependent on the corporation it is hosted in and the on-site security level. There are four categories of these slots.

			- First, symbolized by a boxed lightning bolt, are PWR subroutines. These provide PWR for the A.I. Unlike PWR programs used by Incognita, these are often conditional, allowing you to deprive the A.I. of its resources.

			- Second, symbolized by a brain, are PROACTIVE subroutines. The A.I. will use these to reinforce on-site security whenever possible, if off cooldown and sufficient PWR is available.

			- Third, symbolized by an exclamation mark '!', are REACTIVE subroutines. Agents or Incognita must perform specific actions to trigger these subroutines. Since they use resources, you can wait for a lack of PWR or active cooldown to avoid these.

			- Last, symbolized by a large lightning bolt, are ENHANCEMENT subroutines. These are passive effects that alter something on-site, and can be quite powerful. These are always active.

			- All subroutines need to be identified first. To do that, an agent has to hijack a Console. Each Console will identify one subroutine. Note, that with advanced A.I.s, there may be more subroutines than there is Consoles. For these situations, look for specific items or programs to help.

			- Unless identified, the effects of subroutines are mostly hidden. Identify subroutines, and Incognita will inform you of their actions. Alternatively, you can carefully observe the mission location for clues about what subroutines are in use.

			Your agents can hinder the A.I. by using Consoles. These interactions will temporarily disable the used Console, and require some degree of HACKING skill, as well as PWR from Incognita. There are also programs or items that can help with the job.</>]],
	},
}

return DLC_STRINGS