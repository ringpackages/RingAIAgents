Load "G:\RingAIAgents\src\libAgentAi.ring"

/*
Example: Workflow with agents and teams
Description: Example shows how to use workflows with agents and teams in RingAI Agents system
*/

odevteam = null


# Example usage
func main {
    ? "=== Starting workflow with agents and teams ==="
     
    # Creating system
    oSystem = new AgentAI()

    # Creating agents
    oFrontendDev = oSystem.createAgent("Frontend Developer", "Specialized in frontend development")
    oFrontendDev.setRole("Frontend Developer")
    oFrontendDev.addSkill("JavaScript", 90)
    oFrontendDev.addSkill("React", 85)
    oFrontendDev.addSkill("CSS", 80)

    oBackendDev = oSystem.createAgent("Backend Developer", "Specialized in backend development")
    oBackendDev.setRole("Backend Developer")
    oBackendDev.addSkill("Python", 90)
    oBackendDev.addSkill("Node.js", 85)
    oBackendDev.addSkill("Databases", 80)

    oDesigner = oSystem.createAgent("Designer", "Specialized in UI/UX design")
    oDesigner.setRole("Designer")
    oDesigner.addSkill("UI/UX", 95)
    oDesigner.addSkill("Photoshop", 85)
    oDesigner.addSkill("Figma", 90)

    oProjectManager = oSystem.createAgent("Project Manager", "Responsible for project management and coordination")
    oProjectManager.setRole("Project Manager")
    oProjectManager.addSkill("Project Management", 95)
    oProjectManager.addSkill("Communication", 90)
    oProjectManager.addSkill("Leadership", 85)

    # Creating development team
    oDevTeam = oSystem.createTeam("oDevTeam", "Development Team", oProjectManager)
    oDevTeam.addMember(oFrontendDev)
    oDevTeam.addMember(oBackendDev)
    oDevTeam.addMember(oDesigner)

    # Creating tasks
    oLoginTask = oSystem.createTask("Implement login functionality")
    oLoginTask.setPriority(8)

    oDashboardTask = oSystem.createTask("Create dashboard interface")
    oDashboardTask.setPriority(7)

    oDesignTask = oSystem.createTask("Design user interface")
    oDesignTask.setPriority(9)

    # Creating project workflow
    oProjectFlow = new ProjectWorkflow(oDevTeam)

    # Executing project workflow
    ? "--- Starting project workflow ---"
    oProjectFlow.execute()
    ? "Project status: " + oProjectFlow.oState.getText("project_status")

    # Creating task assignment workflow
    oTaskFlow = new TaskAssignmentFlow(oDevTeam, [oLoginTask, oDashboardTask, oDesignTask])

    # Executing task assignment workflow
    ? "--- Starting task assignment workflow ---"
    oTaskFlow.execute()
    ? "Task status: "
    see oTaskFlow.oState.getList("assignments")

    # Creating collaboration workflow
    oCollaborationFlow = new CollaborationFlow(oDevTeam)

    # Executing collaboration workflow
    ? "--- Starting collaboration workflow ---"
    oCollaborationFlow.execute()
    ? "Collaboration result: " + oCollaborationFlow.oState.getText("collaboration_result")

    # Creating evaluation workflow
    oEvaluationFlow = new EvaluationFlow(oDevTeam)

    # Executing evaluation workflow
    ? "--- Starting evaluation workflow ---"
    oEvaluationFlow.execute()
    ? "Evaluation results: "
    see oEvaluationFlow.oState.getList("evaluation_results")

    ? "=== Example finished ==="
}

/*
الكلاس: ProjectWorkflow
الوصف: تدفق عمل للمشروع
*/
class ProjectWorkflow from Flow {

    oTeam = null
   

    func init oTeam {
        super.init()
        self.oTeam = oTeam
        
        
        registerMethod("startproject")
        start("startproject")
    }

    func startproject {
        oState.setText("project_status", "Starting project")
        emit("project_started", null)

        # Defining project goals
        defineProjectGoals()
    }

    func defineProjectGoals {
        oState.setText("project_goals", "Create a login system and control panel interface.")
        oState.setText("project_status", "Goals defined")
        emit("goals_defined", null)

        # Planning project
        planProject()
    }

    func planProject {
        # Creating project plan
        aProjectPlan = [
            :phases = ["Design", "Development", "Testing", "Deployment"],
            :timeline = "4 weeks",
            :resources = ["Developers", "Designers", "Testers"]
        ]

        oState.setList("project_plan", aProjectPlan)
        oState.setText("project_status", "Project planned")
        emit("project_planned", aProjectPlan)

        # Informing the team about the plan
        oTeam.broadcast("Project plan completed. Please review the assigned tasks.")

        # Starting project execution
        startExecution()
    }

    func startExecution {
        oState.setText("project_status", "Project execution started")
        emit("execution_started", null)

        # Simulating project progress
        oState.setNumber("progress", 25)
        emit("progress_updated", 25)

        # Updating project status
        updateProjectStatus()
    }

    func updateProjectStatus {
        oState.setText("project_status", "Project execution in progress - 25% completed")
        emit("status_updated", oState.getText("project_status"))
    }
}

/*
الكلاس: TaskAssignmentFlow
الوصف: تدفق لتوزيع المهام على أعضاء الفريق
*/
class TaskAssignmentFlow from Flow {

    oTeam = null
    aTasks = []
   

    func init oTeam, aTasks {
        super.init()
        self.oTeam = oTeam
        self.aTasks = aTasks
       
        registerMethod("starttaskassignment")
        start("starttaskassignment")
    }

    func starttaskassignment {
        oState.setText("assignment_status", "Starting task assignment")
        emit("assignment_started", null)

        # Assigning tasks based on skills
        assignTasksBySkill()
    }

    func assignTasksBySkill {
        aAssignments = []
        aMembers = oTeam.getMembers()

        # Simulating task assignment based on skills
        for i = 1 to len(aTasks) {
            oTask = aTasks[i]
            oAgent = findBestAgentForTask(oTask, aMembers)

            if oAgent != null {
                add(aAssignments, [
                    :task = oTask.getDescription(),
                    :agent = oAgent.getName(),
                    :priority = oTask.getPriority()
                ])

                # Assigning the task to the agent
                oTeam.assignTask(oTask, oAgent)
            }
        }

        oState.setList("assignments", aAssignments)
        oState.setText("assignment_status", "Tasks assigned")
        emit("tasks_assigned", aAssignments)

        # Informing the team about the tasks
        notifyTeamMembers()
    }

    func notifyTeamMembers {
        oTeam.broadcast("Tasks assigned to team members. Please review the assigned tasks.")
        emit("team_notified", null)
    }

    # Helper function to find the best agent for a task
    func findBestAgentForTask oTask, aAgents {
        nHighestScore = 0
        oBestAgent = null

        for oAgent in aAgents {
            nScore = calculateAgentTaskScore(oAgent, oTask)
            if nScore > nHighestScore {
                nHighestScore = nScore
                oBestAgent = oAgent
            }
        }

        return oBestAgent
    }

    # Helper function to calculate agent task score
    func calculateAgentTaskScore oAgent, oTask {
        nScore = 0
        cTaskDesc = lower(oTask.getDescription())

        # Checking agent skills
        for aSkill in oAgent.getSkills() {
            cSkillName = lower(aSkill[:name])
            if substr(cTaskDesc, cSkillName) {
                nScore += aSkill[:proficiency]
            }
        }

        # Considering agent role
        if oAgent.getRole() = "Project Manager" and substr(cTaskDesc, "Management") {
            nScore += 50
        }

        if oAgent.getRole() = "User Interface Developer" and (substr(cTaskDesc, "Interface") or substr(cTaskDesc, "Design")) {
            nScore += 30
        }

        if oAgent.getRole() = "Backend Developer" and substr(cTaskDesc, "login") {
            nScore += 40
        }

        if oAgent.getRole() = "Designer" and substr(cTaskDesc, "design") {
            nScore += 50
        }

        return nScore
    }
}

/*
class CollaborationFlow from Flow {

    oTeam = null
   

    func init oTeam {
        super.init()
        self.oTeam = oTeam
        
        registerMethod("startcollaboration")
        start("startcollaboration")
    }

    func startcollaboration {
        oState.setText("collaboration_status", "Starting collaboration")
        emit("collaboration_started", "Collaboration session started between team members." + oTeam.getName() )

        # Creating collaboration session
        createCollaborationSession()
    }

    func createCollaborationSession {
        # Simulating collaboration session
        aSession = [
            :topic = "User interface integration with backend",
            :participants = [],
            :date = TimeList()[5],
            :duration = "60 minutes"
        ]

        # Adding participants
        aMembers = oTeam.getMembers()
        for oMember in aMembers {
            add(aSession[:participants], oMember.getName())
        }

        oState.setList("collaboration_session", aSession)
        emit("session_created", aSession)

        # Simulating collaboration results
        simulateCollaboration()
    }

    func simulateCollaboration {
        # Simulating information exchange between team members
        aMembers = oTeam.getMembers()

        # Ensure there are enough team members
        if len(aMembers) >= 4 {
            oFrontendDev = null
            oBackendDev = null

            # Search for team members based on roles
            for oMember in aMembers {
                if oMember.getRole() = "Frontend Developer" {
                    oFrontendDev = oMember
                }
                if oMember.getRole() = "Backend Developer" {
                    oBackendDev = oMember
                }
            }

            # Exchange information if we have the members
            if oFrontendDev != null and oBackendDev != null {
                # Exchange information
                oFrontendDev.learn("API Integration", "Learned how to integrate with backend APIs")
                oBackendDev.learn("UI Requirements", "Understood the UI requirements for the login system")

                # Logging observations
                oFrontendDev.observe("Backend team is using JWT for authentication")
                oBackendDev.observe("Frontend team needs detailed API documentation")
            }
        }

        # Update collaboration status
        oState.setText("collaboration_result", "Information exchange completed between frontend and backend teams")
        oState.setText("collaboration_status", "Completed")
        emit("collaboration_completed", oState.getText("collaboration_result"))
    }
}

/*
class EvaluationFlow from Flow {

    oTeam = null

    func init oTeam {
        super.init()
        self.oTeam = oTeam
       
        registerMethod("startevaluation")
        start("startevaluation")
    }

    func startevaluation {
        oState.setText("evaluation_status", "Starting evaluation")
        emit("evaluation_started", null)

        # Collecting performance data
        collectPerformanceData()
    }

    func collectPerformanceData {
        aMembers = oTeam.getMembers()
        aPerformanceData = []

        # Simulating performance data collection
        for oMember in aMembers {
            aPerformance = [
                :name = oMember.getName(),
                :role = oMember.getRole(),
                :skills = oMember.getSkills(),
                :performance_score = oMember.getPerformanceScore(),
                :energy_level = oMember.getEnergyLevel(),
                :confidence_level = oMember.getConfidenceLevel()
            ]

            add(aPerformanceData, aPerformance)
        }

        oState.setList("performance_data", aPerformanceData)
        emit("data_collected", aPerformanceData)

        # Analyzing data
        analyzePerformanceData()
    }

    func analyzePerformanceData {
        aPerformanceData = oState.getList("performance_data")
        aEvaluationResults = []

        # Simulating data analysis
        for aData in aPerformanceData {
            # Calculating overall score
            nOverallScore = (aData[:performance_score] * 0.5) +
                           (aData[:energy_level] / 20) +
                           (aData[:confidence_level] / 2)

            # Determining performance level
            cPerformanceLevel = ""
            if nOverallScore >= 8
                cPerformanceLevel = "Excellent"
            elseif nOverallScore >= 6
                cPerformanceLevel = "Very Good"
            elseif nOverallScore >= 4
                cPerformanceLevel = "Good"
            else
                cPerformanceLevel = "Needs Improvement"
            ok

            # Creating evaluation result
            aEvaluation = [
                :name = aData[:name],
                :role = aData[:role],
                :overall_score = nOverallScore,
                :performance_level = cPerformanceLevel,
                :strengths = [],
                :areas_for_improvement = []
            ]

            # Determining strengths and areas for improvement
            for aSkill in aData[:skills] {
                if aSkill[:proficiency] >= 85 {
                    add(aEvaluation[:strengths], aSkill[:name])
                elseif aSkill[:proficiency] < 70
                    add(aEvaluation[:areas_for_improvement], aSkill[:name])
                }
            }

            add(aEvaluationResults, aEvaluation)
        }

        oState.setList("evaluation_results", aEvaluationResults)
        oState.setText("evaluation_status", "Completed")
        emit("evaluation_completed", aEvaluationResults)

        # Providing recommendations
        provideRecommendations()
    }

    func provideRecommendations {
        aEvaluationResults = oState.getList("evaluation_results")
        aRecommendations = []

        # Simulating recommendations
        for aResult in aEvaluationResults {
            aRecommendation = [
                :name = aResult[:name],
                :recommendations = []
            ]

            # Adding recommendations based on areas for improvement
            for cArea in aResult[:areas_for_improvement] {
                add(aRecommendation[:recommendations], "Improve skills in " + cArea)
            }

            # Adding general recommendations
            if aResult[:overall_score] < 6 {
                add(aRecommendation[:recommendations], "Attend training courses in the field of expertise")
            }

            if aResult[:energy_level] < 70 {
                add(aRecommendation[:recommendations], "Improve energy level by distributing tasks more evenly")
            }

            add(aRecommendations, aRecommendation)
        }

        oState.setList("recommendations", aRecommendations)
        emit("recommendations_provided", aRecommendations)
    }
}
