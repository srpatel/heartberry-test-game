-- Game variables
local elapsedTime = 0
local lastKey = "None"
local MAX_DT = 1/30  -- Cap dt to prevent large jumps (equivalent to 30 FPS minimum)

-- Joystick variables
local joystickCircles = {}  -- Table to store circle data for each joystick
local circleRadius = 20

function love.load()
    love.window.setFullscreen(true)
    love.mouse.setVisible(false)
end

function love.update(dt)
    -- Cap dt to prevent large jumps when resuming from suspend
    if dt > MAX_DT then
        dt = MAX_DT
    end
    
    elapsedTime = elapsedTime + dt
    
    -- Update joystick circle positions
    for joystick, circleData in pairs(joystickCircles) do
        if joystick:isConnected() then
            local leftX = joystick:getGamepadAxis("leftx")  -- Left stick X axis
            local leftY = joystick:getGamepadAxis("lefty")  -- Left stick Y axis
            
            -- Move circle based on joystick input
            local speed = 200  -- pixels per second
            circleData.x = circleData.x + leftX * speed * dt
            circleData.y = circleData.y + leftY * speed * dt
            
            -- Keep circle within screen bounds
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            circleData.x = math.max(circleRadius, math.min(screenWidth - circleRadius, circleData.x))
            circleData.y = math.max(circleRadius, math.min(screenHeight - circleRadius, circleData.y))
        end
    end
end

function love.keypressed(key)
    lastKey = key
end

-- Helper function to add a circle for a joystick
function addJoystickCircle(joystick)
    print(joystick:isGamepad())  -- Debug print to check if it's a gamepad
    print(joystick:getName())  -- Debug print to check if it's a gamepad
    print(joystick:getID())  -- Debug print to check if it's a gamepad

    if not joystickCircles[joystick] then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        
        joystickCircles[joystick] = {
            x = math.random(circleRadius, screenWidth - circleRadius),
            y = math.random(circleRadius, screenHeight - circleRadius),
            color = {math.random(), math.random(), math.random()}  -- Random color
        }
    end
end

-- Helper function to remove a circle for a joystick
function removeJoystickCircle(joystick)
    joystickCircles[joystick] = nil
end

-- Called when a joystick is connected
function love.joystickadded(joystick)
    addJoystickCircle(joystick)
end

-- Called when a joystick is removed
function love.joystickremoved(joystick)
    removeJoystickCircle(joystick)
end

function love.draw()
    -- Set white background
    love.graphics.clear(1, 1, 1, 1)  -- White background
    
    -- Set text color to black for visibility on white background
    love.graphics.setColor(0, 0, 0, 1)
    
    -- Display timer (rounded to 1 decimal place)
    love.graphics.print("Timer: " .. string.format("%.1f", elapsedTime) .. " seconds", 50, 50)
    
    -- Display last pressed key
    love.graphics.print("Last key pressed: " .. lastKey, 50, 100)
    
    -- Display window resolution
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.print("Resolution: " .. screenWidth .. " x " .. screenHeight, 50, 150)
    
    -- Display joystick count
    local joystickCount = 0
    for _ in pairs(joystickCircles) do
        joystickCount = joystickCount + 1
    end
    love.graphics.print("Connected joysticks: " .. joystickCount, 50, 200)
    
    -- Draw joystick circles
    for joystick, circleData in pairs(joystickCircles) do
        if joystick:isConnected() then
            love.graphics.setColor(circleData.color[1], circleData.color[2], circleData.color[3], 1)
            love.graphics.circle("fill", circleData.x, circleData.y, circleRadius)
        end
    end
    
    -- Reset color to white for next frame
    love.graphics.setColor(1, 1, 1, 1)
end