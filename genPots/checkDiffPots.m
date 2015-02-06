function checkDiffPots(pots1, pots2, loss1, loss2)
% check whether there is a NaN in pots and loss
for i = 1:pots1.num_features
    fprintf('\nchecking #%d potential\n', i);
    potentials1 = pots1.potentials{i};
    potentials2 = pots2.potentials{i};
    for j = 1:numel(potentials1.sample)
        sample1 = potentials1.sample{j};
        sample2 = potentials2.sample{j};
        for k = 1:numel(sample1.local)
            local1 = sample1.local{k};
            local2 = sample2.local{k};
            if isfield(local1, 'pot')
                if ~isequal(local1.pot, local2.pot)
                    error('Diff found,pots.potentials{%d}.sample{%d}.local{%d}', i, j, k);
                end
            end
        end
        for k = 1:numel(sample1.factor)
            factor1 = sample1.factor{k};
            factor2 = sample2.factor{k};
            if ~isempty(factor1)
                if ~isequal(factor1, factor2)
                    error('Diff found,pots.potentials{%d}.sample{%d}.factor{%d}', i, j, k);
                end
            end
        end
    end
end

fprintf('\nchecking loss.loss\n');
for i = 1:numel(loss1.loss.sample)
    sample1 = loss1.loss.sample{i};
    sample2 = loss2.loss.sample{i};
    for j = 1:numel(sample1.local)
        local1 = sample1.local{j};
        local2 = sample2.local{j};
        if ~isequal(local1.pot, local2.pot)
            error('Diff found,loss.loss.sample{%d}.local{%d}', i, j);
        end
    end
    for j = 1:numel(sample1.factor)
        factor1 = sample1.factor{j};
        factor2 = sample2.factor{j};
        if ~isequal(factor1, factor2)
            error('Diff found,loss.loss.sample{%d}.factor{%d}', i, j);
        end
    end
end


fprintf('\nchecking loss.gtruths\n');
for i = 1:numel(loss1.gtruths.sample)
    sample1 = loss1.gtruths.sample{i};
    sample2 = loss2.gtruths.sample{i};
    if ~isequal(sample1, sample2)
        error('Diff found,loss.gtruths.sample{%d}', i);
    end
end