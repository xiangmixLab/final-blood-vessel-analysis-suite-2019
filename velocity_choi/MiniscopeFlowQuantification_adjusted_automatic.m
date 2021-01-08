function [velomap,velodir_map]=MiniscopeFlowQuantification_adjusted_automatic(vid,lineProfile,Fs)
% Input variables
% NumProfiles = 1;   % Number of line profiles for user to draw to extract speed estimate
velomap=ones(size(vid,1),size(vid,2))*-1;
velodir_map=cell(size(vid,1),size(vid,2));

FrameRate = Fs;
NumFrames = size(vid,3);

%% zscore, flip dark area
for i=1:size(vid,3)
    t=squeeze(double(vid(:,:,i)));
    t=zscore(t);
    t=abs(t);
    vid(:,:,i)=uint8(t);
end
%% User selects desired line profile from image #1 of sequence
% figure(1);   % Open figure window
% imagesc(vid(:,:,1));   % Display image #1
% colormap(gray);   % Show as grayscale image
% [CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates
tic;
for tk=1:length(lineProfile)
    disp(['start processing line ',num2str(tk)])
    disp('start generate BScan image');
    %% Extract B-mode "image" from data
    C=length(improfile(squeeze(vid(:,:,1)),[lineProfile{tk}(1,1) lineProfile{tk}(end,1)],[lineProfile{tk}(1,2) lineProfile{tk}(end,2)]));
    NumPoints = C;   % Determine the number of points in the drawn line
    BScan = zeros(NumPoints,NumFrames);   % Create matrix that will contain the B-mode "image" of the data

    for i = 1:NumFrames
        frame=squeeze(vid(:,:,i));
%         intensity_profile=zeros(length(lineProfile{tk}(:,1)),1);
%         for j=1:length(lineProfile{tk}(:,1))
%             intensity_profile(j)=frame(lineProfile{tk}(j,2),lineProfile{tk}(j,1));
%         end
%         BScan(:,i) = intensity_profile;   % Draw a line profile in the exact position that was drawn, and store line profile as one column in BSCAN
        BScan(:,i)=improfile(frame,[lineProfile{tk}(1,1) lineProfile{tk}(end,1)],[lineProfile{tk}(1,2) lineProfile{tk}(end,2)]);
        BScan(:,i)=imadjust(BScan(:,i)*1/max(BScan(:,i)));
    end
    toc;
    %% Display data
    figure(2)
    imagesc(BScan);
    colormap(gray);

    disp('start estimating lines from BScan');

    %% Detect line profiles in B-mode "image" using 
%     BScan1=imadjust(BScan*1/255);
%     BScan1=double(imcomplement(BScan1));
    BScan1=imgaussfilt(BScan,[3 3]);
    BScan1=double(imcomplement(BScan1));
    imagesc(BScan1)
    BW=imbinarize(BScan1,'adaptive','Sensitivity',0.5);
    BW1=bwareaopen(BW,100);
    se=strel('disk',1);
    BW2 = imerode(logical(BW1),se);

    statss=regionprops(BW2,'Area','BoundingBox','Image','Orientation','PixelList');
%     BW1=statss(10).Image;
%     [H,theta,rho] = hough(BW1);
%     P = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
%     lines = houghlines(BW1,theta,rho,P,'FillGap',round(lineLength/2),'MinLength',lineLength);
% 
%     slope=[0];
%     for i = 1:length(lines)
%         slope(i) = [lines(i).point2(2)-lines(i).point1(2)]/((lines(i).point2(1)-lines(i).point1(1))/FrameRate); % Calculate slope of line drawn [pixels/s]
%     end
    
    lineLength=size(BScan,1)*0.25;
    slope=[0];
    idxx=[];
    ctt=1;
    for i = 1:length(statss)
        if statss(i).BoundingBox(4)>lineLength
            pixlist=statss(i).PixelList;
            pts_line_pt1=mean(pixlist(find(pixlist(:,2)<quantile(pixlist(:,2),0.2)),:),1);
            pts_line_pt2=mean(pixlist(find(pixlist(:,2)>quantile(pixlist(:,2),0.8)),:),1);

            slope(ctt) = ((pts_line_pt2(2)-pts_line_pt1(2))/(pts_line_pt2(1)-pts_line_pt1(1)))*FrameRate; %dy/(dx/Fs)=(dy/dx)*Fs
            idxx(ctt)=i;
            ctt=ctt+1;
        end        
    end
    toc;
    
    % Calculate/display flow speed
    num_positive=sum(slope>0);
    num_negative=sum(slope<0);
    if num_positive>num_negative
        slope(slope<0)=nan;
    else
        slope(slope>0)=nan;
    end

    slope(slope==inf)=[];
    slope(isnan(slope))=[];
    slope_p=abs(slope);
    
%     max_speed=size(BScan,1)/(1/FrameRate); % average car
%     slope_p(slope_p>max_speed)=nan;
    
    fprintf('The speed of flow along the line drawn is %0.3e pixels/s\n\n',nanmean(slope_p))
   
    
    for j=1:length(lineProfile{tk}(:,1))
        if ~isnan(nanmedian(slope_p))
            velomap(lineProfile{tk}(j,2),lineProfile{tk}(j,1))=nanmean(slope_p);
        else
            velomap(lineProfile{tk}(j,2),lineProfile{tk}(j,1))=nan;
        end
    end
    toc;
    line_vec=[lineProfile{tk}(end,1)-lineProfile{tk}(1,1),lineProfile{tk}(end,2)-lineProfile{tk}(1,2)];
    if nanmean(slope)>0
        velodir_map{lineProfile{tk}(round(size(lineProfile{tk},1)/2),2),lineProfile{tk}(round(size(lineProfile{tk},1)/2),1)}=-1*line_vec; %positive slope indicate flow from end to begining, vice versa
    else
        velodir_map{lineProfile{tk}(round(size(lineProfile{tk},1)/2),2),lineProfile{tk}(round(size(lineProfile{tk},1)/2),1)}=1*line_vec;
    end
end

velomap=fillmissing(velomap,'nearest');

se=strel('disk',10);
velomap=imdilate(velomap,se);
% velomap=imgaussfilt(velomap,2);
