/*
    RingAI Agents API
    Author: Azzeddine Remmal
    Date: 2025
*/

# load the basic libraries
load "../libAgentAi.ring"
load "httplib.ring"
load "weblib.ring"

# load the global variables
load "Global.ring"

# initialize the server
oServer = new Server

# load the models
load "models\User.ring"

# load the initialize function
load "initialize.ring"

# load the controllers
load "controllers\layout.ring"

# load the controllers
load "controllers\showDashboard.ring"
load "controllers\showAgents.ring"
load "controllers\showTeams.ring"
load "controllers\showTasks.ring"
load "controllers\showUsers.ring"
load "controllers\showChat.ring"
load "controllers\showChatHistory.ring"
load "controllers\showAPIKeys.ring"

# load the agents functions
load "agents\loadAgents.ring"
load "agents\saveAgents.ring"
load "agents\addAgent.ring"
load "agents\getAgent.ring"
load "agents\listAgents.ring"
load "agents\checkAgents.ring"
load "agents\updateAgent.ring"
load "agents\deleteAgent.ring"
load "agents\trainAgent.ring"
load "agents\getAgentSkills.ring"
load "agents\addAgentSkill.ring"

# load the teams functions
load "teams\loadTeams.ring"
load "teams\saveTeams.ring"
load "teams\addTeam.ring"
load "teams\getTeam.ring"
load "teams\listTeams.ring"
load "teams\updateTeam.ring"
load "teams\deleteTeam.ring"
load "teams\addTeamMember.ring"
load "teams\removeTeamMember.ring"
load "teams\getTeamPerformance.ring"

# load the tasks functions
load "tasks\loadTasks.ring"
load "tasks\saveTasks.ring"
load "tasks\addTask.ring"
load "tasks\getTask.ring"
load "tasks\listTasks.ring"
load "tasks\updateTask.ring"
load "tasks\deleteTask.ring"
load "tasks\addSubtask.ring"
load "tasks\updateTaskProgress.ring"
load "tasks\getTaskHistory.ring"

# load the users functions
load "users\addUser.ring"
load "users\getUser.ring"
load "users\updateUser.ring"
load "users\login.ring"
load "users\logout.ring"

# load the AI functions
load "ai\aiChat.ring"
load "ai\aiAnalyze.ring"
load "ai\aiLearn.ring"
load "ai\getAIModels.ring"
load "ai\getChatHistory.ring"
load "ai\apiKeys.ring"

# load the monitoring functions
load "monitor\getMetrics.ring"
load "monitor\getPerformance.ring"
load "monitor\getEvents.ring"
load "monitor\configureAlerts.ring"

# initialize the system and start the server
initialize()

# initialize the static folder
oServer.shareFolder("static")

? logger("RingAI Agents API Server", "RingAI Agents API Server running at http://localhost:8080", :info)

try {
    # start the server
    oServer.listen("0.0.0.0", 8080)

    # open the browser
    //system("start chrome --new-window http://localhost:8080")

    ? logger("RingAI Agents API Server", "Browser opened successfully!", :info)
catch
    ? logger("RingAI Agents API Server", "Error starting server: " + cCatchError, :error)
}
