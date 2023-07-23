data_path ='\\sund.root.ku.dk\groups\CTN\NedergaardLAB\Personal_folders\Peter Kusk\10. AstroState\PAS-EXP-Oddball\Thy1-G6s-IP3R2KO\2021-11-Batch\awake_1s\M142(WT)';
image_dir = dir([data_path '\raw\*UV-rdnt_miss-dvnt.tif']);
meta_dir = dir([data_path '\raw\*UV-rdnt_miss-dvnt_MetaData.xlsx']);
stim_dir = dir([data_path '\clampex\*UV-rdnt_miss-dvnt_VisStimIdx.xlsx']);

image_data = loadtiff([image_dir.folder '\' image_dir.name]);
meta_data = readtable([meta_dir.folder '\' meta_dir.name]);
dvnt_stims = readmatrix([stim_dir.folder '\' stim_dir.name],'Sheet',2,'Range','B:B');

mm_pr_pix =  (meta_data.PhysicalSizeX_um/1000)/meta_data.BinImageSizeX;
fs = meta_data.SeriesRealFrameRate;
%% Automatically generate mask of raw image and apply it.
[masked_image_data, mask] = PK_generate_automask(image_data);
figure, imagesc(mean(masked_image_data,3));

%clear image_data
%% Rotate and shift masked image stack to be centered around bregma and aligned along the midline.
[aligned_image_data, bregma, lambda] = PK_align_to_bregma_lambda(masked_image_data,[]);

figure, imagesc(mean(aligned_image_data,3));

[aligned_mask] = PK_align_to_bregma_lambda(mask, bregma, lambda);
aligned_mask(aligned_mask>0)=1; % making sure the mask is still binary. 

%clear masked_image_data
%% Generate custom croppped and aligned allen brain atlas cortical map for image stack 
[accf_coordinates, accf_regions] = PK_custom_ACCF_map(aligned_mask, mm_pr_pix);

%% Extract 40 first ICA components 
[ICA_coeff,ICA_score,PCA_coeff,PCA_score,explained]=PK_PCA_ICA(aligned_image_data);

%% Score ICA spatial components based on their affilition with ACCF regions
ICA_ACCF_map_table = [];
for ii = 1:size(ICA_coeff,3)
    [best_region_table] = PK_ACCF_map_score(ICA_coeff(:,:,ii),accf_regions);
    tii = table(ii,explained(ii),'VariableNames',{'ICA_Component', 'Explained_Var'});
    ii_table = [tii best_region_table];
    ICA_ACCF_map_table = [ICA_ACCF_map_table;ii_table];
end

%% Score ICA temporal components based on their activity 
    % Load time indices of interest as a 1D matrix
    dvnt_stims(isnan(dvnt_stims)) = [];
    dvnt_score_trace = PK_time_idx_to_score_trace(dvnt_stims,[0 30],[-1 1],size(aligned_image_data,3));
    
    zs_ICA_score = zscore(ICA_score');
    dvnt_scores = [];
    for ii = 1:size(zs_ICA_score,1)
    dvnt_score = mean(zs_ICA_score(ii,:).*dvnt_score_trace);
    dvnt_scores = [dvnt_scores; dvnt_score];
    end
    
    [on_score, on_score_idx] = sort(dvnt_scores,'descend');
    sorted_zs_ICA_score = zs_ICA_score(on_score_idx,:);
    sorted_ICA_coeff = ICA_coeff(:,:,on_score_idx);
    
%% Plot ICA spatial components /w custom ACCF map
fa = figure('Position',[1 1 1920 916]);
for ii = 1:size(ICA_coeff,3)
    subaxis(4,10,ii, 'Spacing', 0.01, 'Padding', 0, 'Margin', 0.03);
    PK_display_accf_map(sorted_ICA_coeff(:,:,ii),accf_regions,accf_coordinates);
    hold on
    best_fit_region = accf_coordinates{ICA_ACCF_map_table(on_score_idx(ii),:).RegionIdx};
    plot(best_fit_region(:,2),best_fit_region(:,1),'color','r','LineWidth',1.5)
    caxis([-3 10]);
    title({['ICA' num2str(on_score_idx(ii)) ' ' num2str(explained(on_score_idx(ii))) '%'],[ICA_ACCF_map_table(on_score_idx(ii),:).CtxAbbrev{:} ' ' num2str(ICA_ACCF_map_table(ii,:).BestScore)], ['dvnt' num2str(ii) ': ' num2str(round(on_score(ii),3))]});
    colormap inferno
end

fb = figure('Position',[1 1 1705 674]);
subplot(10,1,1)
imagesc(dvnt_score_trace);
colorbar
title('Idx Scoring Trace')
axis off
subplot(10,1,2:9)
imagesc(sorted_zs_ICA_score);
%xline(dvnt_stims,'k-','LineWidth',1);
colormap(dopeassbluered);
cb = colorbar;
cb.Label.String = 'zscore';
cb.Label.FontSize = 13;
box off
ylabel('Sorted temporal ICs');
xlabel('Time (frames)');
title('zscored & scoring sorted ICs')
caxis([-3 3])
%% Save analytical output i .mat struct

% Saving aligned and masked image stack as uint16;
saveastiff(uint16(aligned_image_data),[data_path '\MacroCtxCa\' image_dir.name(1:end-4) '_MA.tif']);

% Saving PCA, ICA & ACCF output in mat struct format.
PK.PCA.coeff = PCA_coeff;
PK.PCA.score = PCA_score;
PK.PCA.explained = explained;
PK.ICA.coeff = ICA_coeff;
PK.ICA.score = ICA_score;
PK.ACCF.coords = accf_coordinates;
PK.ACCF.map = accf_regions;
PK.ACCF.UserBregma = bregma;
PK.ACCF.UserLambda = lambda;
PK.ACCF.ScoreTable = ICA_ACCF_map_table;
PK.TemporalScoring.dvntIdx = dvnt_stims;
PK.TemporalScoring.dvntScores = dvnt_scores;
PK.TemporalScoring.ScoringTrace = dvnt_score_trace;
PK.MetaData = meta_data;
save([data_path '\MacroCtxCa\PK_PCA-ICA.mat'],'PK');

% Saving the ICA mapping image as .png
saveas(fa,[data_path '\MacroCtxCa\ICA_Maps.png'])
close fa
saveas(fb,[data_path '\MacroCtxCa\ICA_Raster.png'])
close fb
%% Plot PCA spatial components /w custom ACCF Map
% figure,
% for ii = 1:size(PCA_coeff,3)
%     subaxis(4,10,ii, 'Spacing', 0.01, 'Padding', 0, 'Margin', 0.03);
%     PK_display_accf_map(PCA_coeff(:,:,ii),accf_regions,accf_coordinates);
%     caxis([-0.02 0.02]);
%     colormap inferno
% end