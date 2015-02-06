function [feat, loc] = readFeatFile(filename)

[~, ~, ext] = fileparts(filename);
if strcmp(ext, '.text')
   [feat, loc] = readTextDescriptors(filename); 
else
   [feat, loc]= readBinaryDescriptors(filename);
end;

function [feat, loc] = readTextDescriptors(filename)

    text = textread(filename, '%s', 'delimiter', '\n'); %#ok<REMFF1>
    size_feature = str2num(text{2});
    num_points = str2num(text{3});
    feat = zeros(size_feature, num_points);
    loc = zeros(num_points, 3);
    for i_point = 1:num_points
        f_v_s = text{i_point+3};
        sep = regexp(f_v_s, ';');
        locinfo = f_v_s(1:sep(1) - 2);
        p = findstr(locinfo, 'CIRCLE');
        locinfo = locinfo(p(1)+7:end);
        locinfo = str2num(locinfo);
        f_v_s = f_v_s(sep(1)+1:sep(2)-1);
        f_v = str2num(f_v_s)';
        if numel(f_v) ~= size_feature
            error('wrong size of feature in %4d.text, the %d-th points', i_data, points(i_point));
        end
        %f_v = uint8(f_v * ac);
        feat(:, i_point) = f_v;
        loc(i_point, :) = locinfo(1:3);
    end
    
    
function [feat, loc]= readBinaryDescriptors(filename)

fid = fopen(filename,'rb');             % Open binary file
m = char(fread(fid,16,'uint8'));   % header BINDESC1 + datatype
Z1=fread(fid,4,'uint32');
elementsPerPoint = Z1(1);
dimensionCount = Z1(2);
pointCount = Z1(3);
bytesPerElement = Z1(4);

loc = my_vec2mat(fread(fid, elementsPerPoint * pointCount, 'double'), elementsPerPoint );
feat = my_vec2mat(fread(fid, dimensionCount * pointCount, 'double'), dimensionCount );
feat = feat';
fclose(fid);


function b = my_vec2mat(c, nc)
b = reshape([c(:) ; zeros(rem(nc - rem(numel(c),nc),nc),1)],nc,[]).';
    