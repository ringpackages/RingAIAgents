/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: addTeam
description: Create a new team
*/
func addTeam
    try {
        # get the team information
        cName = oServer.variable("name")
        cObjective = oServer.variable("objective")
        cLeaderId = oServer.variable("leader_id")

        ? logger("addTeam function", "Creating team: " + cName, :info)
        ? logger("addTeam function", "Objective: " + cObjective, :info)
        ? logger("addTeam function", "Leader ID: " + cLeaderId, :info)

        # set the leader and create the team
        for i = 1 to len(aAgents) {
            if aAgents[i].getID() = cLeaderId {
                # create the team
                oCrew = new Crew(cName, aAgents[i])

                ? logger("addTeam function", "Leader set to: " + aAgents[i].getName(), :info)
                exit
            }
        }

        # add the members
        cMemberIds = oServer.variable("member_ids")
        if len(cMemberIds) > 0 {
            try {
                aMemberIds = JSON2List(cMemberIds)
                if isList(aMemberIds) {
                    for cMemberId in aMemberIds {
                        for i = 1 to len(aAgents) {
                            if aAgents[i].getID() = cMemberId {
                                oCrew.addMember(aAgents[i])
                                ? logger("addTeam function", "Added member: " + aAgents[i].getName(), :info)
                                exit
                            }
                        }
                    }
                }
            catch
                ? logger("addTeam function", "Error parsing member IDs: " + cCatchError, :error)
            }
        }

        # register the team
        add(aTeams, oCrew)
        oMonitor.registerCrew(oCrew)
        # save the team to the database
        if saveTeams() {
            ? logger("addTeam function", "Team created and saved successfully", :info)
            oServer.setContent('{"status":"success","message":"Team created successfully","id":"' +
                              oCrew.getId() + '"}', "application/json")
        else
            ? logger("addTeam function", "Team created but not saved to database", :warning)
            oServer.setContent('{"status":"warning","message":"Team created but not saved to database","id":"' +
                              oCrew.getId() + '"}', "application/json")
        }
    catch
        ? logger("addTeam function", "Error creating team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
