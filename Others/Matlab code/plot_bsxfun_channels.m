%%
% simulation details
nchannels = 50;
npnts     = 1000;

% create correlated multivariate time series
cormat = rand(nchannels);
[evecs,evals] = eig(cormat*cormat');
data = evecs*sqrt(evals) * randn(nchannels,npnts);

% optional: detrended-integral of time series looks more realistic
data = detrend( cumsum(data,2)' )';

% plot all channels with a single line
figure(3), clf
plot(1:npnts, bsxfun(@plus, data, (1:nchannels)' *10))
xlabel('Time (a.u.)')
set(gca,'ytick',[])

