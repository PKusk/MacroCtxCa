%% Combined PCA & JADE ICA function
function [ICA_coeff_3D,ICA_score,PCA_coeff_3D,PCA_score,explained] = PK_PCA_ICA(image_data)
% [ICA_coeff_3D,ICA_score,PCA_coeff_3D,PCA_score,explained] = PK_PCA_ICA(image_data)
% 2023.05.06 - P.Kusk attempt at performing functional parcellation of
% wide-field Ca2+ data. Function takes in an image stack and
% outputs both PCAs and ICAs with scores for each based on the JADE
% algorithm, including variance explained fro each component.

% This code is a combined adaptation from Mauro DiNuzzo's PCA analysis and ICA approach used by Makino et al 2017 (cren2333 github). 

% Reshape data for PCA compatability. Based on Mauro's GCaMP7 analysis
image_data = single(image_data); % convert to single precision

% Run PCA on reshaped image data, also based on Mauro's Analysis
fprintf('Principal component analysis ... ');
[width, height, frames] = size(image_data);
imdata_2d = reshape(image_data, [width*height, frames]);
imdata_2d = imdata_2d';
clear image_data;

numcomponents = 40; % This number of components is taken from Makino et al. 2017, Neuron.
[coeff_2d, score, ~, ~, explained, ~] = pca(imdata_2d, 'algorithm', 'svd', 'numcomponents', numcomponents, 'Rows', 'complete');
clear imdata_2d;

PCA_coeff_3D = single(reshape(coeff_2d, [width, height, numcomponents])); % Convert components back to 3D
PCA_score = score';
explained = explained(1:numcomponents); %
ModePCA = coeff_2d(:,1:numcomponents); % COEFF: Row: Pixel, Column: Component

% Plot
figure
%set(gcf,'color','k')
for mode = 1:40
    subaxis(4,10,mode, 'Spacing', 0.01, 'Padding', 0, 'Margin', 0.03);
    clims = [-0.04 0.04];
    image = ModePCA(:,mode);
    imagesc(reshape(image,[width height]),clims)
    colormap jet;
    axis square
    axis off
    title(['PCA' num2str(mode) ' ' num2str(explained(mode)) '%']);
end

figure, 
imagesc(score');
%caxis([-0.5 0.5])

% ICA algorithm: JADE, Cardoso, 2013, entropy
ModeICA = [];
SCORE_ICA_all = [];
B = jadeR(ModePCA'); % Input: Row: Mode, Column: Pixel; Get: B: Row: Independent Component(IC), Column: Component from PCA;
ModeICA = (B*ModePCA')'; % Get: ModeICA: Column: Independent Component(IC), Row: Pixel;
% Get temporal trace of each ICA mode
A = inv(B)'; % column: PCA, row: IC, each column: PCA project on IC;
SCORE_ICA_all = A*score(:,1:numcomponents)'; % Raw: ICA Component, Column: Frame
ICA_coeff_3D = single(reshape(ModeICA, [width, height, numcomponents])); % Convert components back to 3D
ICA_score = SCORE_ICA_all';
% plot
figure,
for mode = 1:40
    subaxis(4,10,mode, 'Spacing', 0.01, 'Padding', 0, 'Margin', 0.03);
    clims = [-3 10];
    image = ModeICA(:,mode);
    imagesc(reshape(image,[width height]),clims)
    colormap jet;
    axis square
    axis off
    title(['ICA' num2str(mode) ' ' num2str(explained(mode)) '%']);
end

figure
imagesc(zscore(SCORE_ICA_all))
end
