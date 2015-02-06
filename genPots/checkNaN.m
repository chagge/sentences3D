function checkNaN(pots, loss)
% check whether there is a NaN in pots and loss
for i = 1:pots.num_features
    fprintf('\nchecking #%d potential\n', i);
    potentials = pots.potentials{i};
    for j = 1:numel(potentials.sample)
        sample = potentials.sample{j};
        for k = 1:numel(sample.local)
            local = sample.local{k};
            if isfield(local, 'pot')
                if sum(sum(isnan(local.pot) + isinf(local.pot)))
                    error('NaN found,pots.potentials{%d}.sample{%d}.local{%d}', i, j, k);
                end
            end
        end
        for k = 1:numel(sample.factor)
            factor = sample.factor{k};
            if ~isempty(factor)
                if sum(sum(isnan(factor.pot) + isinf(factor.pot)))
                    error('NaN found,pots.potentials{%d}.sample{%d}.factor{%d}', i, j, k);
                end
            end
        end
    end
end


fprintf('\nchecking loss.loss\n');
for i = 1:numel(loss.loss.sample)
    sample = loss.loss.sample{i};
    for j = 1:numel(sample.local)
        local = sample.local{j};
        if sum(isnan(local.pot) + isinf(local.pot))
            error('NaN found,loss.loss.sample{%d}.local{%d}', i, j);
        end
    end
    for j = 1:numel(sample.factor)
        factor = sample.factor{j};
        if sum(isnan(factor.pot) + isinf(factor.pot))
            error('NaN found,loss.loss.sample{%d}.factor{%d}', i, j);
        end
    end
end


fprintf('\nchecking loss.gtruths\n');
for i = 1:numel(loss.gtruths.sample)
    sample = loss.gtruths.sample{i};
    if sum(isnan(sample) + isinf(sample))
        error('NaN found,loss.gtruths.sample{%d}', i);
    end
end