
base_dir = 'william.26.01.2016/data/enregistrements_6/';
files = species_files(base_dir);

x = [];

i=1;

for j=1:size(files,2)
    x = [x;read_audio(files{i,j})];
end

n = 250;

Y = patches(x,n);

[U,S,V] = svd(L);
plot(diag(S))
pause;

size(Y)

lambda = 0.3;
tol = 1e-5;
maxIter=1000;

[L,S]=inexact_alm_rpca(Y,lambda);

[U,S,V] = svd(L);
plot(diag(S))


%[Y,L,S,params] = loadSyntheticProblem('verySmall_l1l2');

% -- Solve simplest constrained versions
% opts = struct('tol',1e-10,'printEvery',50,'L1L2','rows');
% normLS = sqrt(norm(L,'fro')^2+norm(S,'fro')^2);
% % opts.FISTA = true; opts.restart = Inf; opts.BB = false; opts.quasiNewton = false;
% opts.errFcn = @(LL,SS) sqrt(norm(LL-L,'fro')^2+norm(SS-S,'fro')^2)/normLS;
% % opts.sum    = true; % doesn't work with L1L2 = 'rows'
% opts.max    = true;
% [LL,SS,errHist] = solver_RPCA_constrained(Y,params.lambdaMax, params.tauMax,[], opts);
% fprintf(2,'Error with simple constrained version, L1L2 via rows, is %.2e (L), %.2e (S)\n\n', ...
%     norm( LL - L, 'fro')/norm(L,'fro'),  norm( SS - S, 'fro')/norm(S,'fro') );
