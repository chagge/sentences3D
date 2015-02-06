function vis = get_box_viz2(box3D, boxView)

% assumes camera is in [0,0,0]

k = convhull(boxView(1,:), boxView(2,:));
vis = zeros(1, 8);
vis(k) = 1;
C = 0.5 * (box3D.vertices(1, :) + box3D.vertices(7, :));
visfaces = getvisfaces(boxView, box3D.faces);

for i = 1 : size(box3D.faces, 1)
    face = box3D.faces(i, :);
    vert = box3D.vertices(face, :);
    n = cross(vert(2, :)' - vert(1, :)', vert(3, :)' - vert(1, :)');
    n = n / norm(n);
    %t = - n' * (C - vert(1, :))';
    sgnbox = (- n' * (C - vert(1, :))');  % normal pointing outwards
    
    sgncam = (- n' * (- vert(1, :))');
    
    if sgnbox * sgncam < 0 & visfaces(i) > 0.5
        vis(face) = 1;
    end;
end;



function visfaces = getvisfaces(boxView, faces)

visfaces = ones(size(faces, 1), 1);
wbox = max(boxView(1, :)) - min(boxView(1, :));
hbox = max(boxView(2, :)) - min(boxView(2, :));

for i = 1 : size(faces, 1)
    w = max(boxView(1, faces(i, :))) - min(boxView(1, faces(i, :)));
    h = max(boxView(2, faces(i, :))) - min(boxView(2, faces(i, :)));
    if min(w,h) < 2 | (w < 0.06 * wbox) | (h < 0.06 * hbox) |  (min(w,h) < 0.06*max(w,h))
        visfaces(i) = 0.5;
    end;
end;