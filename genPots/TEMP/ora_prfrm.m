%% Oracle performance
%
%   R = ORA_PRFRM();
%   R = ORA_PRFRM('plot');
%
function accuracy = ora_prfrm(pl)

to_plot = nargin >= 1 && strcmpi(pl,'plot');

datadir = '/share/data/sentences3D/NYU';
spdir = fullfile(datadir, '/UCM/SuperSegments');
gtbdir = fullfile(datadir, '/data/segmentation/ourlabels');
clsfile = fullfile(datadir,'classes_reduced.mat');
dstfile = fullfile('/share/data/sentences3D/','code','TEMP',...
    'oralcle_cmatrix.mat');

threshold = [0.04 0.06 0.08 0.10 0.12 0.14 0.16 0.18 0.20];
class = load(clsfile);
nclass = numel(class.classes);
c_matrix = cell(1,numel(threshold));
accuracy = zeros(1,numel(threshold));
m_nsp = zeros(1,numel(threshold));


for i = 1:size(threshold,2);
    
    fprintf('Processing SuperSegment%.2f\n',threshold(i));
    Cm = zeros(nclass, nclass);
    av_nsp = 0;
    for j = 1:1449;
        if mod(j,100) == 0;
            fprintf('%d/1449\n',j);
        end;
        sp = load(fullfile(spdir,sprintf('SuperSegment%.2f/%04d.mat',...
            threshold(i),j)));
        sp = sp.sp;
        gt = imread(fullfile(gtbdir,sprintf('%04d.png',j)));
        nsp = max(sp(:));
        av_nsp = av_nsp + nsp;
        pot = zeros(nsp,nclass);
        
%         for p = 1:nsp;
%             for c = 1:32;
%                 result = sum(sum( (sp == p).*(gt ==c)));
%                 try
%                     statis(p, class.reduced_to_final(c)) = result;
%                 catch
%                     statis(p, 22) = result;
%                 end
%             end
%         end
        for k = 1:(640*480)
            p = sp(k);
            c = gt(k);
            pot(p, c) = pot(p, c) + 1;
        end
        [~,predict] = max(pot,[],2);
        
%         t_x = [1:nsp]';
%         prior = zeros(nsp,22);
%         right_pred = (predict-1)*nsp + t_x;
%         prior(right_pred) = 1;
%         
%         accuracy(i,1) = accuracy(i,1) + sum(sum(statis .* prior)) / (480*640);
        Cm = accumarray([gt(:),predict(sp(:))],ones(480*640,1),...
            [nclass, nclass]) + Cm;
    end
    Cm = Cm ./ repmat(sum(Cm,2),1,nclass);
    c_matrix{i} = Cm;
    accuracy(i) = mean(diag(Cm)); 
    m_nsp(i) = av_nsp / 1449;
end

save(dstfile,'c_matrix', 'accuracy','m_nsp');

if to_plot
    %accuracy
    subplot(2,1,1);
    bar(accuracy);
    title('Performance for different thresholds');
    xlabel('threshold');
    ylabel('accuracy');
    set(gca,'xticklabel',{'0.04', '0.06', '0.08', '0.10', '0.12',...
        '0.14', '0.16', '0.18', '0.20'});
    %average of number of super pixels
    subplot(2,1,2);
    bar(m_nsp);
    title('Mean number of super pixels for different thresholds');
    xlabel('threshold');
    ylabel('Mean number of super pixels');
    set(gca,'xticklabel',{'0.04', '0.06', '0.08', '0.10', '0.12',...
        '0.14', '0.16', '0.18', '0.20'});
end