%% Choose channel and Filt

%ch=6;

ch=1;

dado=LFP_all(:,ch)';

lowcutoff=55;
highcutoff=120;
chosenFs=1000;

[y55_120]=eegfilt2(dado,chosenFs,lowcutoff,[]);
[y55_120]=eegfilt2(y55_120,chosenFs,[],highcutoff);

y55_120=y55_120';


clear lowcutoff highcutoff chosenFs

lowcutoff=1;
highcutoff=2;
chosenFs=1000;

[y1_2]=eegfilt2(dado,chosenFs,lowcutoff,[]);
[y1_2]=eegfilt2(y1_2,chosenFs,[],highcutoff);

y1_2=y1_2';

dado=dado';

H=abs(hilbert(y55_120));


%% Get events and plot overview of the experiment

events = getRawTTLs('Events.nev');

%% plot overview

idx=find(events(:,2)==2);

dado=LFP_all(:,1);

plot(TS,dado,'k');
hold on;
plot(TS,(y55_120.*5)-0.4,'r');
plot(events(idx,1)./1000000,-0.6,'bs');
ylabel('Amplitude (mV)','FontSize',18);
xlabel('Time (s)','FontSize',18);
box off;
set(gcf,'color',[1 1 1]);
%ylim([-6.5 -1.5])
hold off
%legend('Raw LFP (mPFC)','Gamma filtered','Blue light pulse'); 