% velo_manual_region={
%         'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_3_2018_R4_F60_ANETHESIA_1MIN_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_4_18_R4_F60_anethesia_down_1min_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_5_18__R4_F60_anethesia_tight_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_7_18_R4_F60_anethesia_down_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_8_18_R4_F60_line1_3min_anethesia_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_9_18_R4_line1_anethesia_F60_blood_vessel.mat'
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_10_18_251_R4_line1_anetesia_F60_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_11_2018_251_R4_F60_line1_middle_anethesia_better_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_12_2018_251_R4_F60_line1.5_anethesia_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_15_2018_251_F30_R4_line1_anethesia_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_22_2018_251_F60_anethesia_R4_line1_blood_vessel.mat';
%     'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\vessel_manual\b6251\anesthesia_7_27_2018_F251_R4_F60_anethesia_weak background vessel_blood_vessel.mat';
% 
%     }


dat_idx=[1:length(destination)];
mean_velo=zeros(1,length(dat_idx));
peak_velo=zeros(1,length(dat_idx));
area_under_curve=zeros(1,length(dat_idx));
weighted_avg_speed=zeros(1,length(dat_idx));
normalized_total_velocity=zeros(1,length(dat_idx));
auc_vs_realves=zeros(1,length(dat_idx));

distribution_para=zeros(length(dat_idx),4);

ctt=1;
velodat_all={};
hisdat_all={};
hhv=[];
for i=dat_idx %8-6 not aligned
    %% load dat
    load([destination{i},'\','data.mat']);
    %% crop area
    cropped=imread(cropped_area{i});
    cropped=cropped(60:end-60,60:end-60);
    crr=xcorr2(acontrast2-mean(acontrast2(:)),cropped-mean(cropped(:)));  
    [ssr,snd] = max(crr(:));
    [ij,ji] = ind2sub(size(crr),snd);
    
    velomap_crop=velomap(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
    velomap_crop=fliplr(flipud(velomap_crop));   
%     velomap_crop(velomap_crop>600)=0; % velo threshold: 600

    cropped=acontrast2(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
    cropped=fliplr(flipud(cropped));
    
%     velomap_crop=velomap_crop(:,100:end);
%     cropped=cropped(:,100:end);

    velodat=velomap_crop(velomap_crop>0);
    
    mean_velodat=mean(velodat);
    std_velodat=std(velodat);
    velodat(velodat>mean_velodat+3*std_velodat)=nan;
    velomap_crop(velomap_crop>mean_velodat+3*std_velodat)=0;
    velodat(isnan(velodat))=[];
    
%     [D PD] = allfitdist(velodat,'BIC','PDF') % NAKAGAMI FITS BEST TO MOST OF THE DISTRIBUTIONS
    
    velodat_all{i}=velodat;
    
    pd=fitdist(velodat,'gamma');
    k=pd.a;
    theta=pd.b;
    distribution_para(i,:)=[k,theta,k*theta,2/k^0.5];
%     [velodat_fit_check(i),velodat_fit_check_p(i)]=chi2gof(velodat,'CDF',pd,'Alpha',0.01);
    
    
    h1=histogram(velodat,'binWidth',10);
    hold on;
    h2=histfit(velodat,h1.NumBins,'gamma');
    hxdat=h2(2).XData(h2(2).XData>0);
    hydat=h2(2).YData(h2(2).XData>0);
    hisdat_all{i}=[hxdat',hydat'];
    
    close
    h1=histogram(velodat,'binWidth',10);
    h1val=h1.Values;
    hold on;    
    plot(hxdat,hydat)
    
    xlabel('speed(pixel/sec)');
    saveas(gcf,[destination{i},'\','velo_histogram.fig']);
    saveas(gcf,[destination{i},'\','velo_histogram.eps'],'epsc');
    saveas(gcf,[destination{i},'\','velo_histogram.tif']);
    
    t=corrcoef(resample(hydat,length(h1.Values),length(hydat)),h1.Values);
    [velodat_fit_check(i)]=t(2);
    
    close
    
    mean_velo(ctt)=mean(velodat(:));
    hhvt=[find(hydat>=(max(hydat)/2))];%half width half height
    hhv(ctt,:)=hxdat([min(hhvt),max(hhvt)]);
    
    peak_velo(ctt)=hxdat(find(hydat==max(hydat)));
    weighted_avg_speed(ctt)=sum(hydat.*hxdat/sum(hydat));
    area_under_curve(ctt)=nansum(hydat);
    normalized_total_velocity(ctt)=nansum(velodat(:))/nansum(hydat);
    auc_vs_realves(ctt)=nansum(hydat)/nansum(h1val);
    
    vessel_crop=vessel(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
    vessel_crop=fliplr(flipud(vessel_crop));
    [vessel_color]=generate_velo_colormap(cropped,velomap_crop,vessel_crop);
    close
    imagesc(vessel_color)
    title(num2str(i));
    saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.fig']);
    saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.eps'],'epsc');
    saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.tif']);    
    ctt=ctt+1;
%     
end

thresh=0.6;

dat_idx1=dat_idx;
peak_velo1=peak_velo;
auc1=area_under_curve';
hhv1=hhv;
was1=weighted_avg_speed;
ntv=normalized_total_velocity;
aucvr=auc_vs_realves;
dp_1=distribution_para;
hxd=hxdat';

idx_rm=velodat_fit_check<thresh;
dat_idx1(idx_rm)=[];
peak_velo1(idx_rm)=[];
auc1(idx_rm)=[];
hhv1(idx_rm,:)=[];
was1(idx_rm)=[];
ntv(idx_rm)=[];
aucvr(idx_rm)=[];
dp_1(idx_rm,:)=[];

figure;
set(gcf,'renderer','painters');
colorall=distinguishable_colors(100);
for i=dat_idx
    subplot(9,2,i);
    hxdat=hisdat_all{i}(:,1);
    hydat=hisdat_all{i}(:,2);
    h1=histogram(velodat_all{i},'binWidth',10);
    hold on;    
    plot(hxdat,hydat)
%     xlim([0 500])
%     hvalues=h1.Values;
%     plot(hvalues);
%     plot(hisdat_all{i}(:,1),hisdat_all{i}(:,2),'lineWidth',2,'color',colorall(i,:));hold on
end
hisdat_all_mat=cell2mat(hisdat_all);
hisdat_all_mat=hisdat_all_mat(:,2:2:end);
para_collection=[was1',dp_1(:,3),dp_1(:,2)];
% figure;
% % plot(mean_velo);
% % subplot(211)
% plot(peak_velo1);
% hold on;
% plot(hhv1(:,1));plot(hhv1(:,2))
% % subplot(212)
% yyaxis right
% plot(auc1);

% plot(peak_velo./area_under_curve)
plot(was1);hold on;
plot(dp_1(:,3));
plot(dp_1(:,2));

% plot(hhv1(:,1));plot(hhv1(:,2))
yyaxis right
hold on;
plot(auc1);
% plot(aucvr);

figure;
legend_dat={};
for i=dat_idx1
    hxdat=hisdat_all{i}(:,1);
    hydat=hisdat_all{i}(:,2);
    hold on;    
    plot(hxdat,hydat)
%     hvalues=h1.Values;
%     plot(hvalues);
%     plot(hisdat_all{i}(:,1),hisdat_all{i}(:,2),'lineWidth',2,'color',colorall(i,:));hold on
    legend_dat{i}=num2str(i);
end
legend(legend_dat);