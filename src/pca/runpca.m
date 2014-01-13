pwd
addpath('../../bin')
s = RandStream('mcg16807','Seed',0);
RandStream.setDefaultStream(s);

d=readsparse('<zcat mini.allsub.gz | ./../../bin/preinput.py');
d=full(d');
[C] = princomp(d);

dims = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];
for i = 1:length(dims)
  fname = sprintf('mini.pca.c%d', dims(i));
  fprintf(1, '%s\n', fname);
  V = C(:,1:dims(i));
  V = d * V;
  dlmwrite(fname, V, 'delimiter', '\t');
end
