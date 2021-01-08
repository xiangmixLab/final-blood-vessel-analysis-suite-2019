% demo file for applying the NoRMCorre motion correction algorithm on 
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org


clear;
gcp;
%% read data and convert to double
[filename, filepath] = uigetfile('*.tif','Select Template');
templatename= [filepath,filename];
template_test1=imread(templatename);
[filename, filepath] = uigetfile('*.tif','Select Video');
name = [filepath,filename];
[savename,savepath]=uiputfile('*.avi','Save video as');
%addpath(genpath('../../NoRMCorre'));
Yf1 = read_file(name);

template_test=greedy_contrast_enhancement_java(template_test1,2);
Yf=Yf1*0;
tic;
for i1=1:size(Yf1,3)
    Yf(:,:,i1)=greedy_contrast_enhancement_java(squeeze(Yf1(:,:,i1)),2);
    disp(num2str(i1))
end
toc;

Yf = single(Yf);
[d1,d2,T] = size(Yf);

%% perform some sort of deblurring/high pass filtering

if (0)    
    hLarge = fspecial('average', 40);
    hSmall = fspecial('average', 2); 
    for t = 1:T
        Y(:,:,t) = filter2(hSmall,Yf(:,:,t)) - filter2(hLarge, Yf(:,:,t));
    end
    %Ypc = Yf - Y;
    bound = size(hLarge,1);
else
    gSig = 5; %%original 7
    gSiz = 60; %%original 17
    psf = fspecial('gaussian', round(gSiz), gSig);
    ind_nonzero = (psf(:)>=max(psf(:,1)));
    psf = psf-mean(psf(ind_nonzero));
    psf(~ind_nonzero) = 0;   % only use pixels within the center disk
    %Y = imfilter(Yf,psf,'same');
    %bound = 2*ceil(gSiz/2);
    Y = imfilter(Yf,psf,'symmetric');
    Y(Y<0)=0;
    bound = 0;
end
%% first try out rigid motion correction
    % exclude boundaries due to high pass filtering effects
options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',200,'max_shift',20,'iter',1,'correct_bidir',false);
options_r.upd_template=false;

%% register using the high pass filtered data and apply shifts to original data
tic; [M1,shifts1,template1] = normcorre_batch(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r,template_test); toc % register filtered data
    % exclude boundaries due to high pass filtering effects
tic; Mr = apply_shifts(Yf1,shifts1,options_r,bound/2,bound/2); toc % apply shifts to full dataset
    % apply shifts on the whole movie
%% save video as .avi file
n = size(Yf);
framenumber = n(3);

sav=[savepath,savename];
aviobj = VideoWriter(sav,'Grayscale AVI');
aviobj.FrameRate=20;

open(aviobj);
for i=1:T
    frame=uint8(Mr(:,:,i));
    writeVideo(aviobj,frame);
end
close(aviobj);