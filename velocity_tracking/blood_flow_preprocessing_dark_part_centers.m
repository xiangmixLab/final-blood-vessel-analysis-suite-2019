%% gaussian filtering spatial
% h=fspecial('log',20,4);
% for i=1:leng
%     ai2(:,:,i)=imfilter(squeeze(ai1(:,:,i)),h,'replicate');
% end
ai3=ai1*0;
% mean_ai1=mean(ai1,3);
% for i=1:leng
%     ai3(:,:,i)=imgaussfilt(adapthisteq(squeeze(ai1(:,:,i))),6,'FilterSize',[3 3]);
% end
tic
for i=1:height
    for j=1:width
        if vessel(i,j)>0
            fc1=1;
            fc2=5;
            fss=30;
            [b,a] = butter(6,[fc1/(fss/2) fc2/(fss/2)],'bandpass');
%             eve=envelope(double(squeeze(ai1(i,j,:))),round(size(ai1,3)*3/fs),'peak');% to 3 Hz envelope
%             meve=mean(eve);
%             eve=eve-meve;
%             eve=eve*2+meve*2;
            ai1t=double(squeeze(ai1(i,j,:)));
            mai1=mean(ai1t);
            eve=filter(b,a,ai1t-mai1);
            eve=eve*275/(max(eve)-min(eve));
            eve=eve-min(eve);
            ai3(i,j,:)=eve;
            toc
        end
    end
end
ai3=uint8(ai3);

for i=1:leng
    ai3(:,:,i)=imgaussfilt(adapthisteq(squeeze(ai3(:,:,i))),6,'FilterSize',[7 7]);
end
% for i=1:leng
%     ai2(:,:,i)=medfilt2(squeeze(ai1(:,:,i)));
% end
% ai10=ai3*0;

% for i=1:leng
%     tt=ai1(:,:,i).*double(vessel);
%     tt2=tt(tt>0);
%     sig=std(tt2);
%     h=fspecial('gaussian',19,sig);
%     ai3(:,:,i)=deconvlucy(squeeze(ai1(:,:,i)),h);
% end

vesselk=vessel;
vesseledge=edge(vessel,'canny');
se=strel('disk',2);
vesseledge=imdilate(vesseledge,se);
T=1/samplerate_final;
%% test
ai7=ai1*0;
tic
sz=5;
for l=1:leng
    t01=squeeze(ai3(:,:,l));
%     for i=1+sz:size(t01,1)-sz
%         for j=1+sz:size(t01,2)-sz
%                 patch=t01(i-sz:i+sz,j-sz:j+sz);
%                 K=std(patch(:))/mean(patch(:));
%                 tau_c=2*T*K/(1-K^2); %K=[(tau_c/2T)(1-exp(-2t/tau_c)))^0.5
%                 if ~isnan(K)
%                     ai7(i,j,l)=K;% a relative measure, absolute is controversal
%                 else
%                     ai7(i,j,l)=0;
%                 end
%         end
%     end
%     t01 = colfilt(t01,[sz sz],'sliding',@speckle_contrast);
%     t01([1:3,end-2:end],:)=0;
%     t01(:,[1:3,end-2:end])=0;
    t01=localcontrast(uint8(t01),0.5,0.9);
    t01=double(t01);
    if sum(sum(t01))>0
        ai7(:,:,l)=t01*255/max(max(t01));
    else
        ai7(:,:,l)=zeros(size(t01));
    end
toc
end
toc
ai4=ai7;
% for i=1:leng
%     ai4(:,:,i)=ai4(:,:,i)-median(ai4,3);
% end
%% enhance black rbcs
clear ai7
ai5=ai4*0;
ai5_r=ai4*0;
ai5_r1=ai4*0;
ai5_r2=ai4*0;
for i=1:leng
    t01=(squeeze(ai4(:,:,i)));
    t1=imadjust(uint8(t01));% 0-255:uint8; 0-1:double
    t1=imcomplement(uint8(t1)).*uint8(vesselk);
    ai5_r1(:,:,i)=t1;
end

med_ai5_r1=median(ai5_r1,3);
tic
for i=1:size(ai5_r1,3)
    t=ai5_r1(:,:,i);
    t=t-med_ai5_r1;
    t1=imbinarize(uint8(t));
    
    se=strel('disk',3);
    t1=imopen(t1,se);
    t1=bwareaopen(t1, 200);
    t2 = imregionalmax(t1);
    s = regionprops(t2);
    t3=t2*0;
    if ~isempty(s)
        for j=1:length(s)        
        bb=round(s(j).Centroid);
        t3(round(bb(:,2)),round(bb(:,1)))=1;
        end
    end

    ai5(:,:,i)=uint8(t3*255);
    ai5_r(:,:,i)=uint8(t1*255);
%     ai5_r2(:,:,i)=uint8(t);
    toc
end


%% enhance non rbcs for more speckles
% ai6=ai4*0;
% ai6_r=ai4*0;
% ai6_r1=ai4*0;
% for i=1:leng
%     t01=(squeeze(ai4(:,:,i)));
%     t1=imadjust(uint8(t01));
%     t1=uint8(t1).*uint8(vesselk);
%     ai6_r1(:,:,i)=uint8(t1);
% end
% 
% tic
% for i=1:size(ai6_r1,3)
%     t=ai6_r1(:,:,i);
%     t=t-mean(ai6_r1,3);
%     t1=imbinarize(uint8(t));
% %     se=strel('disk',3);
% %     t1=imerode(t1,se);
%     t2 = imregionalmax(t1);
%     s = regionprops(t2);
%     t3=t2*0;
%     if ~isempty(s)
%         for j=1:length(s)        
%         bb=round(s(j).Centroid);
%         t3(round(bb(:,2)),round(bb(:,1)))=1;
%         end
%     end
% 
%     ai6(:,:,i)=uint8(t3*255);
% 
%     toc
% end
%% make points larger
for i=1:leng
    s1=strel('disk',5);
%     ai6(:,:,i)=imdilate(squeeze(ai6(:,:,i)),s1).*double(vesselk);
%     ai5(:,:,i)=imdilate(squeeze(ai5(:,:,i)),s1).*double(vesselk);
    ai5(:,:,i)=ai5_r(:,:,i);
%     ai6(:,:,i)=bwareaopen(squeeze(ai6(:,:,i)),24);
%     ai5(:,:,i)=bwareaopen(squeeze(ai5(:,:,i)),10);
end
% for i=1:leng
%     s1=strel('disk',5);
%     ai6_r(:,:,i)=imdilate(squeeze(ai6_r(:,:,i)),s1).*double(vesselk);
%     ai5_r(:,:,i)=imdilate(squeeze(ai5_r(:,:,i)),s1).*double(vesselk);
%     ai6_r(:,:,i)=bwareaopen(squeeze(ai6_r(:,:,i)),24);
%     ai5_r(:,:,i)=bwareaopen(squeeze(ai5_r(:,:,i)),24);
% end
%% examine
% sav='004_000_004 rbc illustration';
% mkdir(sav);
% 
% savname=[sav,'\','dark_part_centers_new_1.avi'];
% aviobj = VideoWriter(savname,'Uncompressed AVI');
% aviobj.FrameRate=10;
% 
% open(aviobj);
% tt1=[];
% sz=5;
% gaussiank=fspecial('gaussian',sz*2+1,2);
% for i=1:size(ai5,3)-1
%     t1=ai5(:,:,i);
% 
%     tt1=t1;
% %     imshow(uint8(tt1));
% %     saveas(gcf,[sav,'\','frame2',num2str(i),'.tif']);
%     if std(t1(:))>0
%             frame=uint8(tt1*255/(max(tt1(:))));
%             writeVideo(aviobj,frame);
%     end
% %     drawnow;
% toc
% end
% close(aviobj);
% 
% 
% savname=[sav,'\','dark part centers and original.avi'];
% aviobj = VideoWriter(savname,'Uncompressed AVI');
% aviobj.FrameRate=10;
% 
% open(aviobj);
% tt1=[];
% sz=5;
% 
% gaussiank=fspecial('gaussian',sz*2+1,2);
% for i=1:size(ai5,3)-1
% 
%     t1=ai5(:,:,i);
%     t2=ai1(:,:,i);
%     t2=t2*255/max(t2(:));
% 
%     tt1(:,:,1)=t1*255+t2;
%     tt1(:,:,2)=t2;
%     tt1(:,:,3)=t2;
% %     imshow(uint8(tt1));
% %     saveas(gcf,[sav,'\','frame2',num2str(i),'.tif']);
%     if std(tt1(:))>0
%             frame=uint8(tt1);
%             writeVideo(aviobj,frame);
%     end
% %     drawnow;
% toc
% end
% close(aviobj);
