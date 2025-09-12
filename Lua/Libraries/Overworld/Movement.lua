return function()
    local self = { }

    self.speed = 0
    self.walkSpeedCap = 2
    self.runSpeedCap = 4

    self.followPosition = { nil, {}, {}, {} }
    self.followDistance = 24  -- Not *actual* distance. It's the amount of frames it'll take the party member (ID above 1) to reach the Player (ID equal to 1).
    function self.ResetFollowPosition(id, _x, _y, _dir)
        self.followPosition[id] = {}
        local spacing = self.followDistance

        for j=1, spacing*id do
            table.insert(self.followPosition[id], {x=_x, y=_y, direction=_dir})
        end
    end
    function self.MakeFollowPathTowardPlayer(partyID, startX, startY, endX, endY, walkingDirection)
        self.followPosition[partyID] = {}
        local spaceBetweenSteps = self.followDistance
        local stepLength = { (endX-startX)/spaceBetweenSteps, (endY-startY)/spaceBetweenSteps }

        for j=1, spaceBetweenSteps*partyID do
            local stepData = {
                x = endX - stepLength[1]*j,
                y = endY + stepLength[2]*j,
                direction = walkingDirection
            }
            table.insert( self.followPosition[partyID], stepData )
        end
        
    end

    function MoveValueToward(start, destination, speed)
        local direction = 0
        if start < destination then
            direction = 1
        elseif start > destination then
            direction = -1
        end
        local result = start + (speed*direction)
    
        if direction == -1 and result < destination then
            result = destination
        elseif direction == 1 and result > destination then
            result = destination
        end
    
        return result
    end

    -- Ripped from the MEOW overworld library.
    function self.MovePlayer(playerid, x, y)
        local player = playerid
        local movedX = x ~= 0
        local movedY = y ~= 0
        local hitboxX = player.posX + player.hitbox.startX
        local hitboxY = player.posY + player.hitbox.startY

        -- If the 4 corners of the Player's sprite moved horizontally are not on a solid tile, move the Player horizontally
        if movedX then
            local playerPlusX = hitboxX + x
            local leftX  = playerPlusX
            local rightX = playerPlusX + player.hitbox.width
            local downX  = hitboxY
            local upX    = hitboxY + player.hitbox.height
            movedX = not self.issolid(leftX, downX) and not self.issolid(leftX, upX) and not self.issolid(rightX, downX) and not self.issolid(rightX, upX)
            if movedX then
                player.Move(x, 0)
            end
        end

        -- If the 4 corners of the Player's sprite moved vertically are not on a solid tile, move the Player vertically
        if movedY then
            local playerPlusY = hitboxY + y
            local leftY  = hitboxX
            local rightY = hitboxX + player.hitbox.width
            local downY  = playerPlusY
            local upY    = playerPlusY + player.hitbox.height
            movedY = not self.issolid(leftY, downY) and not self.issolid(leftY, upY) and not self.issolid(rightY, downY) and not self.issolid(rightY, upY)
            if movedY then
                player.Move(0, y)
            end
        end
    end

    function self.issolid(x1, y1)
        if Overworld.room.ogmoVersion == nil then
            return false end
        local collisionTiles = Overworld.room.layers["solid"]
        local currentTileLayer = collisionTiles.data2D or {{}}
        local x = math.floor(x1 / (collisionTiles.gridCellWidth or 1)) + 1
        local y = math.abs(math.floor(-y1 / (collisionTiles.gridCellHeight or 1)) + 1)

        if (x < 1) or (x > #currentTileLayer[1]) or (y < 1) or (y > #currentTileLayer) then
            return true end
        return (currentTileLayer[y][x] == 0)
    end

    function self.UpdatePlayerMovement(players)
        local playerDirection = {x = 0, y = 0}
        for i=1, #players do
            local player = players[i]
            local direction = {x = 0, y = 0}
            
            -- The leading player, the one controlled by the user.
            if i == 1 then
                if Input.Up == 2 then 
                    direction.y = direction.y + 1 end
                if Input.Down == 2 then 
                    direction.y = direction.y - 1 end
                
                if Input.Right == 2 then
                    direction.x = direction.x + 1 end
                if Input.Left == 2 then 
                    direction.x = direction.x - 1 end
                

                local isRunning = (Input.Cancel == 2)
                if not isRunning and not self.walkedNearEdge(player) then
                    if self.speed < self.runSpeedCap then
                        self.speed = MoveValueToward(self.speed, self.runSpeedCap, 0.2)
                    end
                else
                    if self.speed > self.walkSpeedCap then
                        self.speed = self.walkSpeedCap
                    else
                        self.speed = MoveValueToward(self.speed, self.walkSpeedCap, 0.4)
                    end
                end

                if direction.x ~= 0 and direction.y ~= 0 then
                    direction.x = 1 * math.sign(direction.x)
                    direction.y = 0.7 * math.sign(direction.y)
                end

                direction.x = direction.x * self.speed
                direction.y = direction.y * self.speed
                self.MovePlayer(player, direction.x, direction.y)
                playerDirection = direction

            -- The other players, which follow in a row.
            else
                if #self.followPosition[i] > 0 then
                    local last = self.followDistance*(i-1)
                    local array = {x=players[1].posX, y=players[1].posY, direction=players[1].direction}

                    if not (playerDirection.x == 0 and playerDirection.y == 0) then
                        player.MoveToAbs(self.followPosition[i][last].x, self.followPosition[i][last].y)
                        player.direction = self.followPosition[i][last].direction

                        table.remove( self.followPosition[i], last )
                        table.insert( self.followPosition[i], 1, array )
                    end

                end


            end
        end

    end

    -- Check whether the player should slow down for being too close to an edge. Like in OG Deltarune.
    function self.walkedNearEdge(player)
        local sides = {
            {0, 2.4}, {1.4, 0}, {0, -0.7}, {-1.4, 0}
        }
        local nearEdge = false
        local distance = 12

        for i=1, #sides do
            nearEdge = nearEdge or self.issolid(player.posX + sides[i][1]*distance, player.posY + sides[i][2]*distance)
        end
        return nearEdge

    end

    return self
end