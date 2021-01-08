%% velocity using kalman filter based tracking
function [velomap,velodir_map]=velocity_tracking_050120(rbc_vid_thresh,vessel,Fs)


velocity=rbc_vid_thresh*0;
velocity_dir=rbc_vid_thresh*0;
% sz=50;
tic;
% for i191=1:sz:size(ai5,1)-sz
%     for j191=1:sz:size(ai5,2)-sz        
%         patch=ai5(i191:i191+sz-1,j191:j191+sz-1,:);
alltracks = MotionBasedMultiObjectTrackingExample_050120(rbc_vid_thresh);

for z191=2:size(rbc_vid_thresh,3)-1
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
                velocity(cen2(1),cen2(2),z191)=velo/(1/Fs);
                dirr=cen2-cen1;
                velocity_dir(cen2(1),cen2(2),z191)=atan2d(dirr(2),dirr(1));
            end
        end
    toc;
    end
end

for i=1:size(velocity,1)
    for j=1:size(velocity,2)
        t1=squeeze(velocity(i,j,:));
        t2=squeeze(velocity_dir(i,j,:));
        t1(isnan(t1))=0;
        t2(isnan(t2))=0;
        velomap(i,j)=nanmean(t1(t1>0));
        velodir_map(i,j)=nanmean(t2(t2>0));
    end
end

velomap(isnan(velomap))=0;
velodir_map(isnan(velodir_map))=0;