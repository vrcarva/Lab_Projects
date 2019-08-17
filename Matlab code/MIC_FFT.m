%% Microfone e FFT
% Flavio Mourao. Nucleo de Neurociencias

% Grava o audio atraves do microfone do computador, calcula a FFT e plota os
% resultados em tempo real. 
% Funcao audiorecorder: a partir do matlab 2014

%%

% Parametros para registrar e analisar
srate = 44100/2;             % amostragem
time  = 0:1/srate:1-1/srate; % vetor tempo
n     = length(time);        % numero de pontos
hz    = linspace(0,srate,n); % frequecias

% Plots
figure(1), clf

% Dominio do Tempo
subplot(211)
timeh = plot(time,zeros(n,1),'k','linew',1);
set(gca,'ylim',[-1 1]/7)
xlabel('Tempo (seg.)'), ylabel('Amplitude')
title('Dominio do Tempo')

% Dominio da Frequencia
subplot(212)
freqh = plot(hz,zeros(n,1),'r','linew',1);
set(gca,'xlim',[0 2000],'ylim',[0 5]*1e-6)
xlabel('Frequencia (Hz)'), ylabel('Power')
title('Dominio da Frequencia')


% Gravador
auddat = audiorecorder(srate,8,1);

% Inicia a gravacao usando um "buffer"
record(auddat);
pause(1.1);

while 1
    % Pega os dados do segundo anterior
    data = getaudiodata(auddat);
    data = data(end-srate+1:end);
    
    % atualiza os plots
    set(timeh,'YData',data);
    set(freqh,'YData',abs(fft(data)/n).^2);
    
    pause(.1)
end

% parar o registro - ctrl+c
stop(auddat);


%%
