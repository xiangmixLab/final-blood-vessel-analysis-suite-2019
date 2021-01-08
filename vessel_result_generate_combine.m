function vessel_result_generate_combine(single_mice_dat_name,date_idx,velo_thresh,left_start)

mean_velo=zeros(length(single_mice_dat_name),length(date_idx{1}));
peak_velo=zeros(length(single_mice_dat_name),length(date_idx{1}));
area_under_curve=zeros(length(single_mice_dat_name),length(date_idx{1}));
weighted_avg_speed=zeros(length(single_mice_dat_name),length(date_idx{1}));
normalized_total_velocity=zeros(length(single_mice_dat_name),length(date_idx{1}));
auc_vs_realves=zeros(length(single_mice_dat_name),length(date_idx{1}));
distribution_para=zeros(length(single_mice_dat_name),length(date_idx{1}),4);
total_area=zeros(length(single_mice_dat_name),length(date_idx{1}));
diameter_mapp=zeros(length(single_mice_dat_name),length(date_idx{1}));
velocolor={};
hisdat_all={};
velodat_fit_check=[];
dia_map={};
for tk=1:length(single_mice_dat_name)

    load(single_mice_dat_name{tk});
    
    dat_idx=[1:length(destination)];

    hhv=[];
    for i=dat_idx 
        %% load dat
        load([destination{i},'\','data.mat']);
        %% crop area
%         cropped=imread(cropped_area{i});
        cropped= acontrast2;
        if length(size(cropped))>2
            cropped=rgb2gray(cropped);
        end
        cropped=cropped(60:end-60,60:end-60);
        crr=xcorr2(acontrast2-mean(acontrast2(:)),cropped-mean(cropped(:)));  
        [ssr,snd] = max(crr(:));
        [ij,ji] = ind2sub(size(crr),snd);

        velomap_crop=velomap(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        velomap_crop=fliplr(flipud(velomap_crop));   
        
        velomap_crop(velomap_crop>velo_thresh)=0; % velo threshold: 600

        cropped=acontrast2(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        cropped=fliplr(flipud(cropped));

        vessel_crop=vessel(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        vessel_crop=fliplr(flipud(vessel_crop));
        
        if ~isempty(left_start)
            velomap_crop=velomap_crop(:,left_start:end);
            vessel_crop=vessel_crop(:,left_start:end);
            cropped=cropped(:,left_start:end);
        end
        
        velodat=velomap_crop(velomap_crop>0);

        mean_velodat=mean(velodat);
        std_velodat=std(velodat);
        velodat(velodat>mean_velodat+3*std_velodat)=nan;
        velomap_crop(velomap_crop>mean_velodat+3*std_velodat)=0;
        velodat(isnan(velodat))=[];

    %     [D PD] = allfitdist(velodat,'BIC','PDF') % NAKAGAMI FITS BEST TO MOST OF THE DISTRIBUTIONS

        pd=fitdist(velodat,'gamma');
        k=pd.a;
        theta=pd.b;
        distribution_para(tk,i,:)=[k,theta,k*theta,2/k^0.5];

        h1=histogram(velodat,'binWidth',50);
        hold on;
        h2=histfit(velodat,h1.NumBins,'gamma');
        hxdat=h2(2).XData(h2(2).XData>0);
        hydat=h2(2).YData(h2(2).XData>0);
        hisdat_all{tk,i}=[hxdat',hydat'];

        close
        h1=histogram(velodat,'binWidth',50);
        h1val=h1.Values;
        hold on;    
        plot(hxdat,hydat)

        xlabel('speed(pixel/sec)');
        saveas(gcf,[destination{i},'\','velo_histogram.fig']);
        saveas(gcf,[destination{i},'\','velo_histogram.eps'],'epsc');
        saveas(gcf,[destination{i},'\','velo_histogram.tif']);

        t=corrcoef(resample(hydat,length(h1.Values),length(hydat)),h1.Values);
        [velodat_fit_check(tk,i)]=t(2);

        close

        hhvt=[find(hydat>=(max(hydat)/2))];%half width half height
        hhv(i,:)=hxdat([min(hhvt),max(hhvt)]);

        [vessel_color]=generate_velo_colormap(cropped,velomap_crop,vessel_crop,[0 1500]);
        close
        imagesc(vessel_color)
        colorbar;
        caxis([0 1500]);
        colormap(jet);
        title(num2str(i));
        saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.fig']);
        saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.eps'],'epsc');
        saveas(gcf,[destination{i},'\','velo_with_vessel_cropped.tif']);    
        
        
        mean_velo(tk,date_idx{tk}(i))=mean(velodat(:));
        peak_velo(tk,date_idx{tk}(i))=hxdat(find(hydat==max(hydat)));
        weighted_avg_speed(tk,date_idx{tk}(i))=sum(hydat.*hxdat/sum(hydat));
        area_under_curve(tk,date_idx{tk}(i))=nansum(hydat);
        normalized_total_velocity(tk,date_idx{tk}(i))=nansum(velodat(:))/nansum(hydat);
        auc_vs_realves(tk,date_idx{tk}(i))=nansum(hydat)/nansum(h1val);
        
        total_area(tk,date_idx{tk}(i))=sum(sum(vessel_crop>0));
        
        dia_map{tk,date_idx{tk}(i)}=vessel_diameter_determine(vessel_crop);
        diameter_mapp(tk,date_idx{tk}(i))=max(dia_map{tk,date_idx{tk}(i)}(:));
        
        velocolor{tk,date_idx{tk}(i)}=vessel_color;
        
        save([destination{i},'\','vessel_velo_statistics.mat'],'mean_velo','peak_velo','weighted_avg_speed','area_under_curve','normalized_total_velocity','auc_vs_realves','total_area','diameter_mapp','velocolor','dia_map');  

    end
end
save(['Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\061320_to_be_send\b6250_hist.mat'],'hisdat_all','mean_velo','area_under_curve','velodat_fit_check');  


%     figure;
%     set(gcf,'renderer','painters');
%     colorall=distinguishable_colors(100);
%     for i=dat_idx
%         subplot(9,2,i);
%         hxdat=hisdat_all{i}(:,1);
%         hydat=hisdat_all{i}(:,2);
%         h1=histogram(velodat_all{i},'binWidth',10);
%         hold on;    
%         plot(hxdat,hydat)
%     end
