%Filtering and enhancement
function [acontrast2,ai2,acontrast2_saturned]=Filter_and_Enhancement_func(a1,saturn_fix)

[height,width,leng]=size(a1);
ai1=zeros(height,width,leng);
ai2=zeros(height,width,leng);
tic

for i=1:leng
    ai1(:,:,i)=double(a1(:,:,i));
end

%% gaussian filtering spatial
for i=1:leng
    ai1(:,:,i)=imgaussfilt(squeeze(ai1(:,:,i)));
end

%% adjust illumination
grand_mean=mean(ai1(:));
grand_std=std(ai1(:));
for i=1:leng
    frame_temp=squeeze(ai1(:,:,i));
    frame_temp=(frame_temp-mean(frame_temp(:)))/std(frame_temp(:));
    frame_temp=(frame_temp+grand_mean)*grand_std;
    ai1(:,:,i)=frame_temp*1/max(frame_temp(:));
end


%% smooth in time
% for i=1:size(ai1,1)
%     for j=1:size(ai1,2)
%         t=squeeze(ai1(i,j,:));
%         t=smooth(t,'sgolay');
%         ai2(i,j,:)=t;
%     end
% end

%% baseline motion artifacts removal

%% thresholding along time

%% histogram equalization and enhance
for i=1:leng
    t=squeeze(ai1(:,:,i))*1/max(max(ai1(:,:,i)));
    ai2(:,:,i)=imadjust(t);
    ai2(:,:,i)=ai2(:,:,i)*255/max(max(ai2(:,:,i)));
end


%% calculate std
acontrast2=zeros(height,width);
amin2=min(double(ai2)*1/255,3);

acontrast2_saturned=acontrast2;
for i=1:height
    for j=1:width
        acontrast2(i,j)=std(ai2(i,j,:));
%         acontrast2(i,j)=mean(ai2(i,j,:));
        if mean(ai2(i,j,:))>250&&saturn_fix==1
            acontrast2_saturned(i,j)=mean(mean(amin2(i-2:i+2,j-2:j+2)));
        end
    end
end

acontrast2=uint8(acontrast2*255/max(acontrast2(:)));
acontrast2_saturned=acontrast2_saturned*max(double(acontrast2(:)))/max(acontrast2_saturned(:));
acontrast2(acontrast2_saturned>0)=acontrast2_saturned(i,j);

acontrast2=adapthisteq(acontrast2);
acontrast2=medfilt2(acontrast2);

ai2=uint8(ai2);
toc
