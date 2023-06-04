% 2021.03.29 - P.Kusk
% Extracting tiff and meta-data from lif
Exp_Path = 'F:\03-AstroState';
Exp_dir = dir([Exp_Path '\*.lif']);

% Input Paramters
tiff_path = [];%'MetaOnly';% Leave open or supply path for tiff stack output. input 'MetaOnly' for only the metadata sheets.
series_idx = []; % indicate which series you wish to extract, leave open for all.
binning = 0.5; % how much you wish to avg. bin the outputtet tiffs from the lif

% Iterative lif processing
for ii = 1:length(Exp_dir)
    lif_path = [Exp_dir(ii).folder '\' Exp_dir(ii).name];
    bf_lif2tiff(lif_path,tiff_path,series_idx,binning);
end