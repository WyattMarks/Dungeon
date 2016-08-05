return function (e, dt)
    if not e.isLocal then return false end
    e.targetX, e.targetY = camera:worldCoords(love.mouse.getPosition())
end

