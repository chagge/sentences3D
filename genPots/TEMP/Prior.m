function R = Prior()
datadir = '/share/data/sentences3D/NYU';
scenedir = fullfile(datadir, 'rot_scenes');
objdir = fullfile(datadir, 'gtobjects_r');

ind_obj = 11;
bias = 12;
scaler = 100;


for idx = 1:1449;
    if mod(idx,50)==0;
        fprintf('examined %d ...\n',idx);
    end
    sc = load(fullfile(scenedir, sprintf('sc%04d.mat',idx)));
    obj = load(fullfile(objdir, sprintf('%04d.mat',idx)));
    for  i = 1:size(obj.objects,1);
        if obj.objects(i).label == ind_obj;
            for j = 1:size(obj.objects(i).pixels,1);
                world = floor((sc.wcoords(obj.objects(i).pixels(j),:)+bias)*scaler);
                try
                    R(world(1), world(2), world(3)) = ...
                        R(world(1), world(2), world(3)) + 1;
                catch
                    R(world(1), world(2), world(3)) = 0;
                end
            end
        end
    end
end