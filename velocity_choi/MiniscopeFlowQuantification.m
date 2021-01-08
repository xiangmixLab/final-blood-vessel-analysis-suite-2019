clear all

% Input variables
videofile = 'b2m3_miniscope.avi';   % Video file name
NumProfiles = 1;   % Number of line profiles for user to draw to extract speed estimate

% Extract frame rate and number of frames from video
v = VideoReader(videofile);
FrameRate = v.FrameRate;
NumFrames = v.NumberOfFrames;

%% User selects desired line profile from image #1 of sequence
v = VideoReader(videofile);  % Rewind video file to beginning
video = readFrame(v);   % Read first frame
[numrows,numcols,colordepth] = size(video);   % Get dimensions of image
if colordepth == 3   % If the image is RGB
    grayVideo = rgb2gray(video);   % Convert frame from RGB to grayscale
else   % Image is grayscale
    grayVideo = video;
end
figure(1);   % Open figure window
imagesc(grayVideo);   % Display image #1
colormap(gray);   % Show as grayscale image
[CX,CY,C,xi,yi] = improfile;   % Allow user to draw a line in the image and extract values along line and specific coordinates

% Rewind video file to beginning
v = VideoReader(videofile);

%% Extract B-mode "image" from data
NumPoints = length(C);   % Determine the number of points in the drawn line
BScan = zeros(NumPoints,NumFrames);   % Create matrix that will contain the B-mode "image" of the data

for i = 1:NumFrames;
    video = readFrame(v);   % Read  frame
    if colordepth == 3   % If the image is RGB
        grayVideo = rgb2gray(video);   % Convert frame from RGB to grayscale
    else   % Image is grayscale
        grayVideo = video;
    end
    BScan(:,i) = improfile(grayVideo,xi,yi);   % Draw a line profile in the exact position that was drawn, and store line profile as one column in BSCAN
end

%% Display data
figure(2)
imagesc(BScan);
colormap(gray);

% User selects three line profiles in B-mode "image"
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


