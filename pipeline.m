%% processing pipeline for example videos
orilocation='./example/b2m40812';
destination='./example/b2m40812results';
prefix='msCam';
Fs=60; % Hz

mkdir(destination);
%% video concatenate
vid=video_concatenate_vessel_func(prefix,4);
%% motion correction
Mr=runrigid1_2p_func(vid);
%% filter and enhancement
[acontrast2,ai2,acontrast2_saturned]=Filter_and_Enhancement_func(Mr,0);
%% vessel detection
% vessel=Hessianprocess_vessel_extraction_func(acontrast2);
if ~exist('velo_manual_region')
    vessel=threshold_vessel(acontrast2);
else
    load(velo_manual_region);
end
%% central line detection
cen_line=find_central_line_func(vessel);
%% split central line
[lineProfile]=split_central_lines(cen_line,60,1); % K.P.Ivanov et al. 1981, the flow better not be smaller than 0.3-0.5mm/sec and not necessary to be larger than 1.5-1.7mm/sec. Let enable 1.8mm/sec detection here
%% rbc video
[rbc_vid,rbc_vid_thresh]=blood_flow_preprocessing_dark_part_centers_func(ai2,vessel);
%% quantify flow
[velomap,velodir_map]=MiniscopeFlowQuantification_adjusted_automatic(rbc_vid,lineProfile,Fs);
%      velomap=pix_demo_func(rbc_vid(:,:,1:50),vessel);
%         [velomap,velodir_map]=velocity_tracking_050120(rbc_vid_thresh,vessel,frame_rate(i));

%% colormap of velocity
[vessel_color]=generate_velo_colormap(acontrast2,velomap,vessel,[0 1500]); % [0 1500]: speed range, 0mm/s-1500um/s

%% save data
save([destination,'\','data.mat'],'acontrast2','vessel','velomap','vessel_color','lineProfile','cen_line');
imagesc(vessel_color);
saveas(gcf,[destination,'\','velo_color_with_vessel.fig']);
saveas(gcf,[destination,'\','velo_color_with_vessel.eps'],'epsc');
saveas(gcf,[destination,'\','velo_color_with_vessel.tif']);
imagesc(uint8(velomap));
colorbar;
saveas(gcf,[destination,'\','velo_color.fig']);
saveas(gcf,[destination,'\','velo_color.eps'],'epsc');
saveas(gcf,[destination,'\','velo_color.tif']);

