function loss = re_index_factors(loss, pots)

fac_counters = pots.fac_counters;
fac_counters_loss = loss.fac_counters;
pots = pots.potentials;

for i = 1 : length(loss.loss.sample)
    if ~isempty(loss.loss.sample{i})
        factor = loss.loss.sample{i}.factor;
        
        shift = fac_counters(i);
        if shift == 0 || fac_counters_loss(i) == 0
            continue;
        end;
        factors_out = [];
        %factors_out(shift+1:end) = factors;
        for j = 1 : length(factor)
            if ~isempty(loss.loss.sample{i}.factor{j})
               [ifeat, jfac] = findFactor(pots, i, factor{j}.nodes);
               if ifeat > 0
                   factors_out{jfac} = factor{j};
                   loss = re_connect(factor, j, loss, i, jfac);
               else
                   jfac = fac_counters(i)+1;
                   factors_out{jfac} = factor{j};
                   loss = re_connect(factor, j, loss, i, jfac);
               end;
            end;
        end;
        loss.loss.sample{i}.factor = factors_out;
    end;
end;

function [i, j] = findFactor(pots, isample, fac)

i = 0;
j = 0;
for k = 1 : length(pots)
    if ~isfield(pots{k}.sample{isample}, 'factor')
        continue;
    end;
    for p = 1 : length(pots{k}.sample{isample}.factor)
         if length(pots{k}.sample{isample}.factor) >= p && ~isempty(pots{k}.sample{isample}.factor{p})
           nodes = pots{k}.sample{isample}.factor{p}.nodes;
           if length(nodes) == length(fac)
               match = 1;
               for t = 1: length(fac)
                   match = match * double(~isempty(find(nodes==fac(t))));
               end;
               if match
                   i = k;
                   j = p;
               end;
           end;
        end;
    end;
end;

function loss = re_connect(factor, j, loss, i, jfac)

                   nodes = factor{j}.nodes;
                   for t = 1 : length(nodes)
                       connTo = loss.loss.sample{i}.local{nodes(t)}.connTo;
                       ind = find(connTo == j);
                       connTo(ind) = jfac;
                       loss.loss.sample{i}.local{nodes(t)}.connTo = connTo;
                   end;