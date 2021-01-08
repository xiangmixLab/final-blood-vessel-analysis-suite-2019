function [velomap,BScan,lines]=MiniscopeFlowQuantification_adjusted_automatic(vid,lineProfile,Fs)
% Input variables
% NumProfiles = 1;   % Number of line profiles for user to draw to extract speed estimate
velomap=zeros(size(vid,1),size(vid,2));
FrameRate = Fs;
NumFrames = size(vid,3);

%% User selects desired line profile from image #1 of sequence
% figure(1);   % Open figure window
% imagesc(vid(:,:,1));   % Display image #1
% colormap(gray);   % Show as grayscale image
% [CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates

for tk=1:length(lineProfile)
    disp(['start processing line ',num2str(tk)])
    disp('start generate BScan image');
    %% Extract B-mode "image" from data
    NumPoints = length(lineProfile{tk}(:,1));   % Determine the number of points in the drawn line
    BScan = zeros(NumPoints,NumFrames);   % Create matrix that will contain the B-mode "image" of the data

    for i = 1:NumFrames
        frame=squeeze(vid(:,:,i));
        intensity_profile=[];
        for j=1:length(lineProfile{tk}(:,1))
            intensity_profile(j)=frame(lineProfile{tk}(j,2),lineProfile{tk}(j,1));
        end
        BScan(:,i) = intensity_profile;   % Draw a line profile in the exact position that was drawn, and store line profile as one column in BSCAN
        BScan(:,i)=imadjust(BScan(:,i)*1/max(BScan(:,i)));
    end
    %% Display data

   disp('start estimating lines from BScan');
   NumProfiles=1;
   slope=[0];
   for i = 1:NumProfiles
        figure(2)
        BW=imbinarize(BScan,'adaptive');
        imagesc(BW);
        colormap(gray);
        titletext = ['Draw line profile # ',num2str(i),' of ',num2str(NumProfiles)];
        title(titletext)
        [CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates
        if ~isempty(yi)&&~isempty(xi)
            slope(i) = [yi(2)-yi(1)]/((xi(2)-xi(1))/FrameRate); % Calculate slope of line drawn [pixels/s]
        end
   end
        

    % Calculate/display flow speed
    fprintf('The speed of flow along the line drawn is %0.3e pixels/s\n\n',median(slope))
    velomap(lineProfile{tk}(:,2),lineProfile{tk}(:,1))=median(slope);
end

se=strel('disk',5);
velomap=imdilate(velomap,se);
velomap=imgaussfilt(velomap,2);
