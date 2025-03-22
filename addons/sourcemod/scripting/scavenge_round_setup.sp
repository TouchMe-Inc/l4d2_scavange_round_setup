#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <left4dhooks>


public Plugin myinfo =
{
    name        = "ScavengeRoundSetup",
    author      = "TouchMe",
    description = "Plugin that helps you customize the number of rounds",
    version     = "build_0001",
    url         = "https://github.com/TouchMe-Inc/l4d2_scavange_round_setup"
}


ConVar
    g_cvScavengeRoundNumber = null,
    g_cvScavengeMatchEndRestart = null
;


public void OnPluginStart()
{
    g_cvScavengeRoundNumber = CreateConVar("sm_scavenge_round_number", "5", "Set the total number of rounds", FCVAR_NOTIFY, true, 1.0, true, 5.0);
    g_cvScavengeMatchEndRestart = CreateConVar("sm_scavenge_match_end_restart", "10", "Time until Scavenge restarts at the end of the game", FCVAR_NOTIFY, true, 0.0, true, 10.0);

    HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
    HookEvent("scavenge_match_finished", Event_ScavMatchFinished, EventHookMode_Post);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (IsNewScavangeGame()) {
        SetScavengeRoundLimit(g_cvScavengeRoundNumber.IntValue);
    }
}

public void Event_ScavMatchFinished(Event event, const char[] name, bool dontBroadcast)
{
    if (g_cvScavengeMatchEndRestart.BoolValue) {
        CreateTimer(g_cvScavengeMatchEndRestart.FloatValue, Timer_RestartMatch);
    }
}

Action Timer_RestartMatch(Handle Timer)
{
    L4D2_Rematch();
    return Plugin_Stop;
}

bool InSecondHalfOfRound() {
    return view_as<bool>(GameRules_GetProp("m_bInSecondHalfOfRound", 1));
}

/*
 * Returns the current round number of current scavenge match.
 *
 * @return       	        Round number.
 */
int GetScavengeRoundNumber() {
    return GameRules_GetProp("m_nRoundNumber");
}

 /*
 * Sets the round limit.
 *
 * @param iRound		     round limit to set. valid round number is 1, 3, 5.
 */
void SetScavengeRoundLimit(int iRound) {
    GameRules_SetProp("m_nRoundLimit", iRound);
}

bool IsNewScavangeGame() {
    return GetScavengeRoundNumber() == 1 && !InSecondHalfOfRound();
}
