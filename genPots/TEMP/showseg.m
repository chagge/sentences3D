function showseg()
datadir = '/share/data/sentences3D/NYU/descriptions_final';
idx = 34;
load(fullfile(datadir, sprintf('%04d.mat',idx)));
for i = 1:6;
    subplot(2,3,i);
    seg = annotation.seg{i};
    ind = seg(:,1) + (seg(:,2) - 1)*480;
    im = zeros(480,640);
    im(ind) = 1;
    imagesc(im);
    title(annotation.class{i});
end