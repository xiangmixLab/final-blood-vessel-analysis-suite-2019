function [velomap]=MiniscopeFlowQuantification_adjusted(vid,Fs)
% Input variables
NumProfiles = 1;   % Number of line profiles for user to draw to extract speed estimate

FrameRate = Fs;
NumFrames = size(vid,3);

%% User selects desired line profile from image #1 of sequence
figure(1);   % Open figure window
imagesc(vid(:,:,1));   % Display image #1
colormap(gray);   % Show as grayscale image
[CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates

%% Extract B-mode "image" from data
NumPoints = length(C);   % Determine the number of points in the drawn line
BScan = zeros(NumPoints,NumFrames);   % Create matrix that will contain the B-mode "image" of the data

for i = 1:NumFrames
    frame=squeeze(vid(:,:,i));
    BScan(:,i) = improfile(frame,xi,yi);   % Draw a line profile in the exact position that was drawn, and store line profile as one column in BSCAN
end

%% Display data
figure(2)
imagesc(BScan);
colormap(gray);

%% User selects line profiles in B-mode "image"
for i = 1:NumProfiles
    figure(2)
    imagesc(BScan);
    colormap(gray);
    titletext = ['Draw line profile # ',num2str(i),' of ',num2str(NumProfiles)];
    title(titletext)
    [CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates
    slope(i) = [yi(2)-yi(1)]/((xi(2)-xi(1))/FrameRate); % Calculate slope of line drawn [pixels/s]
end
        
% Calculate/display flow speed
fprintf('The speed of flow along the line drawn is %0.3e pixels/s\n\n',median(slope))


