%velomap: central 
dest_foldername={
    'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\11222019_to_be_send\batch6_250';
    'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\11222019_to_be_send\batch6_251';
    'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\11222019_to_be_send\batch2_mouse3';
    'Y:\Lujia\TBI project fig\Writing_folder\miniscope tiff\11222019_to_be_send\batch2_mouse4';
    }
info_name={
    'Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\b6m250.mat'		
    'Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\b6m251.mat'
    'Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\b2m3.mat'		
    'Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\b2m4.mat'			
    }

load('Y:\Lujia\TBI project fig\final blood vessel analysis suite 2019\dataloc\date_all.mat');

for tk=1:4
    load(info_name{tk});
    %% part 1 combined vessel-velo plot    
    dat_idx=[1:length(destination)];
    a=figure;
    for i=dat_idx
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
        velomap_crop(velomap_crop>600)=0; % velo threshold: 600

        cropped=acontrast2(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        cropped=fliplr(flipud(cropped));
        

        vessel_crop=vessel(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        vessel_crop=fliplr(flipud(vessel_crop));

        [vessel_color]=generate_velo_colormap(cropped,velomap_crop,vessel_crop);

        cropped1=cropped;
        if tk==3
            vessel_color=vessel_color(:,250:end,:);
            vessel_crop=vessel_crop(:,250:end);
            cropped1=cropped(:,250:end);
        end
        
        cen_line=find_central_line_func(vessel_crop);

        figure(a);
        set(a,'position',[0 0 1900 400]);
        subplot(2,length(dat_idx),i)
        imagesc(vessel_color)
        title(date_all{tk}{i});
        subplot(2,length(dat_idx),i+length(dat_idx))
        imagesc(cropped1);colormap(gray);hold on
        contour(cen_line,'r-')
    %     
    end
    set(gcf,'renderer','painters');
    saveas(gcf,[dest_foldername{tk},'\','combined_vessel_velo_plot.eps'],'epsc');
    disp('combined plot fin');
    close

    %% part 2 separate plot save
    mkdir([dest_foldername{tk},'\','vessel_plot']);
    mkdir([dest_foldername{tk},'\','speed_plot']);

    for i=dat_idx
        %% load dat
        load([destination{i},'\','data.mat']);
        %% crop area
        cropped=imread(cropped_area{i});
        cropped=cropped(60:end-60,60:end-60);
        
        crr=xcorr2(acontrast2,cropped);
        [ssr,snd] = max(crr(:));
        [ij,ji] = ind2sub(size(crr),snd);

        velomap_crop=velomap(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        velomap_crop=fliplr(flipud(velomap_crop));   
        velomap_crop(velomap_crop>600)=0; % velo threshold: 600

        cropped=acontrast2(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        cropped=fliplr(flipud(cropped));

        vessel_crop=vessel(ij:-1:max(ij-size(cropped,1)+1,1),ji:-1:max(ji-size(cropped,2)+1,1));
        vessel_crop=fliplr(flipud(vessel_crop));

        [vessel_color]=generate_velo_colormap(cropped,velomap_crop,vessel_crop);
        
        cropped1=cropped;
        if tk==3
            vessel_color=vessel_color(:,250:end,:);
            vessel_crop=vessel_crop(:,250:end);
            cropped1=cropped(:,250:end);
        end        
        
        cen_line=find_central_line_func(vessel_crop);

        figure;
        imagesc(vessel_color)
        cbh=colorbar;
        colormap(jet);
        caxis([0,max(velomap_crop(:))]);
        ylabel(cbh, 'um/sec')
        saveas(gcf,[dest_foldername{tk},'\','speed_plot','\',date_all{tk}{i},'.tif']);
        saveas(gcf,[dest_foldername{tk},'\','speed_plot','\',date_all{tk}{i},'.eps'],'epsc');
        close;figure
        imagesc(cropped1);colormap(gray);hold on
        contour(cen_line,'r-')
        set(gcf,'renderer','painters');
        saveas(gcf,[dest_foldername{tk},'\','vessel_plot','\',date_all{tk}{i},'.tif']);
        saveas(gcf,[dest_foldername{tk},'\','vessel_plot','\',date_all{tk}{i},'.eps'],'epsc');  
        disp(['separate plot ',date_all{tk}{i},' fin']);
    %     
    end
end

