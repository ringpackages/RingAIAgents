/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: saveTeams
description: Save teams to the database
*/
func saveTeams
    try {
        # check if there are any teams
        if len(aTeams) = 0 {
            return false
        }

        # define the database path
        cDBPath = "G:\RingAIAgents\db\teams.db"

        # create the database if it doesn't exist
        if !fexists(cDBPath) {
            ? logger("saveTeams function", "Creating new database at: " + cDBPath, :info)
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # create the teams table if it doesn't exist
            cSQL = "CREATE TABLE IF NOT EXISTS teams (
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    objective TEXT,
                    leader_id TEXT,
                    members TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # close the database
            sqlite_close(oDatabase)
        }

        # open the database
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # save the teams - using REPLACE INTO instead of delete then add
        ? logger("saveTeams function", "Saving " + len(aTeams) + " teams to database", :info)
        for i = 1 to len(aTeams) {
            oCrew = aTeams[i]

            # collect the member IDs
            aMemberIds = []
            for oMember in oCrew.getMembers() {
                add(aMemberIds, oMember.getID())
            }

            # convert member IDs to JSON
            cMembers = list2json(aMemberIds)

            # clean the text from double quotes
            cName = substr(oCrew.getName(), '"', '""')
            cObjective = substr(oCrew.getObjective(), '"', '""')

            # log the data for debugging
            ? logger("saveTeams function", "Saving team: " + oCrew.getId(), :info)
            ? logger("saveTeams function", "Name: " + cName, :info)
            ? logger("saveTeams function", "Objective: " + cObjective, :info)

            # add the team to the database or update it if it exists
            cSQL = "REPLACE INTO teams (id, name, objective, leader_id, members) VALUES (
                    '" + oCrew.getId() + "',
                    '" + cName + "',
                    '" + cObjective + "',
                    '" + oCrew.getLeader().getID() + "',
                    '" + cMembers + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # close the database
        sqlite_close(oDatabase)

        ? logger("saveTeams function", "Teams saved successfully", :info)
        return true
    catch
        ? logger("saveTeams function", "Error saving teams: " + cCatchError, :error)
        return false
    }
