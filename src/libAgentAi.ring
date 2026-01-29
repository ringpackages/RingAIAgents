/*
    RingAI Agents Library - Main Interface
    Combines all basic components in one place
*/

# Load basic libraries
load "sqlitelib.ring"
load "ringThreadPro.ring"
load "consolecolors.ring"
load "stdlib.ring"
load "jsonlib.ring"
load "ziplib.ring"
load "csvlib.ring"
load "subprocess.ring"
load "openssllib.ring"

# Load helper libraries
load "utils/ringToJson.ring"
Load "utils/helpers.ring"
Load "utils/http_client.ring"
Load "core/state.ring"

# Load core components in the correct order
Load "core/tools.ring"      # does not depend on any component
Load "core/memory.ring"     # does not depend on any component
Load "core/task.ring"       # does not depend on any component
Load "core/llm.ring"        # depends on helpers
Load "core/monitor.ring"    # does not depend on any component
Load "core/reinforcement.ring" # does not depend on any component
Load "core/flow.ring"       # depends on state
Load "core/agent.ring"      # depends on llm, task, memory, tools
Load "core/crew.ring"       # depends on agent
Load "core/integration.ring" # depends on memory, task, agent, crew

# Load building tools
Load "tools\development_tools.ring"
Load "tools\DefaultTools.ring"
//Load "tools\advancedtools.ring"

# Initialize the system
serverdebug = false # true
aDebag = [:error, :info]

if isMainSourceFile() {
   
    # Initialize the system
    oSystem = new AgentAI()

    # Create agents
    oFrontendDev = oSystem.createAgent("Frontend Developer", "Specializes in UI/UX development")
    oFrontendDev.setRole("Frontend Developer")
    oFrontendDev.addSkill("JavaScript", 90)
    oFrontendDev.addSkill("React", 85)
    oFrontendDev.addSkill("CSS", 80)

    oBackendDev = oSystem.createAgent("Backend Developer", "Specializes in server-side development")
    oBackendDev.setRole("Backend Developer")
    oBackendDev.addSkill("Python", 90)
    oBackendDev.addSkill("Node.js", 85)
    oBackendDev.addSkill("Databases", 80)

    # Create a team
    oDevTeam = oSystem.createTeam("oDevTeam", "Development Team", oBackendDev)
    oDevTeam.addMember(oFrontendDev)

    # Create tasks
    oLoginTask = oSystem.createTask("Implement user login functionality")
    oLoginTask.setPriority(8)

    oDashboardTask = oSystem.createTask("Create dashboard UI")
    oDashboardTask.setPriority(7)

    # Assign tasks
    oSystem.assignTask(oLoginTask, oBackendDev)
    oSystem.assignTask(oDashboardTask, oFrontendDev)

    # Display system status
    ? "System Status:"
    ? "=============="
    aStatus = oSystem.getSystemStatus()
    ? "Agents: " + aStatus[:agents]
    ? "Teams: " + aStatus[:teams]
    ? "Tasks: " + aStatus[:tasks]
    ? "Tools: " + aStatus[:tools]

    # Execute tasks
    ? nl + "Executing tasks..."
    oBackendDev.executeTask()
    oFrontendDev.executeTask()

    ? nl + "Done!"
}

class AgentAI

    # constants
    IDLE = :idle
    WORKING = :working
    LEARNING = :learning
    ERROR = :error
    
    # general variables
    bVerbose = true

    func init
        if bVerbose { ? "Setting up the smart customer system" }

        # Initialize components
        oMemory = new Memory("G:/RingAIAgents/db/AgentAI_memory.db")
        oMonitor = new PerformanceMonitor("G:/RingAIAgents/db/AgentAI_monitor.db")
        oRL = new ReinforcementLearning(:epsilon_greedy)

        # Initialize lists
        aAgents = []
        aTeams = []
        aTools = []
        aTasks = []

        return self

    # Create agent
    func createAgent cName, cDescription
        oAgent = new Agent(cName, cDescription)
        add(aAgents, oAgent)
        if bVerbose { ? "New agent created: " + cName }
        return oAgent

    func removeAgent cAgentId
        for i = 1 to len(aAgents) {
            if aAgents[i].getId() = cAgentId {
                del(aAgents, i)
                if bVerbose { ? "Agent removed: " + cAgentId }
                return true
            }
        }
        return false

    # Create team
    func createTeam  objectName, cName, oLeaderAgent
        oTeam = new Crew(objectName, cName, oLeaderAgent)
        add(aTeams, oTeam)
        if bVerbose { ? "New team created: " + cName }
        return oTeam

    func removeTeam cTeamId
        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamId {
                del(aTeams, i)
                if bVerbose { ? "Team removed: " + cTeamId }
                return true
            }
        }
        return false

    # Create task
    func createTask cDescription
        oTask = new Task(cDescription)
        add(aTasks, oTask)
        if bVerbose { ? "New task created: " + cDescription }
        return oTask

    func assignTask oTask, oAgent
        if oAgent.assignTask(oTask) {
            if bVerbose { ? "Task assigned to agent: " + oAgent.getName() }
            return true
        }
        return false

    # Register tool
    func registerTool oTool
        add(aTools, oTool)
        if bVerbose { ? "New tool registered: " + oTool.getName() }
        return true

    func unregisterTool cToolName
        for i = 1 to len(aTools) {
            if aTools[i].getName() = cToolName {
                del(aTools, i)
                if bVerbose { ? "Tool unregistered: " + cToolName }
                return true
            }
        }
        return false

    # Get performance metrics
    func getPerformanceMetrics
        return oMonitor.getMetrics()

    func getSystemStatus
        return [
            :agents = len(aAgents),
            :teams = len(aTeams),
            :tasks = len(aTasks),
            :tools = len(aTools)
        ]

    private
        # Components
        oMemory
        oMonitor
        oRL

        # Lists
        aAgents
        aTeams
        aTools
        aTasks
