function C = confusionMatrix(z1, z2)
% Normalized with respect to z1
% Input
%   z1 = true class for each sample
%   z2 = assigned class to each sample
% Output
%   C = confusion matrix, such that:
%     C(i,j) = percentage of times that class i (z1=i) is assigned to class j (z2=j)
%     sum(C(i,:)) = 100

n = length(unique(z1));
if ~isempty(find(z1==0))
    ind = find(z1 == 0);
    z1(ind) = n+1;
    ind = find(z2 == 0);
    z2(ind) = n;
    n = n+1;
end;
m = length(unique(z2));
n = max(n,m);
m = n;
u = unique([z1; z2]);

C = zeros([n m]);
for i = 1:n
    for j = 1:m
        C(i,j) = 100*sum((z1==u(i)).*(z2==u(j))) / sum(z1==u(i));
    end
end

ind = find(isnan(C));
C(ind) = 0;