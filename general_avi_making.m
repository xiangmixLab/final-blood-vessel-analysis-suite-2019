function general_avi_making(Y,vid_name,Fs)

aviobj = VideoWriter(vid_name,'uncompressed AVI');
aviobj.FrameRate=Fs;
open(aviobj);
tic;

if ~iscell(Y)
    for i=1:size(Y,3)
        t=squeeze(Y(:,:,i));
        t1=uint8(t*255/max(t(:)));
        imagesc(t1);
        frame=t1;
        drawnow;
        writeVideo(aviobj,frame);
        clf
        toc;
    end
else
    for i=1:length(Y)
        t=squeeze(Y{i});
        t1=uint8(t*255/max(t(:)));
        imagesc(t1);
        imagesc(t1);
        frame=t1;
        drawnow;
        writeVideo(aviobj,frame);
        clf
        toc;    
    end
end
close(aviobj)   
