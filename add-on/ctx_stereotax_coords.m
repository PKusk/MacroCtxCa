function [user_ML,user_AP] = ctx_stereotax_coords(user_ML,user_AP)
 % 2023.03.11 P.Kusk @CTN 
 % Function that allows either output of mouse cortex atlas coordinates
 % based on clicked points or gives an overview of input coordinates.
 % Multiple coordinates can be inputted. Code generated from the UCL cortex
 % lab GitHub.
 
ccfbregma = [540 0 570]/100;
load('data\ctxOutlines.mat');
CtxOutlineNames = load('data\CtxOutlineNamesHemiIndication.mat');
CtxOutlineNames.CtxOutlinesAnnotation.CtxAbbrev{29} = 'AUDv(L)_1';
CtxOutlineNames.CtxOutlinesAnnotation.CtxAbbrev{30} = 'AUDv(R)_1';

switch nargin
    case 1
        figure,
        hold on;
        for q = 1:numel(coords) % coords is from ctxOutlines.mat
            cx = coords(q).x/100;
            cy = coords(q).y/100;
            cx = cx-ccfbregma(3); cy = cy-ccfbregma(1);
            theta = 180;
            T = [cosd(theta) -sind(theta) 0; ...
                sind(theta)  cosd(theta) 0; ...
                0           0  1];
            
            newc = T*[cx cy ones(size(cx))]';
            cx = newc(1,:)'; cy = newc(2,:)';
            plot(cx,cy, 'LineWidth', 1.0, 'Color', [0.5 0.5 0.5 0.8]);
            ylim([-6 4]);
            hold on;
            box on
            grid on
        end
        [user_ML,user_AP] = ginput();
        close gcf
    case 2
    otherwise
        user_ML = []; user_AP = [];
end

figure('Position',[66 297 1770 569]);
subplot(1,2,2)
hold on;
coordinates = {};
for q = 1:numel(coords) % coords is from ctxOutlines.mat
    % these are in 10um voxel coordinates, so first convert to mm, then to pixels
    cx = coords(q).x/100;
    cy = coords(q).y/100;
    
    % to do this transformation, first subtract bregma to zero, then rotate, then add back the other bregma
    cx = cx-ccfbregma(3); cy = cy-ccfbregma(1);
    
    theta = 180;
    T = [cosd(theta) -sind(theta) 0; ...
        sind(theta)  cosd(theta) 0; ...
        0           0  1];
    
    newc = T*[cx cy ones(size(cx))]';
    cx = newc(1,:)'; cy = newc(2,:)';
    
    plot(cx,cy, 'LineWidth', 1.0, 'Color', [0.5 0.5 0.5 0.8]);
    ylim([-6 4]);
    hold on;
    coordinates{q} = [cx, cy];
    box on
    grid on
    xticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]);
    ylabel('Anteroposterior distance from Bregma (mm)')
    xlabel('Mediolateral distance from Bregma (mm)')
end

if isempty(user_ML)
else
    scatter(user_ML,user_AP,[],'r','filled');
    for tt = 1:length(user_ML)
        text(user_ML(tt),user_AP(tt)+0.2,['M/L: ' num2str(user_ML(tt)) ', A/P: ' num2str(user_AP(tt))],'Color','r','FontSize',8)
    end
    
end

subplot(1,2,1)
hold on
for ri = 1:60
    region_index = CtxOutlineNames.CtxOutlinesAnnotation.CtxAbbrev{ri};
    region_coordinates = coordinates{ri};
    plot(region_coordinates(:,1),region_coordinates(:,2), 'LineWidth', 1.0, 'Color', [0.5 0.5 0.5 0.8]);
    ylim([-6 4]);
    mean_coordinates = mean(region_coordinates, 1);
    mean_coordinates_collector(ri,:) = mean_coordinates;
    if isempty(user_ML)
    else
        in = inpolygon(user_ML,user_AP,region_coordinates(:,1),region_coordinates(:,2));
        if numel(user_ML(in))~=0
            fill(region_coordinates(:,1),region_coordinates(:,2),'r','FaceAlpha',0.3,'EdgeColor','none')
            mean_coordinates_collector(ri,:) = mean_coordinates;
            if ri == 8
                text(mean_coordinates(1), mean_coordinates(2)+1.5, region_index, ...
                    'Color','k','FontSize',8, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle');
                
            else
                text(mean_coordinates(1), mean_coordinates(2), region_index, ...
                    'Color','k','FontSize',8, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle');
            end
        else
            continue
        end
    end
    if ri == 8
        text(mean_coordinates(1), mean_coordinates(2)+1.5, region_index, ...
            'Color','k','FontSize',8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
        
    else
        text(mean_coordinates(1), mean_coordinates(2), region_index, ...
            'Color','k','FontSize',8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
    end
end
axis off
end
