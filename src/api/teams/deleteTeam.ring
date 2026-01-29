/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: deleteTeam
description: Delete a team
*/
func deleteTeam
    try {
        # try to get the team ID from the URL parameters
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("deleteTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("deleteTeam function", "Error getting URL match parameter", :error)
        }

        # check if the team ID is valid
        if cTeamID = NULL or len(cTeamID) = 0 {
            oServer.setContent('{"status":"error","message":"No team ID provided"}', "application/json")
            return
        }

        # search for the team by ID
        oCrew = NULL
        nIndex = 0

        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamID {
                oCrew = aTeams[i]
                nIndex = i
                exit
            }
        }

        if oCrew != NULL {
            # remove the team from the monitor
            try {
                oMonitor.unregisterCrew(oCrew)
                ? logger("deleteTeam function", "Team unregistered from monitor", :info)
            catch
                ? logger("deleteTeam function", "Error unregistering team: " + cCatchError, :error)
            }

            # delete the team
            del(aTeams, nIndex)
            ? logger("deleteTeam function", "Team deleted", :info)

            # save the changes to the database
            if saveTeams() {
                ? logger("deleteTeam function", "Team deleted and database updated", :info)
                oServer.setContent('{"status":"success","message":"Team deleted successfully"}',
                                  "application/json")
            else
                ? logger("deleteTeam function", "Team deleted but database not updated", :warning)
                oServer.setContent('{"status":"warning","message":"Team deleted but database not updated"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("deleteTeam function", "Error deleting team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
