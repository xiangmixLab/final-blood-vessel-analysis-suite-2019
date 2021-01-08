% demo file for applying the NoRMCorre motion correction algorithm on +
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org


clear;
gcp;
%% read data and convert to double

motion_correction_filenames;

for i10=[43:45]

foldername=templatename{i10}(1:strfind(templatename{i10},'MAX')-1);
mousename=templatename{i10}(strfind(templatename{i10},'MAX')+4:strfind(templatename{i10},'.tif')-1);

cd(foldername);
mkdir(mousename);
% [filename, filepath] = uigetfile('*.tif','Select Template');
templatename1= templatename{i10};
template_test1=imread(templatename1);
% template_test1=(template_test1-mean(template_test1(:)));
% template_test1=uint8(double(template_test1)*255./max(double(template_test1(:))));
% template_test=greedy_contrast_enhancement_java(template_test1,2);
template_test=template_test1;
% [filename, filepath] = uigetfile('*.tif','Select Video');
name = videoname{i10};
%addpath(genpath('../../NoRMCorre'));
Yf1 = read_file(name);
Yf=Yf1*0;

% tic
% for i1=1:size(Yf1,1)
%     for i2=1:size(Yf1,2)
%         Yfk=uint8(detrend(squeeze(double(Yf1(i1,i2,:)))));
%         Yf(i1,i2,:)=Yfk.*Yfk;
%     end
% end
% for i1=1:size(Yf1,3)
%     Yf(:,:,i1)=medfilt2(squeeze(Yf(:,:,i1)));
% end
% 
% template_test=mean(Yf,3);
% template_test=template_test*255/max(template_test(:));
% template_test=uint8(template_test);
% toc;

%contrast enhancement
tic;
% for i1=1:size(Yf,1)
%     for i2=1:size(Yf,2)
%         Yfk=(detrend(squeeze(double(Yf1(i1,i2,:)))));
%         if(max(Yfk(:)))<10
%             Yfk=Yfk*0;
%         end
% % % p(i1,i2)=max(Yfk(:));
% %         Yf(i1,i2,:)=uint8(Yfk*255/max(Yfk(:)));
%         Yf(i1,i2,:)=Yfk;
%     end
% end

% for i1=1:size(Yf1,3)
%     Yt=Yf1(:,:,i1);
%     Yf(:,:,i1)=greedy_contrast_enhancement_java(Yt,2);
% end
Yf=Yf1;
toc;

% Yf=Yf1;
% Yf1=Yf;Yf
Yf = single(Yf);
[d1,d2,T] = size(Yf);
% [savename,savepath]=uiputfile('*.avi','Save video as');
savepath=[pwd,'\',mousename,'\'];
savename=['NormCorre_result_',mousename,'.avi'];

flag=0;
maxshift=cell(30,16);
count=1;

after_process_correlation=zeros(7,5);

for i=2:8
    for j=2:6
% perform some sort of deblurring/high pass filtering
if (0)    
    hLarge = fspecial('average', 40);
    hSmall = fspecial('average', 2); 
    for t = 1:T
        Y(:,:,t) = filter2(hSmall,Yf(:,:,t)) - filter2(hLarge, Yf(:,:,t));
    end
    %Ypc = Yf - Y;
    bound = size(hLarge,1);
else
    gSig = i; %%original 7
    gSiz = round(i*j); %%original 17
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

% se = strel('disk', 8);
% template_test_1=imbinarize(template_test,'global');
% template_test_1=imopen(template_test_1,se);
% template_test_1=uint8(bwareaopen(template_test_1,1000))*255;
% stats = regionprops(template_test_1);
% centroid = stats(255).Centroid;
% template_test_1=template_test_1*0;
% template_test_1(round(centroid(2)),round(centroid(1)))=255;
% 
% 
% Y=Yf1*0;
% for i=1:size(Yf,3)
%     Yt=imbinarize(Yf1(:,:,i),'global');
%     Yt=imopen(Yt,se);
%     Yt=uint8(bwareaopen(Yt,1000))*255;
%     stats = regionprops(Yt);
%     centroid = stats(255).Centroid;
%     Yt=Yt*0;
%     Yt(round(centroid(2)),round(centroid(1)))=255;
%     Y(:,:,i)=Yt;
% end
% Y=single(Y);
% bound=0;
%% first try out rigid motion correction
    % exclude boundaries due to high pass filtering effects
options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',5,'max_shift',20,'iter',1,'correct_bidir',false);
options_r.upd_template=false;

%% register using the high pass filtered data and apply shifts to original data
tic; 
    [M1,shifts1,template1] = normcorre_batch(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r,template_test); toc % register filtered data
    % exclude boundaries due to high pass filtering effects
    tic; Mr = apply_shifts(Yf1,shifts1,options_r,bound/2,bound/2); toc % apply shifts to full dataset
    % apply shifts on the whole movie
    [cM1f,mM1f,vM1f] = motion_metrics(Mr,options_r.max_shift);

after_process_correlation(i-1,j-1)=mean(cM1f);
% figure;
% set(gcf,'outerposition',get(0,'screensize'));
% ButtonHandle = uicontrol('Style', 'PushButton', ...
%                          'String', 'Stop loop', ...
%                          'Callback', 'delete(gcbf)');
% for ik=1:1:size(Yf,3)
% subplot(1,2,1);
% imshow(uint8(Yf(:,:,ik)));
% drawnow;
% title(['original ', 'gSig=',num2str(gSig),' gSiz=',num2str(gSiz)]);
% subplot(1,2,2)
% drawnow;
% imshow(uint8(Mr(:,:,ik)));
% title('corrected');
% xlabel(num2str(ik));
% if ~ishandle(ButtonHandle)
%     break;
% end
% end
% close all;
% satif=input('satified? y/n:','s');
% if satif=='y'
%     break
% end
% Mr1=uint8(Mr);
% % se = strel('disk', 4);
% centroid=zeros(size(Mr1,3),2);
% for ip=1:size(Yf,3)
%     Mr_1=imbinarize(Mr1(:,:,ip),'global');
% %     Mr_1=imopen(Mr_1,se);
%     Mr_1=uint8(bwareaopen(Mr_1,100))*255;
%     stats = regionprops(Mr_1);
%     centroid(ip,:) = stats(255).Centroid;
% end
% 
% maxx=max(abs(centroid(:,1)-mean(centroid(:,1))));
% maxy=max(abs(centroid(:,2)-mean(centroid(:,2))));
% maxshift{i,count}=[maxx,maxy];
% count=count+1;
% maxx
% maxy
% maxshift{i,j-2}=[maxx,maxy];
% if maxx<=3&&maxy<=3
%% save video as .avi file
n = size(Yf);
framenumber = n(3);
% [savename,savepath]=uiputfile('*.avi','Save video as');
sav=[savepath,'corr_',num2str(mean(cM1f)),'_','gsig',num2str(gSig),'_gsiz',num2str(gSiz),'_',savename];
aviobj = VideoWriter(sav,'Grayscale AVI');
aviobj.FrameRate=20;

open(aviobj);
for it=1:T
    frame=uint8(Mr(:,:,it));
    writeVideo(aviobj,frame);
end
close(aviobj);
flag=1;
% break;
% end
end
% if flag==1
%     break;
% end
count=1;
end
end