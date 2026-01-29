/*
    RingAI Agents - GUI Library
    Combines all basic components in one place
*/


load "sqlitelib.ring"
load "ringThreadPro.ring"
Load "jsonlib.ring"
load "consolecolors.ring"
load "../utils/ringToJson.ring"
# load helper libraries
Load "../utils/helpers.ring"
Load "../utils/http_client.ring"
Load "../core/state.ring"

# load core components in the correct order
Load "../core/tools.ring"      # does not depend on any other component
Load "../core/memory.ring"     # does not depend on any other component
Load "../core/task.ring"       # does not depend on any other component
Load "../core/llm.ring"        # depends on helpers
Load "../core/monitor.ring"    # does not depend on any other component
Load "../core/reinforcement.ring" # does not depend on any other component
Load "../core/flow.ring"       # depends on state
Load "../core/agent.ring"      # depends on llm, task, memory, tools
Load "../core/crew.ring"       # depends on agent

# Initialize the system
serverdebug = false # true
aDebag = [:error, :info]