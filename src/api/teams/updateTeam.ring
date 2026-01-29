/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: updateTeam
description: Update team information
*/
func updateTeam
    try {
        # try to get the team ID from the URL
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("updateTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("updateTeam function", "Error getting URL match parameter", :error)
        }

        # check if the team ID is valid
        if cTeamID = NULL or len(cTeamID) = 0 {
            oServer.setContent('{"status":"error","message":"No team ID provided"}', "application/json")
            return
        }

        # search for the team by ID
        oCrew = NULL

        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamID {
                oCrew = aTeams[i]
                exit
            }
        }

        if oCrew != NULL {

            # update the basic information
            cName = oServer.variable("name")
            cObjective = oServer.variable("objective")

            ? logger("updateTeam function", "Updating team name to: " + cName, :info)
            ? logger("updateTeam function", "Updating team objective to: " + cObjective, :info)

            oCrew.setName(cName)
            oCrew.setObjective(cObjective)

            # update the leader
            cLeaderId = oServer.variable("leader_id")
            ? logger("updateTeam function", "Leader ID: " + cLeaderId, :info)

            # search for the leader by ID
            for i = 1 to len(aAgents) {
                if aAgents[i].getID() = cLeaderId {
                    oCrew.setLeader(aAgents[i])
                    ? logger("updateTeam function", "Leader set to: " + aAgents[i].getName(), :info)
                    exit
                }
            }

            # save the changes to the database
            if saveTeams() {
                ? logger("updateTeam function", "Team updated and saved successfully", :info)
                oServer.setContent('{"status":"success","message":"Team updated successfully"}',
                                  "application/json")
            else
                ? logger("updateTeam function", "Team updated but not saved to database", :warning)
                oServer.setContent('{"status":"warning","message":"Team updated but not saved to database"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("updateTeam function", "Error updating team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
