# Matlab Scripts

Main.m<br />
- Call the scripts<br />
- Make some plots<br />

Extracting_raw_LFPs_and_Events .m<br />
- Extract and save data from Intan/Open Ephys:  *.continuous and  *.events<br />
- Required function: load_open_ephys_data.m (https://github.com/open-ephys/analysis-tools)<br />

F_filter<br />
- It filters the signal by two options: <br />
   _ Filter with manually defined parameters and Matlab buil function: filtfilt.m<br />
   _ Filter function (based on EEG_lab): 'fun_myfilters.m' <br />
   
Pre_processing.m<br />
- Define sound epochs<br />
- Organize channels according to the electrodes map<br />
- Estimate the CS modulating signal from digital pulses<br />
- Concatenate the modulator signal as channel 1<br />
- Organize data by trials <br />

sFFT_spectrogram.m
- Short-time FFT by matlab built function spectrogram <br />
- Organizing data trials from the spectrogram<br />  
- Make some plots<br /> 

sFFT_stats.m
- Performs descriptive analysis from the spectrogram <br />

CorCov.m
- Performs Correlation and Covariance Matrices betwwen channels <br />


All code by Flavio Mourao. Nucleo de Neurociencias - NNC<br />
email: mourao.fg@gmail.com<br />
Universidade Federal de Minas Gerais<br />
Brazil<br />
