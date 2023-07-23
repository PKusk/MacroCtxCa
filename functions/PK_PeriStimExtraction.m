function PeriStimSegments = PK_PeriStimExtraction(data,idx,window,dim)

PeriStimSegments = [];
for ii = 1:length(idx)
    switch dim
        case 1
            segment =  data(idx(ii)-window(1):idx(ii)+window(2),:);
        case 2
            segment =  data(:,idx(ii)-window(1):idx(ii)+window(2));
        case 3
            segment = data(:,:,idx(ii)-window(1):idx(ii)+window(2));
        otherwise
            disp('Please input dimension to extract across..')
    end
    PeriStimSegments = cat(dim+1,PeriStimSegments,segment);
end
PeriStimSegments = squeeze(PeriStimSegments);
end