datadir = '/share/data/sentences3D/NYU';
scenedir = fullfile(datadir, 'rot_scenes');

pmin = zeros(1449,3); % x, y, z
pmax = zeros(1449,3); % x, y, z
for idx = 1:1449;
    if mod(idx,50)==0;
        fprintf('examined %d ...\n',idx);
    end
    sc = load(fullfile(scenedir, sprintf('sc%04d.mat',idx)));
    pmax(idx,:) = max(sc.wcoords,[],1);
    pmin(idx,:) = min(sc.wcoords,[],1);
end

pMAX = max(pmax,[],1);
pMIN = min(pmin,[],1);