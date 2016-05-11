[y,Fs] = audioread('william.26.01.2016/data/enregistrements_6/data_cantans/018 _1_S.wav');
y = y(100000:300000);

y(1:100)
max(real(y))
min(real(y))

f = fft(y);

numel(f)
f = symmetric_crop(f);
[~,ind] = sort(f,'descend');

c = 0.0001;
ind = ind(5000:end);
f(ind) = 0;

f = symmetric_extend(f);

comp = ifft(f);

comp(1:100)
max(real(comp))
min(real(comp))

sound(comp,Fs)