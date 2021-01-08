%deblurring
function Yf=deblurring(Yf)
% WEIGHT = edge(template_test,'sobel',.08);
% se = strel('disk',2);
% WEIGHT = 1-double(imdilate(WEIGHT,se));
% WEIGHT([1:3 end-(0:2)],:) = 0;
% WEIGHT(:,[1:3 end-(0:2)]) = 0;
Y=Yf*0;
for i=1:size(Yf,3)
PSF = fspecial('gaussian',7,10);
UNDERPSF = ones(size(PSF)-4);
INITPSF = padarray(UNDERPSF,[2 2],'replicate','both');

% [J1, P1] = deconvblind(template_test,INITPSF,30,[],WEIGHT);
[J1, P1] = deconvblind(Yf(:,:,i),INITPSF);
Y(:,:,i)=J1;
end

n = size(Yf);
framenumber = n(3);
% [savename,savepath]=uiputfile('*.avi','Save video as');
sav=['deblurred.avi'];
aviobj = VideoWriter(sav,'Grayscale AVI');
aviobj.FrameRate=20;

open(aviobj);
for it=1:size(Yf,3)
    frame=uint8(Y(:,:,it));
    writeVideo(aviobj,frame);
end
close(aviobj);
% figure;subplot(121);imshow(template_test);title('Original');subplot(122);imshow(J1);title('Deblurred');