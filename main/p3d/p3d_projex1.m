function p3d_projex1(idx)
%P3D_PROJEX1 Demos the use of p3d_projcube.

datadir = '/share/data/sentences3D/NYU';

sc = load(fullfile(datadir, sprintf('rot_scenes/sc%04d.mat',idx)));
g = load(fullfile(datadir, sprintf('gtobjects_r/%04d.mat',idx)));

imshow(sc.image);
hold on;

for i = 1 : length(g.objects)
    p3d_projcube(sc, g.objects(i).cube, 'r');
end
