function dims = getCubeDim(vertices)

dimx = norm(vertices(2, :) - vertices(1, :));
dimy = norm(vertices(4, :) - vertices(1, :));
dimz = norm(vertices(5, :) - vertices(1, :));
dims = [dimx, dimy, dimz];