/*
    RingAI Agents API - Dashboard Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
function: showDashboard
description: Display the dashboard
*/
import System.Web

func showDashboard
    oPage = new BootStrapWebPage  {
        Title = "RingAI Agents Dashboard"
        # load the common styles
        loadCommonStyles(oPage)
        # load the page specific styles
        html("<link rel='stylesheet' href='/static/css/dashboard.css'>")

        # add the header
        getHeader( oPage )

        div {
            classname = "main-content"
            div {
                classname = "container"

                div {
                    classname = "jumbotron p-4 mb-4"
                    style = "background-color: var(--primary-lighter); border-radius: var(--radius-lg); box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);"
                    div {
                        classname = "row align-items-center"
                        div {
                            classname = "col-md-9"
                            h1 {
                                text("RingAI Agents Dashboard")
                                style = "color: var(--text-primary); font-weight: 700; text-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);"
                            }
                            p {
                                text("Welcome to the RingAI Agents Management System - Your central hub for managing AI agents, teams, and tasks")
                                style = "color: var(--text-primary); font-weight: 500;"
                            }
                        }
                        div {
                            classname = "col-md-3 text-center"
                            Image {
                                src = "https://cdn-icons-png.flaticon.com/512/2103/2103652.png"
                                style = "max-height: 70px; filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.2));"
                                alt = "AI Dashboard Icon"
                            }
                        }
                    }
                }

                div {
                    classname = "row"

                    # add the system statistics section
                    div {
                        classname = "col-md-4"
                        div {
                            classname = "dashboard-card mb-4"
                            div {
                                classname = "card-header"
                                h4 { text("System Statistics") }
                            }
                            div {
                                classname = "card-body"
                                ul {
                                    classname = "list-group list-group-flush"
                                    li { classname = "list-group-item" text("Total Teams: " + len(aTeams)) }
                                    li { classname = "list-group-item" text("Total Agents: " + len(aAgents)) }
                                    li { classname = "list-group-item" text("Active Tasks: " + len(aTasks)) }
                                    li { classname = "list-group-item" text("Total Users: " + len(aUsers)) }
                                }
                            }
                        }
                    }

                    # add the system performance section
                    div {
                        classname = "col-md-4"
                        div {
                            classname = "dashboard-card mb-4"
                            div {
                                classname = "card-header"
                                h4 { text("System Performance") }
                            }
                            div {
                                classname = "card-body"
                                ul {
                                    classname = "list-group list-group-flush"
                                    li { classname = "list-group-item" text("CPU Usage: " + oMonitor.getMetric("cpu_usage") + "%") }
                                    li { classname = "list-group-item" text("Memory Usage: " + oMonitor.getMetric("memory_usage") + "MB") }
                                    li { classname = "list-group-item" text("Active Sessions: " + oMonitor.getMetric("active_sessions")) }
                                }
                            }
                        }
                    }

                    # add the recent events section
                    div {
                        classname = "col-md-4"
                        div {
                            classname = "dashboard-card mb-4"
                            div {
                                classname = "card-header"
                                h4 { text("Recent Events") }
                            }
                            div {
                                classname = "card-body"
                                ul {
                                    classname = "list-group list-group-flush"
                                    aEvents = oMonitor.getRecentEvents(5)
                                    for oEvent in aEvents {
                                        li { classname = "list-group-item" text(oEvent.timestamp + ": " + oEvent.description) }
                                    }
                                }
                            }
                        }
                    }
                }

                div {
                    classname = "row mt-4"
                    div {
                        classname = "col-md-12"
                        h2 {
                            classname = "text-center mb-4"
                            text("Quick Navigation")
                        }
                        div {
                            classname = "dashboard-links"

                            div {
                                classname = "dashboard-link dashboard-link-primary"
                                Link {
                                    Link = "/agents"
                                    classname = "btn"
                                    html("<i class='fas fa-robot'></i><span>Manage Agents</span>")
                                }
                            }

                            div {
                                classname = "dashboard-link dashboard-link-secondary"
                                Link {
                                    Link = "/teams"
                                    classname = "btn"
                                    html("<i class='fas fa-users'></i><span>Manage Teams</span>")
                                }
                            }

                            div {
                                classname = "dashboard-link dashboard-link-info"
                                Link {
                                    Link = "/tasks"
                                    classname = "btn"
                                    html("<i class='fas fa-tasks'></i><span>Manage Tasks</span>")
                                }
                            }

                            div {
                                classname = "dashboard-link dashboard-link-warning"
                                Link {
                                    Link = "/users"
                                    classname = "btn"
                                    html("<i class='fas fa-user-cog'></i><span>Manage Users</span>")
                                }
                            }

                            div {
                                classname = "dashboard-link dashboard-link-danger"
                                Link {
                                    Link = "/chat"
                                    classname = "btn"
                                    html("<i class='fas fa-comments'></i><span>AI Chat</span>")
                                }
                            }

                            div {
                                classname = "dashboard-link dashboard-link-indigo"
                                Link {
                                    Link = "/api-keys"
                                    classname = "btn"
                                    html("<i class='fas fa-key'></i><span>API Keys</span>")
                                }
                            }
                        }
                    }
                }
            }
        }

        # add the footer
        getFooter( oPage )

        noOutput()
    }

    oServer.setHTMLPage(oPage)
