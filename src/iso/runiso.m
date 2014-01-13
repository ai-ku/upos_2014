s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

addpath('../../bin');

reduced = [2 4 8 16 32 64 128 256 512 1024 2048];
options = struct('dims', reduced, 'overlay', 0, 'comp', 1, 'display', 0, 'dijkstra', 1, 'verbose', 1)

d = readsparse('<zcat mini.knn5.gz', 100);
D = max(d, d');

[Y, R, E] = IsomapII(D, 'k', 100, options);

% For debug purpose
%save('yre.100nn.2048.mat', 'Y', 'R', 'E');

for i = 1:length(reduced)
    A = Y.coords{i}';
    [m, n] = size(A);
    dlmwrite(['mini.iso.c' int2str(n)], A, 'delimiter', ' ');
end
