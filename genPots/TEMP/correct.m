
datadir = '/share/data/sentences3D/NYU';
spdir = fullfile(datadir, '/UCM/SuperSegments');
potbdir = fullfile(datadir, '/data/segPredictions');
gtbdir = fullfile(datadir, '/data/segmentation/ourlabels');
clsfile = fullfile(datadir,'classes_reduced.mat');
dstdir = fullfile(datadir, 'rgbdt_segpot');
for j = 1:1449;

    if mod(j,200) == 0;
        fprintf('processed %d/1449\n',j);
    end;
      
    sp = load(fullfile(spdir,sprintf('SuperSegment0.10/%04d.mat', j)));
%    gt = load(fullfile(potbdir,sprintf('%04d.mat',j)));
%    lb = imread(fullfile(gtbdir,sprintf('%04d.png',j)));
    sp = sp.sp;
    nsp = max(sp(:));
    
    %compute potential & label
%    pot = zeros(nsp,nclass + 1); %[pot,npixel]
%    label = zeros(nsp,nclass);
    
%     for k = 1:(640*480)
%         my_sp = sp(k);
%         sj_sp = gt.seg(k);
%         l = lb(k);
%         temp = [gt.pot(sj_sp,:), 1];
%         pot(my_sp,:) = pot(my_sp,:) + temp;
%         label(my_sp, l) = label(my_sp, l) + 1; 
%     end
%     pot = pot(:,1:nclass) ./ repmat(pot(:,end),1,nclass);%#ok<NASGU>
%     
    dstfile = fullfile(dstdir,sprintf('sp%04d.mat',j));
    save(dstfile, 'sp');
end

fprintf(' segmentation potential processed.\n');