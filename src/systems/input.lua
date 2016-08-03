local input = function(entity, dt)
    if not entity.isLocal then
        return false
    end

	if not ( entity.right and entity.left ) then
        if entity.right then
            entity.xvel = entity.speed
        elseif entity.left then
            entity.xvel = -entity.speed
        else
            entity.xvel = 0
        end
    else 
        entity.xvel = 0
    end

    if not ( entity.down and entity.up ) then
        if entity.up then
            entity.yvel = -entity.speed
        elseif entity.down then
            entity.yvel = entity.speed
        else
            entity.yvel = 0
        end
    else
        entity.yvel = 0
    end
end





return input