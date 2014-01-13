% mex readsparse.c -largeArrayDims
pwd
addpath('../../bin')
s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);
%%%
cluster = 4096;
sigma = 0;
data=readsparse('< zcat mini.knn5.gz', 100);
tdata = data';
sdata = max(tdata, data);
clear tdata, data;
dims = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
[U Evec Eig] = sc(sdata, sigma,cluster);

% dlmwrite('/scratch/1/myatbaz/mini.knn5.spectral.vec', U, 'delimiter', '\t');
% dlmwrite('/scratch/1/myatbaz/mini.knn5.spectral.eigvec', Evec, 'delimiter','\t');
% dlmwrite('/scratch/1/myatbaz/mini.knn5.spectral.eigval', Eig, 'delimiter', '\t');

for i = 1:length(dims)
  fname = sprintf('mini.spectral.c%d', dims(i));
  fprintf(1, '%s\n', fname);
  V = U(:,1:dims(i));
  sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
  cluvec = V ./ repmat(sq_sum, 1, dims(i));
  dlmwrite(fname, cluvec, 'delimiter', '\t');
end
