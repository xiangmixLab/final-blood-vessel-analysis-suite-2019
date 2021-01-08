%extract data from velocity fig

filename={'velocitymask_scale_not_ad_30Hz_msCam1——070617.mat.fig','velocitymask_scale_not_ad_30Hz_msCam1_051517.mat.fig','velocitymask_scale_not_ad_60Hz_msCam1——053017.mat.fig','velocitymask_scale_not_ad_60Hz_msCam1——061317.mat.fig'};
for i=1:4
fn=filename{i,1};
averagevm=
rgb1 = label2rgb(gray2ind(uint8(averagevm),255),jet(255));
for i=1:height
    for j=1:width
        if rgb1(i,j,1)==255&&rgb1(i,j,2)==255&&rgb1(i,j,3)==255
        rgb1(i,j,:)=0;
        end
    end
end

anew1=uint8(anew)+rgb1;

imshow(anew1);
saveas(gcf,['tempresult\velocitymask_scale_not_ad_',filename,'.fig'],'fig');
saveas(gcf,['tempresult\velocitymask_scale_not_ad_',filename,'.jpg'],'jpg');
close all;