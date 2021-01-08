function [lineProfile]=split_central_lines(cen_line,part_length,interval)
%split central lines
crossings = bwmorph(cen_line, 'branchpoints');
se=strel('disk',1);
crossings = imdilate(crossings,se);

%cen line modify
cen_line([1:6,end-6:end],[1:6,end-6:end])=0;
%get individual line pixel locations
cen_line_split=double(cen_line).*double(~crossings);
statss=regionprops(logical(cen_line_split),'PixelList');

lineProfile={};
lineProfile1={};
ctt=1;
for i=1:length(statss)

    %find how to sort the list
    plist=statss(i).PixelList;
    uni_x=unique(plist(:,1));
    uni_y=unique(plist(:,2));
    if length(uni_x)>=length(uni_y)
        plist=sortrows(plist,1);
    else
        plist=sortrows(plist,2);
    end
    if size(plist,1)>part_length      
        for j=1:interval:size(plist,1)-part_length
            lineProfile{ctt}=plist(j:j+part_length,:);
            ctt=ctt+1;
        end
    else
        lineProfile{ctt}=statss(i).PixelList;
        ctt=ctt+1;
    end      
end

rm_idx=zeros(length(lineProfile),1);
for i=1:length(lineProfile)
    if size(lineProfile{i},1)<25 % remvoe too short segments , min speed detect 25*30=750um/sec
        rm_idx(i)=1;
    end
end

lineProfile=lineProfile(~rm_idx);