%find central line
function vesselcentralline=find_central_line_func(vessel)
BW = bwmorph(vessel,'skel',Inf);
vesselcentralline=uint8(BW)*255;

B = bwmorph(BW, 'branchpoints');
E = bwmorph(BW, 'endpoints');
[y,x] = find(E);
B_loc = find(B);
Dmask = false(size(BW));
for k = 1:numel(x)
    D = bwdistgeodesic(BW,x(k),y(k));
    distanceToBranchPt = min(D(B_loc));
    if distanceToBranchPt<=10%this branch is a small branch that should be removed.
    Dmask(D < distanceToBranchPt) =true;
    end
end
vesselcentralline = vesselcentralline - uint8(Dmask)*255;

vesselcentralline=vesselcentralline.*uint8(bwareaopen(vesselcentralline,5));
            
% imshow(vesselcentralline);
% hold all;
% [y,x] = find(B); plot(x,y,'ro')       
% close all;
% ar=vesselcentralline;
% lhmap=uint8(ar);

