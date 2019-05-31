stars = love.graphics.newParticleSystem(image.star, 20)
stars:setPosition(love.graphics.getWidth() * 0.5,  love.graphics.getHeight() * 0.5)
stars:setBufferSize(1000)
stars:setEmissionRate(100 )
stars:setEmitterLifetime(-1 )
stars:setParticleLifetime(2 )
stars:setColors(1, 1, 1, 1, 1, 1, 1, 0 )
stars:setSizes(0, 1, 1 )
stars:setSpeed(300, 400 )
stars:setSpread(math.rad(360))
stars:setSpread(math.rad(360))

return stars