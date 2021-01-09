os.loadAPI("json")
local ws,err = http.websocket("ws://localhost:5757")

function shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

local id = 0

local absoluteStartPosition = {}

relativeStartPosition = {x=0,y=0,z=0,DIRECTION="FRONT"}

relativePosition = relativeStartPosition
turtle.refuel()

function mineALayer(length)
    for i=0,length,1
    do
        mineUnaStriscia(5)
        if i%2 ==0 then
            turtle.turnLeft()
            turtle.dig()
            turtle.suck()
            turtle.forward()
            turtle.turnLeft()

        else 
            turtle.turnRight()
            turtle.dig()
            turtle.suck()
            turtle.forward()
            turtle.turnRight()
        end
    end
end

function mineUnaStriscia(length)
    for i=0,length,1
    do 
        turtle.dig()
        turtle.suck()
        turtle.forward()
    end
end    

function mineAllDays()
    for i =1,66,1
    do
        turtle.digDown()
        turtle.suckDown()
        turtle.down()
        
        mineALayer(5)
    end
end

function getRelativePosition()
    local send = {}
    send.type= "update"
    send.datatype = "location"
    send.data = relativePosition
    ws.send(json.encode(send))

end
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

function move(where)
    local change = false
    if(where == -1) then--sotto
        
        local r = turtle.down()
        if r then 
            relativePosition.y=relativePosition.y-1
            change = true
        end
    end
    if(where == 1) then --sopra
        local r = turtle.up()
        if r then 
            relativePosition.y=relativePosition.y+1
            change = true
        end
    end





    if(where == 0 and relativePosition.DIRECTION =="FRONT")then --avanti se la posizione relativa è FRONT
        local r = turtle.forward()
        if r then
            relativePosition.x=relativePosition.x+1
            change = true
        end
    end
    if(where == 4 and relativePosition.DIRECTION =="FRONT")then --avanti se la posizione relativa è FRONT
        local r = turtle.back()
        if r then
            relativePosition.x=relativePosition.x-1
            change = true
        end
    end


    if(where == 0 and relativePosition.DIRECTION =="BACK")then --avanti se la posizione relativa è FRONT
        local r = turtle.forward()
        if r then
            relativePosition.x=relativePosition.x-1
            change = true
        end
    end
    if(where == 4 and relativePosition.DIRECTION=="BACK")then --avanti se la posizione relativa è FRONT
        local r = turtle.back()
        if r then
            relativePosition.x=relativePosition.x+1
            change = true
        end
    end

    if(where == 0 and relativePosition.DIRECTION =="LEFT")then --avanti se la posizione relativa è FRONT
        local r = turtle.forward()
        if r then
            relativePosition.z=relativePosition.z+1
            change = true
        end
    end
    if(where == 4 and relativePosition.DIRECTION =="LEFT")then --avanti se la posizione relativa è FRONT
        local r = turtle.back()
        if r then
            relativePosition.z=relativePosition.z-1
            change = true
        end
    end
    



    if(where == 0 and relativePosition.DIRECTION =="RIGHT")then --avanti se la posizione relativa è FRONT
        local r = turtle.forward()
        if r then
            relativePosition.z=relativePosition.z-1
            change = true
        end
    end
    if(where == 4 and relativePosition.DIRECTION =="RIGHT")then --avanti se la posizione relativa è FRONT
        local r = turtle.back()
        if r then
            relativePosition.z=relativePosition.z+1
            change = true
        end
    end
    if change then
        local send = {}
        send.type= "update"
        send.datatype = "location"
        send.data = relativePosition
        ws.send(json.encode(send))

    end

    
end

function turn(where)
    if(where == 2 and relativePosition.DIRECTION == "FRONT") then 
         relativePosition.DIRECTION = "LEFT" 
    elseif (where == 2 and relativePosition.DIRECTION == "LEFT") then  
        relativePosition.DIRECTION = "BACK" 
    elseif (where == 2 and relativePosition.DIRECTION == "BACK") then 
         relativePosition.DIRECTION = "RIGHT" 
    elseif (where == 2 and relativePosition.DIRECTION == "RIGHT") then  
        relativePosition.DIRECTION = "FRONT" 
    end
    if(where == 2) then 
        turtle.turnLeft()
    end
    if(where == 3 and relativePosition.DIRECTION == "FRONT") then  
        relativePosition.DIRECTION = "RIGHT" 
    elseif (where == 3 and relativePosition.DIRECTION == "RIGHT")  then 
        relativePosition.DIRECTION = "BACK" 
    elseif (where == 3 and relativePosition.DIRECTION == "BACK") then 
         relativePosition.DIRECTION = "LEFT" 
    elseif (where == 3 and relativePosition.DIRECTION == "LEFT") then  
        relativePosition.DIRECTION = "FRONT" 
    end
    if(where == 3) then 
        turtle.turnRight()
    end
    local send = {}
    send.type= "update"
    send.datatype = "location"
    send.data = relativePosition
    ws.send(json.encode(send))

end

function inspectAll()
    local ex = {}
    ex.top = {}
    ex.top.position= shallow_copy(relativePosition)
    ex.top.position.y = relativePosition.y+1
    ex.bottom = {}
    ex.bottom.position= shallow_copy(relativePosition)
    ex.bottom.position.y = relativePosition.y-1
   
    ex.front = {}
    ex.front.position= shallow_copy(relativePosition)
    print(ex.bottom.position)
    print(ex.top.position)
    print(ex.front.position)
    if(relativePosition.DIRECTION == "LEFT")then
        ex.front.position.z=relativePosition.z+1
    end
    if(relativePosition.DIRECTION == "RIGHT")then
        ex.front.position.z=relativePosition.z-1
    end
    if(relativePosition.DIRECTION == "FRONT")then
        ex.front.position.x=relativePosition.x+1
    end
    if(relativePosition.DIRECTION == "BACK")then
        ex.front.position.x=relativePosition.x-1
    end
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
env= {mineAllDays=mineAllDays,mineALayer=mineALayer, mineUnaStriscia=mineUnaStriscia, shallow_copy=shallow_copy,getRelativePosition=getRelativePosition,turn=turn,move=move,inspectAll = inspectAll ,dig=dig,turtle = turtle,getInventory=getInventory, os=os, getName = getName,id=id,setID=setID,getID=getID}

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


