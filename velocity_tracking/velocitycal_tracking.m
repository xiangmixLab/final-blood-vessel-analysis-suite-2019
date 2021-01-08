%% velocitycal_tracking
vessel_parts=bwlabel(vessel);
if splitVessel==1
    vesc1=vesselcentralline;
    vesc1_bp = bwmorph(vesc1,'branchpoints');
    vesc1(vesc1_bp)=0;
    vessel_cline_parts=bwlabel(vesc1);
    vessel_parts=zeros(size(vessel));
    idx_c=unique(vessel_cline_parts);
    idx_c=idx_c(2:end);
    ct=1;
    for ip=1:length(idx_c)
        vc_inf_current=unique(vessel_cline_influence(vessel_cline_parts==ip));
        vc_inf_current=vc_inf_current(2:end);
        for u=1:size(vessel_cline_influence1,1)
            for v=1:size(vessel_cline_influence1,2)
                if ~isempty(find(vc_inf_current==vessel_cline_influence1(u,v)))
                    vessel_parts(u,v)=ct;
                end
            end
        end
        ct=ct+1;
    end
    se=strel('disk',8);
    vessel_parts=imclose(vessel_parts,se);
end

max_velo=25;
velocity=ai5*0;
velocity_dir=ai5*0;
% sz=50;
tic;
% for i191=1:sz:size(ai5,1)-sz
%     for j191=1:sz:size(ai5,2)-sz        
%         patch=ai5(i191:i191+sz-1,j191:j191+sz-1,:);
idx=unique(vessel_parts);
idx=idx(2:end);
for vp=1:length(idx)
    maskk=vessel_parts==vp;
        patch=double(ai5);
        for vp1=1:leng
            patch(:,:,vp1)=squeeze(patch(:,:,vp1)).*maskk;
        end
        alltracks = MotionBasedMultiObjectTrackingExample_adapted(patch,directo);
        for z191=2:size(ai5,3)-1
            tracks1=alltracks{z191-1};
            tracks2=alltracks{z191};
            if ~isempty(tracks1)&&~isempty(tracks2)
                leng1=length(tracks1);
                leng2=length(tracks2);
                id1=zeros(1,leng1);
                id2=zeros(1,leng2);
                bbox1=cell(1,leng1);
                bbox2=cell(1,leng2);
                for j192=1:leng1
                    id1(j192)=tracks1(j192).id;
                    bbox1{j192}=tracks1(j192).bbox;
                end
                for j192=1:leng2
                    id2(j192)=tracks2(j192).id;
                    bbox2{j192}=tracks2(j192).bbox;
                end
                commonidx=intersect(id1,id2);
                ct=1;
                commonidx1=[];
                commonidx2=[];
                for i193=1:length(id1)
                    if ~isempty(find(commonidx==id1(i193)))
                        commonidx1(ct,1)=i193;
                        ct=ct+1;
                    end
                end
                ct=1;
                for i193=1:length(id2)
                    if ~isempty(find(commonidx==id2(i193)))
                        commonidx2(ct,1)=i193;
                        ct=ct+1;
                    end
                end
                for j192=1:length(commonidx1)
                    coor1=bbox1{commonidx1(j192)};
                    coor2=bbox2{commonidx2(j192)};
                    cen1=double([round(coor1(2)+coor1(4)/2) round(coor1(1)+coor1(3)/2)]);
                    cen2=double([round(coor2(2)+coor2(4)/2) round(coor2(1)+coor2(3)/2)]);
                    if cen1(1)>0&&cen1(1)<size(vessel,1)&&cen1(2)>0&&cen1(2)<size(vessel,2)&&cen2(1)>0&&cen2(1)<size(vessel,1)&&cen2(2)>0&&cen2(2)<size(vessel,2)&&vessel(cen1(1),cen1(2))>0&&vessel(cen2(1),cen2(2))>0
                        velo=sum((cen2-cen1).^2)^0.5;
%                         velodir=(cen2-cen1);
                        if velo<=max_velo
                        velocity(cen2(1),cen2(2),z191)=velo;
%                         velocity_dir(cen1(1),cen1(2),z191-1)=commonidx1(j192)+vp*1000;
                        velocity_dir(cen2(1),cen2(2),z191)=commonidx2(j192)+vp*1000;
                        end
                    end
                end
            end
            toc;
        end
%         toc;           
%     end
% end
end