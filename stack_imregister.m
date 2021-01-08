function [vid,vid_cell]=stack_imregister(vid_ori,template)
vid=[];
if iscell(vid_ori)
    for i=1:length(vid_ori)
        vid(:,:,i)=vid_ori{i};
    end
else
    vid=vid_ori;
end

[optimizer,metric]=imregconfig('monomodal');
if ~isempty(template)
    parfor i=1:size(vid_ori,3)
        vid(:,:,i)=imregister(squeeze(vid_ori(:,:,i)), template, 'translation',optimizer, metric);
    end
else
    registration={};
    for i=2:size(vid,3)       
%         vid(:,:,i)=imregister(squeeze(vid(:,:,i)), squeeze(vid(:,:,i-1)), 'translation',optimizer, metric);
        registration{i}=registration2d(squeeze(vid(:,:,i-1)),squeeze(vid(:,:,i)));
        disp(num2str(i));
    end
    for i=2:size(vid,3)       
%         vid(:,:,i)=imregister(squeeze(vid(:,:,i)), squeeze(vid(:,:,i-1)), 'translation',optimizer, metric);
        for j=2:i
            vid(:,:,i) = deformation(squeeze(vid(:,:,i)),registration{j}.displacementField,registration{i}.interpolation);
            disp([num2str(i),' deformation step ',num2str(j-1)]); 
        end
        disp([num2str(i),' finish deformation']);       
    end        
    close all;
end

for i=1:size(vid,3)
    vid_cell{i}=squeeze(vid(:,:,i));
end