function [feat, loc] = getFeatMask(seg, feat, loc)

        dimx = round(max(max(loc(:, 1)), max(seg(:, 1)))) + 5;
        dimy = round(max(max(loc(:, 2)), max(seg(:, 2)))) + 5;
        mask = roipoly(zeros(dimy, dimx), seg(:, 1), seg(:, 2));
        indseg = sub2ind([dimy, dimx], loc(:, 2), loc(:, 1));
        val = mask(indseg);
        indregion = find(val == 1);
        
        feat = feat(:, indregion');
        loc = loc(indregion, :);