function [nf, ns, ng] = getCubeNormals(cubeinfo)

ns = cubeinfo.vertices(2, :) - cubeinfo.vertices(1, :);
ns  = ns / norm(ns);
nf = cubeinfo.vertices(5, :) - cubeinfo.vertices(1, :);
nf  = nf / norm(nf);
ng = cubeinfo.vertices(4, :) - cubeinfo.vertices(1, :);
ng  = ng / norm(ng);
