/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: loadTeams
description: Load available teams
*/
func loadTeams
    try {
        # clear the current teams list
        aTeams = []

        # define the database path
        cDBPath = "G:/RingAIAgents/db/teams.db"

        # check if the database exists
        if fexists(cDBPath) {
            ? logger("loadTeams function", "Loading teams from database: " + cDBPath, :info)
            # open the database
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # retrieve the teams
            cSQL = "SELECT * FROM teams"
            aResults = sqlite_execute(oDatabase, cSQL)

            # log the query results
            ? logger("loadTeams function", "SQL query executed: " + cSQL, :info)
            ? logger("loadTeams function", "Number of teams found: " + iif(type(aResults) = "LIST", len(aResults), 0), :info)

            # process the results
            if type(aResults) = "LIST" and len(aResults) > 0 {
                # log the details of each team
                for nTeamIndex = 1 to len(aResults) {
                    aResult = aResults[nTeamIndex]
                    ? logger("loadTeams function", "Processing team " + nTeamIndex + " of " + len(aResults) + ": " + aResult[:name], :info)
                    # find the leader
                    oLeader = NULL
                    ? logger("loadTeams function", "Looking for leader with ID: " + aResult[:leader_id], :info)
                    for i = 1 to len(aAgents) {
                        if isObject(aAgents[i]) and methodExists(aAgents[i], :getId) {
                            if aAgents[i].getId() = aResult[:leader_id] {
                                oLeader = aAgents[i]
                                ? logger("loadTeams function", "Found leader: " + aAgents[i].getName(), :info)
                                exit
                            }
                        }
                    }

                    # use the first customer if no leader is found
                    if oLeader = NULL and len(aAgents) > 0 {
                        oLeader = aAgents[1]
                    }

                    # create a new team
                    if oLeader != NULL {
                        oCrew1 = new Crew("oCrew1 ", aResult[:name], oLeader)

                        # set the ID and objective
                        oCrew1.setId(aResult[:id])

                        # log the objective for debugging
                        ? logger("loadTeams function", "Loading objective for team " + aResult[:id] + ": " + aResult[:objective], :info)

                        # set the objective
                        oCrew1.setObjective(aResult[:objective])

                        # add the members
                        try {
                            cMembersStr = aResult[:members]
                            ? logger("loadTeams function", "Members string: " + cMembersStr, :info)

                            # clean the members string and convert it to a valid JSON format
                            cMembersStr = trim(cMembersStr)
                            if left(cMembersStr, 1) != "[" {
                                cMembersStr = "[" + cMembersStr + "]"
                            }

                            # try to parse the JSON
                            ? logger("loadTeams function", "Cleaned members JSON: " + cMembersStr, :info)
                            aMemberIds = JSON2List(cMembersStr)

                            if isList(aMemberIds) {
                                ? logger("loadTeams function", "Number of members: " + len(aMemberIds), :info)

                                for cMemberId in aMemberIds {
                                    # avoid adding the leader again
                                    if cMemberId = oLeader.getId() {
                                        ? logger("loadTeams function", "Skipping leader: " + cMemberId, :info)
                                        loop
                                    }

                                    # find the member and add it
                                    for i = 1 to len(aAgents) {
                                        if aAgents[i].getId() = cMemberId {
                                            ? logger("loadTeams function", "Adding member: " + aAgents[i].getName() + " with ID: " + cMemberId, :info)
                                            oCrew1.addMember(aAgents[i])
                                            exit
                                        }
                                    }
                                }
                            else
                                ? logger("loadTeams function", "Members list is not valid", :error)
                            }
                        catch
                            ? logger("loadTeams function", "Error parsing members: " + cCatchError, :error)
                        }

                        # add the team to the list
                        add(aTeams, oCrew1)

                        # register the team with the monitor
                        try {
                            oMonitor.registerCrew(oCrew1)
                        catch
                            ? logger("loadTeams function", "Error registering crew with monitor: " + cCatchError, :error)
                        }
                    }
                }
            }

            # close the database
            sqlite_close(oDatabase)
        }

        # create default teams if no teams are loaded
        if len(aTeams) = 0 and len(aAgents) > 0 {
            ? logger("loadTeams function", "No teams loaded, creating default teams", :info)

            # create the development team
            oDevTeam = new Crew("oDevTeam", "Development Team", aAgents[1])
            oDevTeam.setObjective("Build software")

            # add team members
            for i = 2 to min(len(aAgents), 4) {
                oDevTeam.addMember(aAgents[i])
            }

            # add the team to the general list
            add(aTeams, oDevTeam)

            # register the team with the monitor
            try {
                oMonitor.registerCrew(oDevTeam)
            catch
                ? logger("loadTeams function", "Error registering dev team with monitor: " + cCatchError, :error)
            }

            # create the support team if there are enough customers
            if len(aAgents) >= 5 {
                oSupportTeam = new Crew("oSupportTeam", "Support Team", aAgents[5])
                oSupportTeam.setObjective("Help users")

                # add team members
                for i = 6 to min(len(aAgents), 8) {
                    oSupportTeam.addMember(aAgents[i])
                }

                # add the team to the general list
                add(aTeams, oSupportTeam)

                # register the team with the monitor
                try {
                    oMonitor.registerCrew(oSupportTeam)
                catch
                    ? logger("loadTeams function", "Error registering support team with monitor: " + cCatchError, :error)
                }
            }

            # save the default teams
            saveTeams()
        }

        ? logger("loadTeams function", "Teams loaded successfully: " + len(aTeams), :info)
        return true
    catch
        ? logger("loadTeams function", "Error loading teams: " + cCatchError, :error)
        return false
    }