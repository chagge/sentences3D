%  Cs = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5];
Cs = 0.01;
cfgs = {'r1_gt.cfg', 'r2_gt.cfg', 'r3_gt.cfg', 'r4_gt.cfg', 'r5_gt.cfg', 'r6_gt.cfg'};
objty = 'gt';
for k = 1 : length(cfgs)
    for i = 1 : length(Cs)
        disp(cfgs{k});
        C = Cs(i);
        disp(num2str(C));
        cfg = cfgs{k};
        sen3d_main(objty, cfg, C);
    end
end
    
