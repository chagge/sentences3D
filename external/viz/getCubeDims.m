function [dims, u] = getCubeDims(cls)

datadir = '~/science/data/3D/nyu/gtobjects';
files = dir(fullfile(datadir, '*.mat'));
dims = zeros(10000, 3);
pntr = 1;
u = zeros(35, 1);

for i = 1 : length(files)
    if mod(i-1,50)==0, fprintf('%d/%d\n', i, length(files)); end;
    data = load(fullfile(datadir, files(i).name));
    objects = data.objects;
    
    for j = 1 : length(objects)
        label = objects(j).label;
        if label > 0
            u(label) = u(label)+1;
        end;
        if label == cls
            try
            dims(pntr, :) = objects(j).cube.dims;
            pntr = pntr + 1;
            end;
        end;
    end;
end;

dims = dims(1:pntr-1, :);