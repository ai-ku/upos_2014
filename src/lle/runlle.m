pwd
addpath('../../bin')
s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

fprintf(1,'Reading Substitute data\n');
d=readsparse('<zcat mini.allsub.gz | ../../bin/preinput.py');

fprintf(1,'Reading neighbor data\n');
nn=readsparseidx('< zcat mini.knn5.gz', 100);

[Y] = lle(d, nn, 2048);
Y = Y';
dims = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];

for i = 1:length(dims)
  fname = sprintf('mini.lle.c%d', dims(i));
  fprintf(1, '%s\n', fname);
  V = Y(:,1:dims(i));
  dlmwrite(fname, V, 'delimiter', '\t');
end
