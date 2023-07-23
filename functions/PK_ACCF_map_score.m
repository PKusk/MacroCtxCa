function [best_region_table] = PK_ACCF_map_score(image,accf_regions)

%im_mean=mean(image(accf_regions>0),[1,2]);
region_scores = []; score_map = [];
for ll = 1:max(accf_regions,[],[1,2])
    active_region = accf_regions==ll;
    %region_size = sum(active_region,[1,2]); % Contingency
    %SI = active_region.*image;
    score = mean((image(active_region)),[1,2]);
    %score = (mean_score/im_mean)*100; % percentage difference from mean pixel intensity.
    region_scores = [region_scores ;ll score];
    %area_score = active_region*score;
    %score_map = cat(3,score_map,area_score);
end
% to do: add contigency that if too areas or more have close scores include all
zscor_xnan = @(x) bsxfun(@rdivide, bsxfun(@minus, x, mean(x,'omitnan')), std(x, 'omitnan')); % stolen from https://se.mathworks.com/matlabcentral/answers/249566-zscore-a-matrix-with-nan
zscor_regions = zscor_xnan(region_scores(:,2)); % expressed in STD from mean of all regions (non NaNs)

% Determine the region with best score.
[best_score,best_region] = max(zscor_regions);
best_score_table = table(best_score,'VariableNames',{'BestScore'});

load('CtxOutlineNamesHemiIndication.mat');
best_region_annotation = CtxOutlinesAnnotation(best_region,:);
best_region_annotation = renamevars(best_region_annotation,"Var1","RegionIdx");
best_region_table = [best_score_table best_region_annotation]

end