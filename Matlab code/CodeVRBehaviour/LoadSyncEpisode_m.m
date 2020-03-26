%% Load ThorSync Episode HDF5 file:
% Modified by MO to pass the filename as an optional parameter: 'filename', filename.
% - all will be exported to base workspace with unique names.
% - Attributes can be any combination of the following:
%   LoadSyncEpisode('start',1)      -- load after 1 second of data
%   LoadSyncEpisode('length',3)     -- load 3 seconds of data
%   LoadSyncEpisode('interval',0.1) -- load data with gap of 0.1 second
% --- Copyright (c) 2014, Thorlabs, Inc. All rights reserved. ---

%% Copyright (c) 2014, Thorlabs, Inc. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function LoadSyncEpisode_m(varargin)
if ~isempty(varargin) && any(cell2mat(cellfun(@(x) strcmpi(x,'filename'),varargin,'UniformOutput',false)))
  IdxCell = find(cell2mat(cellfun(@(x) strcmpi(x,'filename'),varargin,'UniformOutput',false)))+1;
  [pathstr,name,ext] = fileparts(varargin{IdxCell});
  filename = [name, ext];
  pathname = [pathstr, filesep];
  varargin = varargin([1:IdxCell-2 (IdxCell+1):end]);
  clear pathstr name ext IdxCell
else
  % Select one h5 file:
  [filename, pathname] = uigetfile('*.h5', 'Pick a Sync Episode file');
  if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
    return    
  end
end
disp(['User selected ', fullfile(pathname, filename)])
%% Load params from XML:
clockRate = 20000000;
sampleRate = LoadSyncXML(pathname);

%% Start loading HDF5:
pathandfilename = strcat(pathname,filename);
info = h5info(pathandfilename);

%% Parse input:
props = {'start','length','interval'};
data = {[1,1],[1 Inf],[1 1]};

if(~isempty(varargin))
  assert(rem(length(varargin),2)==0 && iscellstr(varargin(1:2:end)), 'Inputs failed to conform to expected string-value pair format, eg> ''start'',1');
  %foundProps = intersect(varargin(1:2:end), props);
  IdxCell = cellfun(@(x) strcmpi(x,props),varargin(1:2:end),'UniformOutput',false);
  val = double(cell2mat(varargin(2:2:end)))*sampleRate;
  for i=1:length(val)
    data{cell2mat(IdxCell(i))>0} = [1 val(i)];
  end
end

%% Read HDF5:

for j=1:length(info.Groups)
  for k = 1:length(info.Groups(j).Datasets)
    %datasetPath = strcat(info.Groups(j).Name,'/',info.Groups(j).Datasets(k).Name);
    %Mush, 29/12/2016, strcat removes any trailing white spaces, which is not what we want here
    datasetPath = [info.Groups(j).Name,'/',info.Groups(j).Datasets(k).Name];
    
    datasetName = info.Groups(j).Datasets(k).Name;
    datasetName(isspace(datasetName))='_';
    datasetValue = h5read(pathandfilename,datasetPath,data{1},data{2},data{3})';
    % load digital line in binary:
    if(strcmp(info.Groups(j).Name,'/DI'))
      datasetValue(datasetValue>0) = 1;
    end
    % create time variable out of gCtr,
    % account for 20MHz sample rate:
    if(strcmp(info.Groups(j).Name,'/Global'))
      datasetValue = double(datasetValue)./clockRate;
      datasetName = 'time';
    end
    assignStr = UniqueName(datasetName);
    assignin('base',assignStr,datasetValue);
  end
end

end


function outStr = UniqueName(str)
%% Generate unique name for variable to be exported.

cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
vars = evalin('base','who');
index = 1;
unique = false;
cmpStr = str;

while (~unique)
  ret = cellfun(cellfind(cmpStr),vars);
  if(~any(ret))
    outStr = cmpStr;
    unique = true;
  else
    cmpStr = strcat(str,num2str(index,'%03d'));
    index=index+1;
  end
end

end