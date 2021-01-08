function [vessel_color]=generate_velo_colormap(acontrast2,velomap,vessel,velorange)
vessel_color(:,:,1)=acontrast2;
vessel_color(:,:,2)=acontrast2;
vessel_color(:,:,3)=acontrast2;

cmap=colormap(jet);
velomap1=velomap+1;

se1=strel('disk',2);
velomap1=imdilate(velomap1,se1);

max_velo=max(velomap1(:));
if ~isempty(velorange)
    max_velo=max(velorange);
    velomap1(velomap1>=max_velo)=max_velo;
end

velomap1=imgaussfilt(velomap1,8,'FilterSize',[25 25]);
velomap1=imerode(velomap1,se1);

% velomap1(vessel)=velomap1(vessel)+1; % make the parts in vessel all have color
velomap1=round(velomap1*size(cmap,1)/max(velomap1(:)));
velomap1(velomap1==0)=1;


    
for i=1:size(vessel_color,1)
    for j=1:size(vessel_color,2)
        if vessel(i,j)>0
            vessel_color(i,j,:)=cmap(round(velomap1(i,j)),:)*255;
        else
        end
    end
end



