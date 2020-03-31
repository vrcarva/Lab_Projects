function [ ffiltered ] = fun_myfilters(f,Fs,bandcuts,tipo,params )
% [ ffiltered ] = fun_myfilters(f,Fs,bandcuts,tipo,params )
%  filters a signal f, according to a specific filter type (eegfilt from eeglab, EWT or butterworth/cheby/ellip etc)
%INPUTS
%*f: signal to be filtered
%*Fs: Sampling Frequency (Hz)
%*bandcuts: Vector with 2 elements [lowcut highcut] - Lower and upper
%frequency bounds. if lowcut = 0 -> lowpass. if highcut = 0 ->highpass
%*tipo:
%   'EWT' EWT filter - check funEWTfilt
%   eegfilt - EEGLAB eegfilt function (2 way fir least squares, default parameters)
%   iir - matlab's design filter. Parameters defined by params
%*params(optional): iir filter parameters
%   params.iirtype: design type: default 'butter'
%   params.order: filter order (default 10)
%   params.bandstop: = 1 if notch filter(only IIR and FIR)
%OUTPUTS:
%ffiltered: the filtered signal

if isfield(params,'bandstop')
    Notchfilt = params.bandstop;
else
    Notchfilt = 0;
end

if strcmp(lower(tipo),'ewt')
    [ modos ] = funEWTfilt(f,Fs,bandcuts,0 );
    if bandcuts(1) ~=0 && bandcuts(2)~=0
        ffiltered = modos(2,:);
    else
        if bandcuts(1) ==0
            ffiltered = modos(1,:);
        end
        
        if bandcuts(2) ==0
            ffiltered = modos(end,:);
        end
    end
end

if strcmp(tipo,'eegfilt')
    if Notchfilt
        ffiltered = eegfilt(f,Fs,bandcuts(1),bandcuts(2),0,3*fix(Fs/bandcuts(1)),1,'firls',0);
    else
        ffiltered = eegfilt(f,Fs,bandcuts(1),bandcuts(2));
        
    end
end


if strcmp(lower(tipo),'iir')
    if isfield(params,'iirtype')
        iirtype = params.iirtype;
    else
        iirtype = 'butter';
    end
    if isfield(params,'order')
        Norder = params.order;
    else
        Norder = 10;
    end
    
    if bandcuts(1) ~=0 && bandcuts(2)~=0
        if Notchfilt
            dd = fdesign.bandstop('N,F3dB1,F3dB2',Norder,bandcuts(1),bandcuts(2),Fs);
        else
            dd = fdesign.bandpass('N,F3dB1,F3dB2',Norder,bandcuts(1),bandcuts(2),Fs);
        end
    else
        if bandcuts(1) ==0
            dd = fdesign.lowpass('N,F3dB',Norder,bandcuts(2),Fs);
        end
        
        if bandcuts(2) ==0
            dd = fdesign.highpass('N,F3dB',Norder,bandcuts(1),Fs);
        end
    end
    
    Hd = design(dd,iirtype);
    ffiltered = filtfilt(Hd.sosMatrix,Hd.ScaleValues,f);
    
end


end

