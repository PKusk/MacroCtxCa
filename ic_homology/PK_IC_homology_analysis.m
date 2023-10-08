%% ICA Homology analysis

% Find and load all IC pipeline outputs
data_path = '\\sund.root.ku.dk\groups\CTN\NedergaardLAB\Personal_folders\Peter Kusk\10. AstroState\PAS-EXP-Oddball\Thy1-G6s-IP3R2KO\2022-10-Batch\awake_1s';
data_dirs = dir([data_path '\*\*\PK_PCA-ICA.mat']);

%% Load each analysis struct, extract IC's and annotation and reshape to 1D
combined_ICs =  []; combined_scores = []; combined_IC_names =  []; combined_mouse_ids = []; combined_mouse_genotype = [];
for ii = 1:length(data_dirs)
    data = load([data_dirs(ii).folder '\' data_dirs(ii).name]);
    mouse_id = extractBetween(data_dirs(ii).folder ,'awake_1s\','\PK2023_MacroAnalysis');
    mouse_genotype = extractBetween(mouse_id,'(',')');
    mouse_genotype = repmat(mouse_genotype,40,1);
    mouse_id = repmat(mouse_id,40,1); 
    ICA_coeff = data.PK.ICA.coeff;
    [w,h,n] = size(ICA_coeff);
    IC_1D = reshape(ICA_coeff,w*h,n);
    combined_ICs = cat(2,combined_ICs,IC_1D);
    
    accf_table = data.PK.ACCF.ScoreTable;
    IC_name =accf_table.CtxAbbrev;
    combined_IC_names = cat(1,combined_IC_names,IC_name);
    combined_mouse_ids = cat(1,combined_mouse_ids,mouse_id);
    combined_mouse_genotype = cat(1,combined_mouse_genotype,mouse_genotype);
    
    ICA_score = data.PK.ICA.score;
    combined_scores = cat(2,combined_scores,ICA_score);
end
%% Cluster similiar spatial components 
Y_ICs = tsne(combined_ICs'); % t-SNE extraction
[k_idx,C,sumd] = kmeans(Y_ICs,35); % kmeans clustering

% Plot t-SNE dimensions with mouse labels and with Ctx labels
f1=figure('Position',[1 41 1920 963]);
subplot(2,2,1)
gscatter(Y_ICs(:,1),Y_ICs(:,2),combined_IC_names)
hLegend = findobj(gcf, 'Type', 'Legend');
hLegend.NumColumns = 2;
hLegend.Box = 'off';
hLegend.Location = 'bestoutside';
%legend('boxoff','Orientation','horizontal');
axis off
subplot(2,2,2)
gscatter(Y_ICs(:,1),Y_ICs(:,2),combined_mouse_ids)
legend('Location','bestoutside')
legend('boxoff')
axis off
subplot(2,2,4)
gscatter(Y_ICs(:,1),Y_ICs(:,2),combined_mouse_genotype)
legend('Location','bestoutside')
legend('boxoff')
axis off

subplot(2,2,3)
% Plot k-means clusters with the cluster sum annotions
qual_colors = cbrewer('qual','Set1',35,'linear');
%f2=figure('Position',[148 274 969 673]);
for ii = 1:length(C)
    scatter(Y_ICs(k_idx==ii,1),Y_ICs(k_idx==ii,2),20,qual_colors(ii,:),'filled')
    hold on
    plot(C(ii,1),C(ii,2),'kx','MarkerSize',15,'LineWidth',1)
    text(C(ii,1)+0.2,C(ii,2),num2str(sumd(ii)), 'FontSize', 8) % sumd or ii
end
axis off
%%
% Find most conserved ICs by finding clusters with observations equal to
% +/-1 of number of animals supplied to analysis and sort based on smallest
% cluster sum of distance.
[sumd_sorted,sumd_sorted_idx]=sort(sumd);
[GC,GR] = groupcounts(k_idx); 
sorted_GC = GC(sumd_sorted_idx);
sorted_GR = GR(sumd_sorted_idx);
size_selected_clusters = sorted_GR((length(data_dirs)-2)<sorted_GC&sorted_GC<(length(data_dirs)+2));

for jj = 1:length(size_selected_clusters)
    
    aa = combined_ICs(:,k_idx==size_selected_clusters(jj));
    raa = reshape(aa,w,h,size(aa,2));
    ic_id = combined_IC_names(k_idx==size_selected_clusters(jj));
    m_id = combined_mouse_ids(k_idx==size_selected_clusters(jj));
    
    ax(1)=figure('Position',[1 41 1920 963]);
    for ii = 1:size(raa,3)
        subplot(3,8,ii)
        imshow(raa(:,:,ii))
        title([m_id{ii} '/' ic_id{ii}])
    end
    ax(2)=subplot(3,8,[9 24]);
    stackedplot(zscore(combined_scores(:,k_idx==size_selected_clusters(jj))))
    %caxis([-4 4])
    %yticklabels(m_id)
    
    active_cluster_scores = combined_scores(:,k_idx==size_selected_clusters(jj));
%     ax(3)=subplot(5,8,[33 40]);
%     hold on
%     imagesc((data.PK.TemporalScoring.ScoringTrace),'AlphaData',0.3)
%     yl = ylim();
%     plot(rescale(mean(zscore(active_cluster_scores(:,contains(m_id,'KO'))),2)',yl(1),yl(2)),'r')
%     plot(rescale(mean(zscore(active_cluster_scores(:,contains(m_id,'WT'))),2)',yl(1),yl(2)),'b')
%     ylim(yl)
%     xlim([1 12000])
    
    colormap(ax(1),inferno)
   % colormap(ax(2),dopeassbluered)
%     colormap(ax(3),flipud(gray))
end