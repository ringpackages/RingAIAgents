/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: addTeamMember
description: Add a new team member
*/
func addTeamMember
    try {
        nTeamId = number(oServer.aParameters[1])
        if nTeamId > 0 and nTeamId <= len(aTeams) {
            oCrew = aTeams[nTeamId]

            nAgentId = number(oServer["agent_id"])
            if nAgentId > 0 and nAgentId <= len(aAgents) {
                # add the member
                oCrew.addMember(aAgents[nAgentId])

                # store the addition in the memory
                oMemory.store(
                    "Team Member Added: " + aAgents[nAgentId].getName() + " to " + oCrew.getName(),
                    Memory.LONG_TERM,
                    6,
                    ["team", "member"],
                    [:team = oCrew.getName(), :member = aAgents[nAgentId].getName()]
                )

                ? logger("addTeamMember function", "Member added successfully", :info)
                oServer.setContent('{"status":"success","message":"Member added successfully"}',
                                  "application/json")
            else
                oServer.setContent('{"status":"error","message":"Agent not found"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("addTeamMember function", "Error adding team member: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
