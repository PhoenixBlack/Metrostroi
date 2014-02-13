System function overview

gmod_subway_base:LoadSystem("name")
Loads the given system on the train (shared)

Metrostroi.DefineSystem("name")
???

TRAIN_SYSTEM:Initialize()
Serverside-only init

TRAIN_SYSTEM:ClientInitialize()
Clientside-only init

TRAIN_SYSTEM:Think(deltaTime)
Serverside-only think

TRAIN_SYSTEM:ClientThink(deltaTime)
Clientside-only think

TRAIN_SYSTEM:ClientDraw(deltaTime)
Clientside only entity draw 

TRAIN_SYSTEM:Inputs() 
Wiremod inputs, return table containing strings with desired names or {name,type} for special types

TRAIN_SYSTEM:Outputs()
Wiremod outputs, see above

TRAIN_SYSTEM:TriggerInput(name,value)
Wiremod triggerinput, also used for communication between systems

TRAIN_SYSTEM:TriggerOutput(name,value)
Wiremod triggeroutput, see above

See lua/autorun/metrostroi.lua for actual list

How to add a new system:

1: Call Metrostroi.DefineSystem("example") in your system file
2: Place the file in Metrostroi\lua\metrostroi\systems and name it "sys_example.lua"
3: Open Metrostroi\lua\autorun\metrostroi.lua and append LoadSystem("example")
4: Open the entity's shared.lua and call self:LoadSystem("example")

