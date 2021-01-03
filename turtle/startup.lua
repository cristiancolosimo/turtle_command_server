os.loadAPI("json")
local ws,err = http.websocket("ws://localhost:5757")

local id = 0

local absoluteStartPosition = {}

local relativeStartPosition = {x=0,y=0,z=0}

turtle.refuel()

function setID(_id)
    id=_id
end
function getID()
    local send = {}
    send.type = "update"
    send.datatype = "id"
    send.data = id
    ws.send(json.encode(send))
end

function inspectAll()
    local ex = {}
    ex.top = {}
    ex.bottom = {}
    ex.front = {}
    
    local success,data = turtle.inspect()
    if success then
        ex.front.name = data.name
        ex.front.meta = data.metadata
    else
        ex.front.name= "air"
        ex.front.meta = 0
    end 


    local success,data = turtle.inspectDown()
    if success then
        ex.bottom.name = data.name
        ex.bottom.meta = data.metadata
    else
        ex.bottom.name= "air"
        ex.bottom.meta = 0
    end 


    local success,data = turtle.inspectUp()
    if success then
        ex.top.name = data.name
        ex.top.meta = data.metadata
    else
        ex.top.name= "air"
        ex.top.meta = 0
    end 
    local send = {}
    send.type = "update"
    send.datatype = "inspectBlock"
    send.data = ex
    
    
    ws.send(json.encode(send))
end

function getInventory()
    local inventory = {}
    
    for i=1,16,1
    do  
        local slot = {}
        slot.slot = i
        slot.data = turtle.getItemDetail(i)
        inventory[i] = slot
        
    end
    local send = {}
    send.type = "update"
    send.datatype = "inventory"
    send.data = inventory
    --print(json.encode(send))
    ws.send(json.encode(send))
end 

function place(where)
    if(where == 0) then
        turtle.place()
    end
    if(where == -1) then
        turtle.placeDown()
    end
    if(where == 1) then
        turtle.placeUp()
    end
end

function dig(where)
    if(where == -1) then --sotto
        turtle.digDown()
        turtle.suckDown()
    elseif (where == 0) then --avanti
        turtle.dig()
        turtle.suck()
    elseif (where == 1) then--sopra
        turtle.digUp()
        turtle.suckUp()
    elseif (where == 2) then -- sinistra
        turtle.turnLeft()
        turtle.dig()
        turtle.suck()
        turtle.turnRight()
    elseif (where == 3) then -- destra
        turtle.turnRight()
        turtle.dig()
        turtle.suck()
        turtle.turnLeft()
    elseif (where == 4) then
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.dig()
        turtle.suck()
        turtle.turnRight()
        turtle.turnRight()
    end
    local send = {}
    send.type = "update"
    send.datatype = "dig"
    send.data = {where = where}
    ws.send(json.encode(send))
end

function getName()
    local send = {}
    send.type = "update"
    send.datatype = "name"
    send.data = os.getComputerLabel()
    
    ws.send(json.encode(send))

end
env= {inspectAll = inspectAll ,dig=dig,turtle = turtle,getInventory=getInventory, os=os, getName = getName,id=id,setID=setID,getID=getID}

function executeEval(obj)
    if obj["type"] == "eval" then
        
        
        local func = load(obj["command"])
        setfenv(func,env)
        local result = func()
        print("eseguo")
        if(result == nil) then
            print("nil")    
        else
            print("eval: "..result)
        end
        
        
        --string attempt to call glocal a nil value
    end
end

if err then
    print(err)
end
if ws then
    print("CONNECTED TO SERVER")
    ws.send('{"type":"connect","usertype":"turtle"}')
    while true do
        
        local message = ws.receive()
        print(message)
        local obj  = json.decode(message)
        executeEval(obj)
    end
end


