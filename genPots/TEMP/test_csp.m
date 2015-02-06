%% Unary Potential
%
%   c_matrix = UNARY_POT();
%
function c_matrix = unary_pot()

datadir = '/share/data/sentences3D/NYU';
spdir = fullfile(datadir, '/UCM/SuperSegments');
potbdir = fullfile(datadir, '/data/segPredictions');
gtbdir = fullfile(datadir, '/data/segmentation/ourlabels');
clsfile = fullfile(datadir,'classes_reduced.mat');
root = '/share/data/sentences3D/NYU/data/segmentation';
test_list = textread(fullfile(root, 'data_split', 'test.txt'), '%s');

class = load(clsfile);
nclass = size(class.classes,1);
ntest = length(test_list);
c_matrix = zeros(nclass,nclass);
pred = load('/share/data/sentences3D/NYU/result_t/gt.g15/C1.0e-02/best.mat');


for j = 1:ntest;

    if mod(j,50) == 0;
        fprintf('%d/%d\n',j,ntest);
    end;
    
    id = str2num(test_list{j});   
    sp = load(fullfile(spdir,sprintf('SuperSegment0.10/%04d.mat', id)));
%    gt = load(fullfile(potbdir,sprintf('%04d.mat',j)));
    label = imread(fullfile(gtbdir,sprintf('%04d.png',j)));
    sp = sp.sp;
    nsp = max(sp(:));
    
%     %compute potential & ground truth
%     pot = zeros(nsp,nclass + 1); %[pot,npixel]
% %    label_st = zeros(nsp,nclass);
%     
%     for k = 1:(640*480)
%         my_sp = sp(k);
%         sj_sp = gt.seg(k);
%         temp = [gt.pot(sj_sp,:), 1];
%         pot(my_sp,:) = pot(my_sp,:) + temp;
%         
% %        l = lbl(k);
% %        label_st(my_sp, l) = label_st(my_sp, l) + 1;
% %        label_st(my_sp,:) = label_st(my_sp,:) + gt.gt(sj_sp,:);
% 
%     end
%     pot = pot(:,1:nclass) ./ repmat(pot(:,end),1,nclass);
% %    [~,label] = max(label_st,[],2);
%     
%     %inference
%     [~,predict] = max(pot,[],2);
    
    predict = pred.results(j).spixel_labels;
    %test
    c_matrix = accumarray([label(:),(predict(sp(:)))'],ones(480*640,1),[nclass, nclass]) + ...
        c_matrix;
end
c_matrix = c_matrix ./ repmat(sum(c_matrix,2),1,nclass);

%show
for i = 1 : nclass
    fprintf('%s: %0.4f\n', class.classes{i}, c_matrix(i, i));
end;

accuracy = mean(diag(c_matrix));
fprintf('accuracy: %0.4f\n', accuracy);
