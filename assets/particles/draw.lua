function drawparticles(name)
  love.graphics.draw(particles[name] )
  love.graphics.setColor(0.1, 0.1, 0.1, 0.3)
  love.graphics.rectangle("fill", 000,000, love.graphics.getDimensions())
end
return drawparticles