orilocation_name={'b6m250.mat','b6m251.mat','b2m3.mat','b2m4.mat'};
datee={{'6/29/2018','6/30/2018,','7/1/2018','7/3/2018','7/4/2018','7/5/2018','7/6/2018','7/7/2018','7/9/2018','7/10/2018','7/11/2018','7/12/2018','7/13/2018','7/14/2018','7/15/2018','7/22/2018','7/31/2018'};
       {'6/29/2018','6/30/2018,','7/3/2018','7/4/2018','7/5/2018','7/7/2018','7/8/2018','7/9/2018','7/10/2018','7/11/2018','7/12/2018','7/15/2018','7/22/2018','7/27/2018'};
       {'8/9/2017','8/12/2017,','8/15/2017','8/18/2017','8/21/2017','8/24/2017','8/27/2018','8/30/2017','9/2/2017','9/5/2017','9/8/2017','9/11/2017','9/13/2017','9/18/2017','9/21/2017','9/25/2017','9/28/2017','10/3/2017'};
       {'8/6/2017','8/9/2017','8/12/2017,','8/15/2017','8/18/2017','8/24/2017','8/27/2018','8/30/2017','9/2/2017','9/8/2017','9/11/2017','9/13/2017','9/18/2017','9/21/2017','9/25/2017','9/28/2017','10/3/2017'};
};
for tk=1:4
    load(['Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\',orilocation_name{tk}]);

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

        cropped=acontrast2(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        cropped=fliplr(flipud(cropped));

        velodat=velomap_crop(velomap_crop>0);

        mean_velodat=mean(velodat);
        std_velodat=std(velodat);
        velodat(velodat>mean_velodat+3*std_velodat)=nan;
        velomap_crop(velomap_crop>mean_velodat+3*std_velodat)=0;
        velodat(isnan(velodat))=[];

        velodat_all{i}=velodat;

        pd=fitdist(velodat,'nagasaki');
        k=pd.a;
        theta=pd.b;
        distribution_para(i,:)=[k,theta,k*theta,2/k^0.5];
%         [velodat_fit_check(i),velodat_fit_check_p(i)]=chi2gof(velodat,'CDF',pd,'Alpha',0.01);


        h1=histogram(velodat,'binWidth',10);
        hold on;
        h2=histfit(velodat,h1.NumBins,'nagasaki');
        hxdat=h2(2).XData(h2(2).XData>0);
        hydat=h2(2).YData(h2(2).XData>0);
        hisdat_all{i}=[hxdat',hydat'];

        close
        h1=histogram(velodat,'binWidth',50);
        h1val=h1.Values;
        hold on;    
        plot(hxdat,hydat)

        xlabel('speed(pixel/sec)');
        xlim([0 8000]);
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
% 
%     idx_rm=velodat_fit_check<thresh;
%     dat_idx1(idx_rm)=[];
%     peak_velo1(idx_rm)=[];
%     auc1(idx_rm)=[];
%     hhv1(idx_rm,:)=[];
%     was1(idx_rm)=[];
%     ntv(idx_rm)=[];
%     aucvr(idx_rm)=[];
%     dp_1(idx_rm,:)=[];

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
    end
    hisdat_all_mat=cell2mat(hisdat_all);
   
    plot(was1);hold on;
    plot(dp_1(:,3));
    plot(dp_1(:,2));

