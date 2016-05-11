[y,Fs] = audioread('william.26.01.2016/data/enregistrements_6/data_cantans/018 _1_S.wav');
y = y(100000:300000);


dt = 1;

s1{1} = y;
s1{2} = dt;


scales = 1:0.1:50;
wname  = 'morl';
par    = 6;
WAV    = {wname,par};
cwt_s1_lin = cwtft(s1,'scales',scales,'wavelet',WAV,'plot');


