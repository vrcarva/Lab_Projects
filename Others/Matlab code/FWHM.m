srate = 1612; % in hz, 
time  = linspace(-1,1,srate);
width = width1; % comprimento da gaus.
windows = 50; % numero de janelas
peaktime = -0.9 + (1.8)*rand(1,windows); % pico em segundos

signal = exp((-(time-0).^2) / (2*width^2));

[v,peakx]  = max(signal); 
[~,left5]  = min(abs(signal(1:peakx)-.5));
[~,right5] = min(abs(signal(peakx:end)-.5));
right5 = right5+peakx-1;

figure
hold on
plot(time,signal,'k','linew',2)
plot([time(peakx) time(peakx)],[0 v], 'k--','linew',.5)
plot([time(left5) time(left5)],[0 0], 'ro','linew',.5)
plot([time(right5) time(right5)],[0 0], 'ro','linew',.5)
plot([time(right5) time(right5)],[signal(right5) signal(right5)], 'ro','linew',.5)
plot([time(left5) time(left5)],[signal(left5) signal(left5)], 'ro','linew',.5)

FWHM = time(right5) - time(left5)
FWHM = 2*sqrt(2*log(2))*width;