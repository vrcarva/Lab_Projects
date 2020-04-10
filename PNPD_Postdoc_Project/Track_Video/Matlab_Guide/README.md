# Guide to synchronize behavior with the electrophysiological record

 - Manually extract timestamps from possible behavioral events<br />

- Outputs:<br />
       .TS_LFPindex - Events (index) according to the record<br />
       .TS_LFPsec    - Events (in seconds) according to the record<br />
       .TSseconds    - Events (in seconds) according to the respective video frames<br />
       .TSframes      - Frames number where events occurred<br />


The code relies on the following functions:<br />

 --> showFrameOnAxis_2.m --> Display input video frame on axis<br />
       Computer Vision Toolbox - Copyright 2004-2010 The MathWorks, Inc.<br />

 --> load_open_ephys_data.m --> Open *.continuos from Openephys<br />
       https://github.com/open-ephys/analysis-tools<br />

Authors: 
Vinicius Carvalho. Nucleo de Neurociencias NNC.<br />
email: vrcarva@gmail.com<br />

Flavio Mourao. Nucleo de Neurociencias NNC.<br />
email: mourao.fg@gmail.com<br />



![https://github.com/fgmourao/Lab_Projects/blob/master/PNPD_Postdoc_Project/Track_Video/Matlab_Guide/Images/layout.png](https://github.com/fgmourao/Lab_Projects/blob/master/PNPD_Postdoc_Project/Track_Video/Matlab_Guide/Images/layout.png)
