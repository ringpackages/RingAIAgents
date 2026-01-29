load "guilib.ring"  # Load the GUI library
load "G:\RingAIAgents\src\gui\main_window.ring"

/*
Author:  Azzeddine Remmal
Date: 2025
Example: TechFlow Solutions
A comprehensive software company working in the field of application development and artificial intelligence solutions
*/

# Create the company and teams
func main {
    # Initialize the main window
    oApp = new QApp {
        oWindow = new MainWindow() 
        setupTechFlowCompany()
        oWindow.show()
    
        exec()
    }
}

func setupTechFlowCompany {
    # 1. Frontend Development Team
    oFrontendCrew = new Crew("Frontend Development Team") {
        setDescription("Responsible for creating responsive and user-friendly interfaces")
        setLeader(createAgent("Sarah Chen", "Senior Frontend Developer", [
            ["React", 90],
            ["Vue.js", 85],
            ["Angular", 80],
            ["UI/UX Design", 95],
            ["Performance Optimization", 90]
        ]))
        addMember(createAgent("Mike Johnson", "Frontend Developer", [
            ["HTML5", 80],
            ["CSS3", 85],
            ["JavaScript", 90],
            ["React", 85],
            ["Bootstrap", 80]
        ]))
        addMember(createAgent("Emma Davis", "UI/UX Designer", [
            ["Figma", 95],
            ["Adobe XD", 90],
            ["User Research", 85],
            ["Wireframing", 80],
            ["Prototyping", 85]
        ]))
    }

    # 2. Backend Development Team
    oBackendCrew = new Crew("Backend Development Team") {
        setDescription("Building robust and scalable server-side applications")
        setLeader(createAgent("David Kumar", "Senior Backend Developer", [
            ["Node.js", 90],
            ["Python", 85],
            ["Java", 80],
            ["MongoDB", 95],
            ["PostgreSQL", 90]
        ]))
        addMember(createAgent("Lisa Wang", "Backend Developer", [
            ["Python", 85],
            ["Django", 80],
            ["FastAPI", 85],
            ["SQL", 90],
            ["Redis", 80]
        ]))
        addMember(createAgent("James Wilson", "Database Administrator", [
            ["PostgreSQL", 95],
            ["MongoDB", 90],
            ["Redis", 85],
            ["Database Design", 90],
            ["Performance Tuning", 85]
        ]))
    }

    # 3. AI Development Team
    oAICrew = new Crew("AI Development Team") {
        setDescription("Developing cutting-edge AI solutions")
        setLeader(createAgent("Dr. Maria Rodriguez", "AI Research Lead", [
            ["Machine Learning", 95],
            ["Deep Learning", 90],
            ["Natural Language Processing", 85],
            ["Computer Vision", 90]
        ]))
        addMember(createAgent("Alex Zhang", "ML Engineer", [
            ["TensorFlow", 90],
            ["PyTorch", 85],
            ["Scikit-learn", 80],
            ["Data Analysis", 90],
            ["Model Optimization", 85]
        ]))
        addMember(createAgent("Sophie Martin", "Data Scientist", [
            ["Data Analysis", 90],
            ["Statistical Modeling", 85],
            ["Python", 95],
            ["R", 80],
            ["SQL", 85]
        ]))
    }

    # 4. Quality Assurance Team
    oQACrew = new Crew("Quality Assurance Team") {
        setDescription("Ensuring software quality and reliability")
        setLeader(createAgent("Robert Taylor", "QA Lead", [
            ["Test Planning", 90],
            ["Automation Testing", 85],
            ["Performance Testing", 80],
            ["Security Testing", 90]
        ]))
        addMember(createAgent("Nina Patel", "QA Engineer", [
            ["Selenium", 85],
            ["JUnit", 80],
            ["TestNG", 85],
            ["Manual Testing", 90],
            ["API Testing", 80]
        ]))
        addMember(createAgent("Carlos Garcia", "Security Tester", [
            ["Penetration Testing", 90],
            ["Security Analysis", 85],
            ["Vulnerability Assessment", 80]
        ]))
    }

    # 5. DevOps Team
    oDevOpsCrew = new Crew("DevOps Team") {
        setDescription("Managing infrastructure and deployment pipelines")
        setLeader(createAgent("Thomas Anderson", "DevOps Lead", [
            ["AWS", 90],
            ["Docker", 85],
            ["Kubernetes", 80],
            ["CI/CD", 95],
            ["Infrastructure as Code", 90]
        ]))
        addMember(createAgent("Laura Kim", "Cloud Engineer", [
            ["AWS", 85],
            ["Azure", 80],
            ["Google Cloud", 85],
            ["Terraform", 90],
            ["Ansible", 80]
        ]))
        addMember(createAgent("Ryan Murphy", "System Administrator", [
            ["Linux", 90],
            ["Shell Scripting", 85],
            ["Monitoring", 80],
            ["Security", 90],
            ["Networking", 85]
        ]))
    }

    # Add tasks
    
    # 1. E-commerce Platform Development
    addTask("E-commerce Platform Development", "High", [
        ["Frontend development of product catalog", "Medium", "Implement responsive design", ["React", "Vue.js"]],
        ["Backend API development", "High", "Implement RESTful API", ["Node.js", "Python"]],
        ["Payment gateway integration", "Medium", "Integrate with payment gateway", ["Stripe", "PayPal"]],
        ["Shopping cart implementation", "High", "Implement shopping cart functionality", ["React", "Redux"]]
    ], oFrontendCrew, "2025-03-15")

    addTask("E-commerce Backend Services", "High", [
        ["User authentication system", "High", "Implement user authentication", ["Node.js", "Passport.js"]],
        ["Product inventory management", "Medium", "Implement product inventory management", ["Python", "Django"]],
        ["Order processing system", "High", "Implement order processing system", ["Java", "Spring Boot"]],
        ["Analytics dashboard", "Medium", "Implement analytics dashboard", ["Tableau", "Power BI"]]
    ], oBackendCrew, "2025-03-20")

    # 2. Product Recommendation Engine
    addTask("Product Recommendation Engine", "Medium", [
        ["Data collection and preprocessing", "Medium", "Collect and preprocess data", ["Python", "Pandas"]],
        ["Model development and training", "High", "Develop and train recommendation model", ["TensorFlow", "Scikit-learn"]],
        ["API integration", "Medium", "Integrate with API", ["Flask", "Django"]],
        ["Performance optimization", "High", "Optimize performance", ["Python", "NumPy"]]
    ], oAICrew, "2025-04-01")

    # 3. E-commerce Platform Testing
    addTask("E-commerce Platform Testing", "High", [
        ["Functional testing", "Medium", "Test functionality", ["Selenium", "JUnit"]],
        ["Performance testing", "High", "Test performance", ["JMeter", "Gatling"]],
        ["Security assessment", "Medium", "Assess security", ["OWASP ZAP", "Burp Suite"]],
        ["User acceptance testing", "High", "Test user acceptance", ["Manual Testing", "API Testing"]]
    ], oQACrew, "2025-03-25")

    # 4. Platform Deployment
    addTask("Platform Deployment", "High", [
        ["Infrastructure setup", "Medium", "Set up infrastructure", ["AWS", "Terraform"]],
        ["CI/CD pipeline configuration", "High", "Configure CI/CD pipeline", ["Jenkins", "GitHub Actions"]],
        ["Monitoring setup", "Medium", "Set up monitoring", ["Prometheus", "Grafana"]],
        ["Backup and recovery planning", "High", "Plan backup and recovery", ["AWS", "Ansible"]]
    ], oDevOpsCrew, "2025-04-05")

    # Add crews to the main window
    addCrew(oFrontendCrew)
    addCrew(oBackendCrew)
    addCrew(oAICrew)
    addCrew(oQACrew)
    addCrew(oDevOpsCrew)
}

# Helper function to create an agent
func createAgent cName, cRole, aSkills {
    oAgent = new Agent(cName)
    oAgent {
        setRole(cRole)
        
        # Add skills with experience levels
        for cSkill in aSkills {
            if type(cSkill) = "STRING" {
                addSkill(cSkill, random()% 70-100)  # Random experience level
            else
                addSkill(cSkill[1], cSkill[2])  # Specific experience level
            }
        }
        
        #   Set appropriate personality traits for the role
        switch cRole {
            case "Senior Frontend Developer"
                setPersonality([
                    :openness = 85,  # Open to new technologies
                    :conscientiousness = 90,  # Organized and detail-oriented
                    :extraversion = 75,  # Able to communicate with the team
                    :agreeableness = 80,  # Cooperative
                    :neuroticism = 30   # Stable emotionally
                ])
                # Set work preferences
                setPreferences([
                    :workStyle = "collaborative",
                    :communicationStyle = "direct",
                    :problemSolving = "innovative",
                    :workHours = "flexible",
                    :learningStyle = "hands-on"
                ])
                # Set goals
                setGoals([
                    "Improve application performance",
                    "Implement responsive designs",
                    "Mentor junior developers",
                    "Research new technologies"
                ])
                
            case "AI Research Lead"
                setPersonality([
                    :openness = 95,  # Enjoys innovation
                    :conscientiousness = 85,  # Methodical
                    :extraversion = 70,  # Able to present ideas
                    :agreeableness = 75,  # Cooperative
                    :neuroticism = 35   # Stable under pressure
                ])
                setPreferences([
                    :workStyle = "research-oriented",
                    :communicationStyle = "detailed",
                    :problemSolving = "analytical",
                    :workHours = "project-based",
                    :learningStyle = "theoretical"
                ])
                setGoals([
                    "Publish research papers",
                    "Develop novel AI solutions",
                    "Lead R&D projects",
                    "Collaborate with academia"
                ])
                
            case "DevOps Lead"
                setPersonality([
                    :openness = 80,  # Open to change
                    :conscientiousness = 95,  # Very meticulous
                    :extraversion = 70,  # Able to communicate
                    :agreeableness = 85,  # Supportive of the team
                    :neuroticism = 25   # Stable under pressure
                ])
                setPreferences([
                    :workStyle = "systematic",
                    :communicationStyle = "clear",
                    :problemSolving = "pragmatic",
                    :workHours = "on-call",
                    :learningStyle = "practical"
                ])
                setGoals([
                    "Improve deployment efficiency",
                    "Enhance system reliability",
                    "Automate processes",
                    "Implement security best practices"
                ])
                
            default
                setPersonality([
                    :openness = random(60,100),
                    :conscientiousness = random(70,100),
                    :extraversion = random(50,100),
                    :agreeableness = random(60,100),
                    :neuroticism = random(20,60)
                ])
        }
        
        # Set energy level and emotional state
        setEnergyLevel(100)
        setEmotionalState("focused")
        
        # Set active status
        setActive(true)
    }
    return oAgent
}

# Helper function to add a task
func addTask cName, cPriority, aSubtasks, oCrew, cDueDate {
    oTask = new Task(cName, "Project: " + cName)
    oTask {
        setPriority(cPriority)
        setDueDate(cDueDate)
        assign(oCrew)
        
        # Add subtasks with details
        for cSubtask in aSubtasks {
            oSubTask = new Task(
                cSubtask[1],  # Subtask name
                "Subtask of: " + cName
            )
            oSubTask {
                setPriority(cSubtask[2])  # Subtask priority
                if len(cSubtask) > 2 {
                    setDescription(cSubtask[3])  # Detailed description
                }
                if len(cSubtask) > 3 {
                    setRequiredSkills(cSubtask[4])  # Required skills
                }
            }
            addSubTask(oSubTask)
        }
        
        # Set acceptance criteria
        setAcceptanceCriteria([
            "All subtasks completed",
            "Code review passed",
            "Tests passing",
            "Documentation updated",
            "Performance requirements met"
        ])
        
        # Set required resources
        setRequiredResources([
            :hardware = ["Development machine", "Testing devices"],
            :software = ["IDE", "Build tools", "Testing frameworks"],
            :access = ["Source code", "Databases", "APIs"]
        ])
        
        # Set possible risks
        setRisks([
            :technical = ["Integration issues", "Performance bottlenecks"],
            :schedule = ["Resource availability", "Dependency delays"],
            :quality = ["Bug escapes", "Technical debt"]
        ])
    }
    getParent().addTask(oTask)
}

# Define the tools and technologies used
class TechStack {
    # Frontend Tools
    aFrontendTools = [
        :frameworks = ["React 18.0", "Vue.js 3.0", "Angular 15"],
        :styling = ["TailwindCSS 3.0", "Material-UI 5.0", "Bootstrap 5"],
        :testing = ["Jest", "Cypress", "React Testing Library"],
        :build = ["Webpack 5", "Vite", "Babel"],
        :design = ["Figma", "Adobe XD", "Sketch"]
    ]
    
    # Backend Tools
    aBackendTools = [
        :languages = ["Node.js 18", "Python 3.11", "Java 17"],
        :frameworks = ["Express.js", "FastAPI", "Spring Boot"],
        :databases = ["PostgreSQL 15", "MongoDB 6.0", "Redis 7.0"],
        :orms = ["Prisma", "SQLAlchemy", "Hibernate"],
        :testing = ["Jest", "PyTest", "JUnit"]
    ]
    
    # AI Tools
    aAITools = [
        :frameworks = ["TensorFlow 2.12", "PyTorch 2.0", "Scikit-learn 1.2"],
        :nlp = ["Transformers", "spaCy", "NLTK"],
        :vision = ["OpenCV", "TorchVision", "TensorFlow Vision"],
        :data = ["Pandas", "NumPy", "Matplotlib"],
        :deployment = ["TensorFlow Serving", "TorchServe", "MLflow"]
    ]
    
    # DevOps Tools
    aDevOpsTools = [
        :cloud = ["AWS", "Azure", "Google Cloud"],
        :containers = ["Docker", "Kubernetes", "Helm"],
        :ci_cd = ["Jenkins", "GitHub Actions", "GitLab CI"],
        :monitoring = ["Prometheus", "Grafana", "ELK Stack"],
        :infrastructure = ["Terraform", "Ansible", "CloudFormation"]
    ]
    
    # QA Tools
    aQATools = [
        :automation = ["Selenium", "Playwright", "TestComplete"],
        :api_testing = ["Postman", "SoapUI", "JMeter"],
        :security = ["OWASP ZAP", "Burp Suite", "Acunetix"],
        :performance = ["Apache JMeter", "K6", "Gatling"],
        :management = ["TestRail", "Jira", "qTest"]
    ]
}
