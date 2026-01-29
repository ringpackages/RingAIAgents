/*
    RingAI Agents API - API Keys Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
Function: showAPIKeys
Description: Display API keys management page
*/
import System.Web

func showAPIKeys
    oPage = new BootStrapWebPage {
        Title = "RingAI API Keys Management"
        # Load common styles
        loadCommonStyles(oPage)
        # Load page-specific styles
        html("<link rel='stylesheet' href='/static/css/api-keys.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/api-keys.js'></script>")

        # Add header
        getHeader(oPage)

        div {
            classname = "main-content"
            div {
                classname = "container"

                div {
                    classname = "row mb-4"
                    div {
                        classname = "col-md-12"
                        h1 { text("API Keys Management") }
                        p { text("Manage your API keys for language models and other services") }
                    }
                }

                # API keys section
                div {
                    classname = "row"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-primary text-white d-flex justify-content-between align-items-center"
                                h5 { text("Language Model API Keys") }
                                button {
                                    id = "add-key-btn"
                                    classname = "btn btn-sm btn-light"
                                    onclick = "$('#add-key-modal').modal('show');"
                                    html("<i class='fas fa-plus'></i> Add New Key")
                                }
                            }
                            div {
                                classname = "card-body"
                                div {
                                    classname = "table-responsive"
                                    table {
                                        classname = "table table-striped"
                                        thead {
                                            tr {
                                                th { text("Provider") }
                                                th { text("Model") }
                                                th { text("Key") }
                                                th { text("Status") }
                                                th { text("Actions") }
                                            }
                                        }
                                        tbody {
                                            id = "api-keys-table"
                                            tr {
                                                id = "loading-row"
                                                td {
                                                    colspan = "5"
                                                    classname = "text-center"
                                                    text("Loading API keys...")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                # API keys information section
                div {
                    classname = "row mt-4"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-secondary text-white"
                                h5 { text("API Keys Information") }
                            }
                            div {
                                classname = "card-body"
                                div {
                                    classname = "row"
                                    div {
                                        classname = "col-md-6"
                                        h6 { text("Supported Providers") }
                                        ul {
                                            li { text("Google (Gemini)") }
                                            li { text("OpenAI (GPT)") }
                                            li { text("Anthropic (Claude)") }
                                            li { text("Mistral AI") }
                                            li { text("Cohere") }
                                        }
                                    }
                                    div {
                                        classname = "col-md-6"
                                        h6 { text("How to Get API Keys") }
                                        ul {
                                            li {
                                                html("Google Gemini: <a href='https://ai.google.dev/' target='_blank'>Google AI Studio</a>")
                                            }
                                            li {
                                                html("OpenAI: <a href='https://platform.openai.com/' target='_blank'>OpenAI Platform</a>")
                                            }
                                            li {
                                                html("Anthropic: <a href='https://console.anthropic.com/' target='_blank'>Anthropic Console</a>")
                                            }
                                            li {
                                                html("Mistral AI: <a href='https://console.mistral.ai/' target='_blank'>Mistral AI Console</a>")
                                            }
                                            li {
                                                html("Cohere: <a href='https://dashboard.cohere.com/' target='_blank'>Cohere Dashboard</a>")
                                            }
                                        }
                                    }
                                }
                                div {
                                    classname = "alert alert-info mt-3"
                                    html("<i class='fas fa-info-circle'></i> <strong>Note:</strong> API keys are stored securely and encrypted in the database. They are only used to authenticate with the respective services.")
                                }
                            }
                        }
                    }
                }
            }
        }

        # Modal to add new API key
        div {
            id = "add-key-modal"
            classname = "modal fade"
            tabindex = "-1"
            role = "dialog"
            aria_labelledby = "add-key-modal-label"
            aria_hidden = "true"
            div {
                classname = "modal-dialog"
                role = "document"
                div {
                    classname = "modal-content"
                    div {
                        classname = "modal-header"
                        h5 {
                            id = "add-key-modal-label"
                            classname = "modal-title"
                            text("Add New API Key")
                        }
                        button {
                            type = "button"
                            classname = "close"
                            data = [
                                :dismiss = "modal"
                            ]
                            aria_label = "Close"
                            span {
                                aria_hidden = "true"
                                html("&times;")
                            }
                        }
                    }
                    div {
                        classname = "modal-body"
                        form {
                            id = "add-key-form"
                            div {
                                classname = "form-group"
                                div {
                                    text("Provider:")
                                }
                                select {
                                    id = "provider"
                                    classname = "form-control"
                                    required = "required"
                                    option { value = "" text("Select Provider") }
                                    option { value = "google" text("Google (Gemini)") }
                                    option { value = "openai" text("OpenAI (GPT)") }
                                    option { value = "anthropic" text("Anthropic (Claude)") }
                                    option { value = "mistral" text("Mistral AI") }
                                    option { value = "cohere" text("Cohere") }
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Model:")
                                }
                                select {
                                    id = "model"
                                    classname = "form-control"
                                    required = "required"
                                    option { value = "" text("Select Model") }
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("API Key:")
                                }
                                input {
                                    type = "password"
                                    id = "api-key"
                                    classname = "form-control"
                                    placeholder = "Enter your API key"
                                    required = "required"
                                }
                                text("Your API key will be stored securely.")
                            }
                        }
                    }
                    div {
                        classname = "modal-footer"
                        button {
                            type = "button"
                            classname = "btn btn-secondary"
                            data = [
                                :dismiss = "modal"
                            ]
                            text("Cancel")
                        }
                        button {
                            type = "button"
                            id = "save-key-btn"
                            classname = "btn btn-primary"
                            text("Save Key")
                        }
                    }
                }
            }
        }

        # Modal to edit API key
        div {
            id = "edit-key-modal"
            classname = "modal fade"
            tabindex = "-1"
            role = "dialog"
            aria_labelledby = "edit-key-modal-label"
            aria_hidden = "true"
            div {
                classname = "modal-dialog"
                role = "document"
                div {
                    classname = "modal-content"
                    div {
                        classname = "modal-header"
                        h5 {
                            id = "edit-key-modal-label"
                            classname = "modal-title"
                            text("Edit API Key")
                        }
                        button {
                            type = "button"
                            classname = "close"
                            data = [
                                :dismiss = "modal"
                            ]
                            aria_label = "Close"
                            span {
                                aria_hidden = "true"
                                html("&times;")
                            }
                        }
                    }
                    div {
                        classname = "modal-body"
                        form {
                            id = "edit-key-form"
                            input {
                                type = "hidden"
                                id = "edit-key-id"
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Provider:")
                                }
                                input {
                                    type = "text"
                                    id = "edit-provider"
                                    classname = "form-control"
                                    readonly = "readonly"
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Model:")
                                }
                                input {
                                    type = "text"
                                    id = "edit-model"
                                    classname = "form-control"
                                    readonly = "readonly"
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("API Key:")
                                }
                                input {
                                    type = "password"
                                    id = "edit-api-key"
                                    classname = "form-control"
                                    placeholder = "Enter new API key"
                                    required = "required"
                                }
                                text("Leave blank to keep the current key.")
                            }
                        }
                    }
                    div {
                        classname = "modal-footer"
                        button {
                            type = "button"
                            classname = "btn btn-secondary"
                            data = [
                                :dismiss = "modal"
                            ]
                            text("Cancel")
                        }
                        button {
                            type = "submit"
                            id = "update-key-btn"
                            classname = "btn btn-primary"
                            text("Update Key")
                        }
                    }
                }
            }
        }

        # Add footer
        getFooter(oPage)

        # Add script to load API keys
        html("<script>
            // Execute code after page load
            $(document).ready(function() {
                console.log('Document ready');

                // Load API keys
                loadAPIKeys();

                // Set up event handlers
                $('#provider').change(function() {
                    updateModelOptions();
                });

                // Set up event handler for add key button
                $('#add-key-btn').on('click', function(e) {
                    console.log('Add key button clicked via jQuery');
                    e.preventDefault();
                    $('#add-key-modal').modal('show');
                    return false;
                });

                // Alternative way to open the popup
                document.getElementById('add-key-btn').addEventListener('click', function(e) {
                    console.log('Add key button clicked via addEventListener');
                    $('#add-key-modal').modal('show');
                });

                // Set up event handler for save button directly
                document.getElementById('save-key-btn').onclick = function() {
                    console.log('Save button clicked directly');
                    alert('Save button clicked');
                    saveAPIKey();
                    return false;
                };

                // Set up event handler for form submission directly
                document.getElementById('add-key-form').onsubmit = function(e) {
                    e.preventDefault();
                    console.log('Form submitted directly');
                    saveAPIKey();
                    return false;
                };

                // Set up event handler for update button directly
                document.getElementById('update-key-btn').onclick = function() {
                    console.log('Update button clicked directly');
                    updateAPIKey();
                    return false;
                };

                // Set up event handler for edit form submission directly
                document.getElementById('edit-key-form').onsubmit = function(e) {
                    e.preventDefault();
                    console.log('Edit form submitted directly');
                    updateAPIKey();
                    return false;
                };

                // Try to open the modal after page load with a short delay
                setTimeout(function() {
                    console.log('Trying to show modal after timeout');
                    try {
                        $('#add-key-modal').modal({
                            keyboard: false,
                            backdrop: 'static',
                            show: false
                        });
                    } catch (e) {
                        console.error('Error initializing modal:', e);
                    }
                }, 1000);
            });

            // Helper function to open the modal
            function openAddKeyModal() {
                console.log('openAddKeyModal function called');
                $('#add-key-modal').modal('show');
            }
        </script>")

        # Add an additional button to open the modal
        html("<div class='container mt-3'>
            <button onclick='openAddKeyModal()' class='btn btn-primary'>
                <i class='fas fa-plus'></i> Open Add Key Modal (Alternative)
            </button>
        </div>")

        noOutput()
    }

    oServer.setHTMLPage(oPage)
