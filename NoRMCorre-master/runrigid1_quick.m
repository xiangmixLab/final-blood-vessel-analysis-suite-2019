% demo file for applying the NoRMCorre motion correction algorithm on +
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org

addpath('opticalflow/');
clear;
% gcp;
%% read data and convert to double

[filename, filepath] = uigetfile('*.tif','Select Template');
templatename= [filepath,filename];
template_test=imread(templatename);
[filename, filepath] = uigetfile('*.tif','Select Video');
name = [filepath,filename];
%addpath(genpath('../../NoRMCorre'));
Yf = read_file(name);
[d1,d2,T] = size(Yf);
savepath=[pwd,'\'];
savename=['NormCorre_result_',filename(1:strfind(filename,'.tif')-1),'.avi'];

flag=0;
maxshift=cell(30,16);
count=1;
[d1,d2,T] = size(Yf);
bound = 0;
%% Method 1: optical flow + global ostu threshold
% template_test_1=imbinarize(template_test,'global');
% % template_test_1=imopen(template_test_1,se);
% template_test_1=uint8(bwareaopen(template_test_1,1000))*255;
% stats = regionprops(template_test_1);
% centroidt = stats(255).Centroid;
% 
% 
% centroid3rec={};
% Y=Yf*0;
% Yk=Yf*0;
% for i=1:size(Yf,3)
%     tic
%     Yt=imbinarize(Yf(:,:,i),'global');
% %     Yt=imopen(Yt,se);
%     Yt=uint8(bwareaopen(Yt,1000))*255;
% %     stats = regionprops(Yt);
% %     centroid = stats(255).Centroid;
% %     shift=[round(centroidt(1)-centroid(1)),round(centroidt(2)-centroid(2))];
%    alpha = 0.5;
%     ratio = 0.7;
%     minWidth = 40;
%     nOuterFPIterations = 7;
%     nInnerFPIterations = 1;
%     nSORIterations = 30;
% 
%     para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
% 
%     % this is the core part of calling the mexed dll file for computing optical flow
%     % it also returns the time that is needed for two-frame estimation
%     [vxt,vyt] = Coarse2FineTwoFrames(Yt,template_test_1,para);
%     shift=[round(mean(vxt(:))),round(mean(vyt(:)))];
%     
%     Yt1=Yf(:,:,i);
%     Yt2=Yf(:,:,i);
%     Yt3=Yt*0;
%     for i1=abs(shift(1))+1:size(Yt1,1)-abs(shift(1))
%       for i2=abs(shift(2))+1:size(Yt1,2)-abs(shift(2))
%          Yt1(i1+shift(1),i2+shift(2))=Yt2(i1,i2);
%          Yt3(i1+shift(1),i2+shift(2))=Yt(i1,i2);
%       end
%     end
%     
%     Y(:,:,i)=Yt1;
%     Yk(:,:,i)=Yt3;
%     Yt3=imbinarize(Yt1,'global');
% %     Yt3=imopen(Yt3,se);
%     Yt3=uint8(bwareaopen(Yt3,1000))*255;
%     stats = regionprops(Yt3);
%     centroid3 = stats(255).Centroid;
%     centroid3rec{i}=centroid3;
%     disp(['frame ',num2str(i),' registered']);
%     toc
% end

%% Method 2: detrend (remove background) + local centroid registing
% tic
% Yf1=Yf*0;
% for i1=1:size(Yf,1)
%     for i2=1:size(Yf,2)
%         Yfk=uint8(detrend(squeeze(double(Yf1(i1,i2,:)))));
%         Yf1(i1,i2,:)=Yfk.*Yfk;
%     end
% end
% for i1=1:size(Yf1,3)
%     Yf1(:,:,i1)=medfilt2(squeeze(Yf1(:,:,i1)));
% end
% 
% template_test=mean(Yf,3);
% template_test=template_test*255/max(template_test(:));
% template_test=uint8(template_test);
% toc;
% 
% template_test1=imbinarize(template_test,'adaptive');
% template_test1=medfilt2(template_test1);
% template_test1=(bwareaopen(template_test1,10));
% stats = regionprops(template_test1);
% lengk=sum(~cellfun(@isempty,{stats.Area})); 
% centroidt={};
% template_test2=zeros(size(template_test1));
% for i=1:lengk
%     centroidt{i} = stats(i).Centroid;
%     template_test2(round(centroidt{i}(2)),round(centroidt{i}(1)))=1;
% end
% centroid={};
% for i=1:size(Yf,3)
%     tic
%     Yt=imbinarize(squeeze(Yf(:,:,i)),'adaptive');
%     Yt=medfilt2(Yt);
%     Yt=(bwareaopen(Yt,10));
%     stats = regionprops(Yt);
%     lengk=sum(~cellfun(@isempty,{stats.Area})); 
%     for j=1:lengk
%         centroid{i,j} = stats(j).Centroid;
%     end
% end
% 
% centroidcoor=[];
% count=1;
% for i=1:size(centroid,1)
%     for j=1:size(centroid,2)
%         if ~isempty(centroid{i,j})
%             centroidcoor(count,:)=[centroid{i,j}(2),centroid{i,j}(1)];
%             count=count+1;
%         end
%     end
% end
% 
% opts = statset('Display','final');
% [idx,C] = kmeans(centroidcoor,100,'Distance','cityblock','Replicates',5,'Options',opts);
%     
% 
% Yf2=zeros(size(Yf));
% for i=1:size(centroid,1)
%     for j=1:size(centroid,2)
%         if ~isempty(centroid{i,j})
%             Yf2(round(centroid{i,j}(2)),round(centroid{i,j}(1)),i)=1;
%         end
%     end
% end
% 
% yf2xy={};
% shift=zeros(size(Yf2,3),2);
% count=0;
% for i=1:size(Yf2,3)
%     [x,y]=find(Yf2(:,:,i)==1);
%     yf2xy{i}=[x,y];
%     for j=1:size(C)
%         if C(j,2)>11&&C(j,2)<size(Yf2,1)-11&&C(j,1)>11&&C(j,1)<size(Yf2,2)-11
%         for u=-10:10%can be adjusted by max_shift
%             for v=-10:10
%                 if Yf2(round(C(j,2)+u),round(C(j,1)+v),i)==1
%                     shift(i,:)=shift(i,:)-[C(j,2)+u,C(j,1)+v]+[C(j,2),C(j,1)];
%                     count=count+1;
%                 end
%             end
%         end
%         end
%     end
%     shift(i,:)=shift(i,:)./count;
%     count=0;
% end
% 
% shift(shift==inf)=0;
% shift(isnan(shift))=0;
% Y=Yf*0;
% for i=1:size(Yf2,3)
%     for i1=round(abs(min(shift(:))))+2:size(Yf2,1)-round(abs(max(shift(:))))-2
%         for i2=round(abs(min(shift(:))))+2:size(Yf2,2)-round(abs(max(shift(:))))-2
%             Y(i1,i2,i)=Yf(round(i1+shift(i,1)),round(i2+shift(i,2)),i);    
%         end
%     end
% end
% Mr=Y;

%% method 3: NormCorre, whit out the highpass
% template_test1=(template_test-mean(template_test(:)));
% template_test=greedy_contrast_enhancement_java(template_test1,2);
% 
% Yf1=Yf*0;
% tic;
% for i1=1:size(Yf,1)
%     for i2=1:size(Yf,2)
%         Yfk=(detrend(squeeze(double(Yf(i1,i2,:)))));
%         if(max(Yfk(:)))<10
%             Yfk=Yfk*0;
%         end
%         Yf1(i1,i2,:)=Yfk;
%     end
% end
% 
% for i1=1:size(Yf1,3)
%     Yt=Yf1(:,:,i1);
%     Yf1(:,:,i1)=greedy_contrast_enhancement_java(Yt,2);
% end
% toc;
% Yf1 = single(Yf1);
% Y=Yf1;
% 
% 
% 
% %% first try out rigid motion correction
%     % exclude boundaries due to high pass filtering effects
% options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',5,'max_shift',5,'iter',1,'correct_bidir',false);
% options_r.upd_template=false;
% 
% %% register using the high pass filtered data and apply shifts to original data
% tic; 
%     [M1,shifts1,template1] = normcorre_batch(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r,template_test); toc % register filtered data
%     % exclude boundaries due to high pass filtering effects
%     tic; Mr = apply_shifts(Yf,shifts1,options_r,bound/2,bound/2); toc % apply shifts to full dataset
%     % apply shifts on the whole movie
%     [cM1f,mM1f,vM1f] = motion_metrics(Mr,options_r.max_shift);


%% method 4: manual selected specific point alignment
% imshow(template_test1);
% [x,y]=getpts;
% close all;
% x1=round(x);
% y1=round(y);
% 
% for i=1:size(Yf,3)
%     Yt=Yf(:,:,i);
%     patch=Yt(y1-5:y1+5,x1-5:x1+5);
%     patch1=imbinarize(patch,'global');
%     stats = regionprops(patch1);
%     centroid = stats(255).Centroid;
% end

%% save video as .avi file
n = size(Yf);
framenumber = n(3);
% [savename,savepath]=uiputfile('*.avi','Save video as');
sav=[savepath,'correction_quick','_',savename];
aviobj = VideoWriter(sav,'Grayscale AVI');
aviobj.FrameRate=20;

open(aviobj);
for it=1:T
    frame=uint8(Mr(:,:,it));
    writeVideo(aviobj,frame);
end
close(aviobj);


