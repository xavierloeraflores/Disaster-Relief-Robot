function sysCall_init()
    setObjectives()
    sensorDetector=sim.getObject("./sensorDetector")     
    robotBase=sim.getObject('.') 
    leftMotor=sim.getObject("./leftMotor") 
    rightMotor=sim.getObject("./rightMotor") 
    proxSensor=sim.getObject("./proxSensor") 
    minSpeed=50*math.pi/180
    maxSpeed= 300*math.pi/180
    startingSpeed = maxSpeed
    reverseSpeed = -200*math.pi/180
    reverseTime=-1
    robotCollection=sim.createCollection(0)
    sim.addItemToCollection(robotCollection,sim.handle_tree,robotBase,0)
    UI()
    
end

function UI()
    distanceSegment=sim.addDrawingObject(sim.drawing_lines,4,0,-1,1,{0,1,0})
    robotTrace=sim.addDrawingObject(sim.drawing_linestrip+sim.drawing_cyclic,2,0,-1,200,{1,1,0},nil,nil,{1,1,0})
    graph=sim.getObject('./graph')
    distStream=sim.addGraphStream(graph,'robot clearance','m',0,{1,0,0})
    xml = '<ui title="Robot speed"><hslider minimum="0" maximum="100" on-change="changeSpeed" id="1"/></ui>'
    ui=simUI.create(xml)
    speed=startingSpeed
    simUI.setSliderValue(ui,1,100*(speed-minSpeed)/(maxSpeed-minSpeed))
    function changeSpeed(ui,id,newVal)
    speed=minSpeed+(maxSpeed-minSpeed)*newVal/100
    end
end



function setObjectives()
    objective0 = sim.getObject("../Objective[0]")
    objective1 = sim.getObject("../Objective[1]")
    objective2 = sim.getObject("../Objective[2]")
    sim.setObjectColor(objective0,0,sim.colorcomponent_ambient_diffuse,{0,1,1})
    sim.setObjectColor(objective1,0,sim.colorcomponent_ambient_diffuse,{0,1,1})
    sim.setObjectColor(objective2,0,sim.colorcomponent_ambient_diffuse,{0,1,1})
end


function sysCall_sensing()
    local result,distData=sim.checkDistance(robotCollection,sim.handle_all)
    if result>0 then
        sim.addDrawingObjectItem(distanceSegment,nil)
        sim.addDrawingObjectItem(distanceSegment,distData)
        sim.setGraphStreamValue(graph,distStream,distData[7])
    end
    local p=sim.getObjectPosition(robotBase,sim.handle_world)
    sim.addDrawingObjectItem(robotTrace,p)
end 

function detectObjective()
    local result_To_Detect,distance,detectedPoint,detectedObjectHandle=sim.readProximitySensor(sensorDetector)
    if (result_To_Detect>0) then    
        if detectedObjectHandle then
            if sim.getObjectAlias(detectedObjectHandle) == 'Objective' then
                print("Objective Found: " .. tostring(sim.getObjectAlias(detectedObjectHandle)) )
                sim.setObjectColor(detectedObjectHandle,0,sim.colorcomponent_ambient_diffuse,{0,1,0})
                sim.setObjectColor(sensorDetector,0,sim.colorcomponent_ambient_diffuse,{0,1,0})
            end
        end
    else
        sim.setObjectColor(sensorDetector,0,sim.colorcomponent_ambient_diffuse,{0,0,1})
    end
end

function sysCall_actuation() 
    result=sim.readProximitySensor(proxSensor)
    if (result>0.01) then reverseTime=sim.getSimulationTime()+1 end 
    if (reverseTime<sim.getSimulationTime()) then
        sim.setJointTargetVelocity(leftMotor,speed)
        sim.setJointTargetVelocity(rightMotor,speed)
    else
        sim.setJointTargetVelocity(rightMotor,reverseSpeed/2)
        sim.setJointTargetVelocity(leftMotor,reverseSpeed)
    end
    detectObjective()
end

function sysCall_cleanup() 
    simUI.destroy(ui)
end 
