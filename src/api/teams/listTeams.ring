/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: listTeams
description: Get list of teams
*/
func listTeams
    try {
        ? logger("listTeams function", "listTeams function called", :info)
        ? logger("listTeams function", "Number of teams: " + len(aTeams), :info)

        aTeamsList = []

        # collect team information from the global variable aTeams
        for i = 1 to len(aTeams) {
            oCrew = aTeams[i]

            # collect the basic information
            aTeamInfo = [
                :id = i,
                :name = oCrew.getName(),
                :objective = oCrew.getObjective()
            ]

            ? logger("listTeams function", "Team " + i + ": " + oCrew.getName(), :info)
            add(aTeamsList, aTeamInfo)
        }

        # create default teams if no teams are found
        if len(aTeamsList) = 0 and len(aAgents) > 0 {
            ? logger("listTeams function", "No teams found, creating default teams", :info)

            # create the development team
            oDevTeam = new Crew("Development Team", "Build software")

            # set the team leader (first customer)
            oDevTeam.setLeader(aAgents[1])

            # add team members
            for i = 2 to len(aAgents) {
                oDevTeam.addMember(aAgents[i])
            }

            # add the team to the general list
            add(aTeams, oDevTeam)

            # add the team to the response list
            add(aTeamsList, [
                :id = 1,
                :name = oDevTeam.getName(),
                :objective = oDevTeam.getObjective()
            ])

            # create the support team
            oSupportTeam = new Crew("Support Team", "Help users")

            # set the team leader (first customer)
            if len(aAgents) >= 1 {
                oSupportTeam.setLeader(aAgents[1])
            }

            # add the team to the general list
            add(aTeams, oSupportTeam)

            # add the team to the response list
            add(aTeamsList, [
                :id = 2,
                :name = oSupportTeam.getName(),
                :objective = oSupportTeam.getObjective()
            ])
        }

        # convert the list to JSON
        cJSON = '{"teams":' + list2json(aTeamsList) + '}'

        ? logger("listTeams function", "Teams list retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listTeams function", "Error retrieving teams list: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
