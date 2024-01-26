# C951 Task 2 Writeup

Xavier Loera Flores
ID:011037676
xloeraf@wgu.edu
C951 Introduction to Artificial Intelligence

## Disaster Recovery Environment & Obstacles

The robot will navigate a disaster environment that is representative of a burning building with two key obstacles in the way of the robot. Fire will be scattered and present throughout the simulation in small patches that can be navigated around. There are also large pieces of debris that block large portions of the environment. The robot will need to navigate around the fire and debris to find its objectives.

## Robot Improvements to Disaster Recovery

The robot will improve disaster recovery in the environment by adapting to the obstacles in the environment. The robot will be able to navigate around the fire and debris to find its objectives. It will be able to navigate into hard to reach areas and find survivors that are trapped in the environment.

## Justifications for Robot Architecture Modifications

The robot is equipped with an additional proximity sensor and a object detector sensor. The proximity sensor allows the robot to detect any obstacles or walls that are in the way of the robot. The object detector will allow the robot to identify wether an object is an obstacle or an objective. These sensors allow the robot to navigate around obstacles and find objectives.

## Maintenance Internal Environment Representation

Utilizing both the object detector sensor as well as the proximity sensor, the robot is able to maintain an internal environment representation. The object detector sensor allows the robot to identify objects in the environment and the proximity sensor allows the robot to identify the distance between the robot and the object. The robot can use this information to create a map of the environment and identify where obstacles are located. Once the robot has where obstacles are located, it uses this information to change is course and navigate towards a different direction. The robot uses the object detector sensor and marks them as found once it has reached them.

## Reasoning, Knowledge Representation, Uncertainty, Intelligence

#### Reasoning

The robot follows the following reasoning to achieve its goal. It will move forward until finds an obstacle. It will then change course an move in a different direction. While it is doing this, it will be looking for objective targets to mark them as found.

#### Knowledge Representation

#### Uncertainty

#### Intelligence

## Further Prototype Improvements

There are many improvements that can made to the robot to support its disaster relief endeavors. The main issue with the robot is that it has no way to access space completely blocked off by obstacles.
The following are potential physical improvements that can be made to the robot to mitigate this issue:

- Flight: The robot can be equipped with a flight mechanism that allows it to fly over obstacles. This would allow the robot to access areas that are completely blocked off by obstacles.
- Mechanical Arms: The robot can be equipped with mechanical arms that allow it to move obstacles out of the way. This would allow the robot to access areas that are partially blocked off by obstacles.
- Drill: The robot can be equipped with a drill that allows it to drill through obstacles. This would allow the robot to access areas that are partially blocked off by obstacles.

Alternatively, the robot can improve it's performance and learning through the use of reinforced learning and advanced search algorithms.

- Reinforced Learning: The robot can be equipped with reinforced learning to improve its performance. Reinforced learning would allow the robot to learn from its mistakes and improve its performance over time if we reward/penalize the robot on its effectiveness for searching a space. This would allow the robot to learn how to navigate environments more efficiently and find more survivors in a shorter amount of time.

- Advanced Search Algorithms: The robot can be equipped with advanced search algorithms such as a depth first search or greedy algorithm to cover more ground and find more survivors. This would allow the robot to find more survivors in a shorter amount of time since the robot won't be randomly searching the environment and retreading the same ground.

## Robot Source Code

Main Robot Code:

```
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
```

The remainder of the code which consists of small scripts can be found in the Coppelia Robotics file.

## Sources

I did not use any external sources to complete this writeup.
