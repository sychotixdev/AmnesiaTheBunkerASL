// v0.1 of Amnesia: The Bunker for Steam Demo (5/23/23)
// Written by Sychotix (twitch.tv/sychotixx... but I don't stream much)

// Steam
state("AmnesiaTheBunker_Demo_Steam", "Demo")
{
	int loadingBitMask   : "AmnesiaTheBunker_Demo_Steam.exe", 0x00988718, 0x158, 0x210;
	float loadingPercentage   : "AmnesiaTheBunker_Demo_Steam.exe", 0x00988718, 0x158, 0xF0; // Unused, but we could
	string15 mapScriptName   : "AmnesiaTheBunker_Demo_Steam.exe", 0x00988718, 0x180, 0x268;
}

startup {

	settings.Add("autoStart", true, "Start Automatically");
}

init {
	vars.startingNewRun = false;
	vars.hitStartLoad = false;
	vars.useBitMask = false;
}

update {

	// This is required because there is ~1 second before loading actually begins, but map script has changed
	if (current.mapScriptName != null && current.mapScriptName.Trim() == "officer_hub.hpm")
	{
		// If we came from main_menu to officer_hub, we are trying to start a new run
		if (old.mapScriptName != null && 
			old.mapScriptName.Trim() == "main_menu.hpm")
		{
			print("[Bunker ASL]  Think we are starting a new run.");
			vars.startingNewRun = true;
		}
	}
	// If we are on anything not officer_hub, we are not starting a new run
	else if (current.mapScriptName != null)
	{
		vars.startingNewRun = false;
	}
	
	// If we are starting a new run, check if we have hit starting loaded
	if (vars.startingNewRun && current.loadingPercentage > 0.0f)
	{
		vars.hitStartLoad = true;
	}
	
}

start {

	if (vars.useBitMask)
	{

		// Only if our update says we are starting a new run, previously were loading, and are no longer loading
		if (vars.startingNewRun && (old.loadingBitMask & 0x00000100) > 0 && (current.loadingBitMask & 0x00000100) == 0) {
			print("[Bunker ASL] Starting new run.");
			vars.startingNewRun = false;
			return true;
		}
	}
	else if (vars.startingNewRun && vars.hitStartLoad && current.loadingPercentage == 0.0f)
	{
		print("[Bunker ASL] Starting new run.");
		vars.startingNewRun = false;
		vars.hitStartLoad = false;
		return true;
	}
	
	return false;
}

split {
	return false;
}

reset {
	// If we are in the menu, reset
	// Temporarily disabled since we don't au3to-split on end
	//return (timer.CurrentPhase == TimerPhase.Running && current.mapScriptName != null && current.mapScriptName.Trim() == current.mapScriptName; 
	return false;
}

isLoading {
	if (vars.useBitMask && (current.loadingBitMask & 0x00000100) > 0)
	{
		print("[Bunker ASL] Currently Loading. Mask value: " + current.loadingBitMask);
		return true;
	}
	else if (current.loadingPercentage > 0.0f)
	{
		 return true;
	}
	return false;
}
