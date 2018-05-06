-- Distance between two 3D points:
-- From: https://love2d.org/wiki/General_math
function math.dist(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end
