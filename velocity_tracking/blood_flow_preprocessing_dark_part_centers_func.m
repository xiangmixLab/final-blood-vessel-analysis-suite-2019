function [rbc_vid,rbc_vid_thresh]=blood_flow_preprocessing_dark_part_centers_func(ai2,vessel)

tic;
[height,width,leng]=size(ai2);
%% gaussian filtering spatial
ak2=ai2*0;
for i=1:leng
    ak2(:,:,i)=imgaussfilt(adapthisteq(squeeze(ai2(:,:,i))),6,'FilterSize',[7 7]);
end

%% PCA
ak2_reshape=reshape(ak2,size(ak2,1)*size(ak2,2),size(ak2,3));
[coeff, score, latent, tsquared, explained, mu] = pca(double(ak2_reshape));
coeff1=coeff*0;
coeff1(:,1)=coeff(:,1);
ak2_reconstruct=reshape(score *coeff1' + repmat(mu, size(ak2_reshape,1),1),size(ak2,1),size(ak2,2),size(ak2,3));

ak3=double(ak2)-ak2_reconstruct;
ak3=ak3-min(ak3(:));

%% enhance
rbc_vid=ak3*0;
for i=1:leng
    rbc_vid(:,:,i)=imadjust(uint8(ak3(:,:,i)*255/max(max(ak3(:,:,i)))));
    rbc_vid(:,:,i)=rbc_vid(:,:,i).*vessel;
end

%% threshold
rbc_vid_thresh=rbc_vid*0;
for i=1:size(rbc_vid,3)
    t=squeeze(rbc_vid(:,:,i));
    max_t=max(t(:));
    t1=t>max_t*0.85;
    t1=bwareaopen(t1,25);
    rbc_vid_thresh(:,:,i)=t1;
end
toc;
%% get vessel edge
% vesselk=vessel;
% vesseledge=edge(vessel,'canny');
% se=strel('disk',2);
% vesseledge=imdilate(vesseledge,se);
% 
% %%
% T=1/samplerate_final;
% %% local contrast enhancement 
% ak3=ak2*0;
% tic
% sz=5;
% for l=1:leng
%     t01=squeeze(ak2(:,:,l));
%     t01=localcontrast(uint8(t01),0.5,0.9);
%     t01=double(t01);
%     if sum(sum(t01))>0
%         ak3(:,:,l)=t01*255/max(max(t01));
%     else
%         ak3(:,:,l)=zeros(size(t01));
%     end
% toc
% end
% toc
% ak4=ak3;
% 
% %% enhance black rbcs
% clear ak7
% ak5=ak4*0;
% ak5_r=ak4*0;
% ak5_r1=ak4*0;
% ak5_r2=ak4*0;
% for i=1:leng
%     t01=(squeeze(ak4(:,:,i)));
%     t1=imadjust(uint8(t01));% 0-255:uint8; 0-1:double
%     t1=imcomplement(uint8(t1)).*uint8(vesselk);
%     ak5_r1(:,:,i)=t1;
% end
% 
% med_ak5_r1=median(ak5_r1,3);
% tic
% for i=1:size(ak5_r1,3)
%     t=ak5_r1(:,:,i);
%     t=t-med_ak5_r1;
%     t1=imbinarize(uint8(t));
%     
%     se=strel('disk',3);
%     t1=imopen(t1,se);
%     t1=bwareaopen(t1, 200);
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
%     ak5(:,:,i)=uint8(t3*255);
%     ak5_r(:,:,i)=uint8(t1*255);
% %     ak5_r2(:,:,i)=uint8(t);
%     toc
% end
