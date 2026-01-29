/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: getTeam
description: Get a specific team's information
*/
func getTeam
    try {
        # try to get the team ID from the URL parameters
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("getTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("getTeam function", "Error getting URL match parameter", :error)
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

            # collect the member IDs
            aMemberIds = []
            for oMember in oCrew.getMembers() {
                add(aMemberIds, oMember.getID())
            }

            ? logger("getTeam function", "Team retrieved successfully", :info)
            # prepare the JSON response
            aResponse = [
                :status = "success",
                :team = [
                    :id = oCrew.getId(),
                    :index = nIndex,
                    :name = oCrew.getName(),
                    :objective = oCrew.getObjective(),
                    :leader_id = oCrew.getLeader().getID(),
                    :member_ids = aMemberIds,
                    :performance = oCrew.getPerformanceScore()
                ]
            ]

            # convert the object to JSON
            cJSON = list2json(aResponse)

            # log the JSON response for debugging
            ? logger("getTeam function", "JSON response: " + cJSON, :info)

            # send the response
            oServer.setContent(cJSON, "application/json")
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("getTeam function", "Error retrieving team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
