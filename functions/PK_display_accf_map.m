function  h = PK_display_accf_map(image,mask,accf_coords)

image(~mask) = nan;
h = imagesc2(image);
for ll = 1:length(accf_coords)
    active_coords = accf_coords{ll};
    if isempty(active_coords)
        continue
    else
    hold on
    plot(active_coords(:,2),active_coords(:,1),'color',[0.5 0.5 0.5])
    end
end

end