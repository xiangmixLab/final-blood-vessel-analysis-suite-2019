%Video Concatenate function
function a1=video_concatenate_vessel_func(mscamprefix,max_vid)
tic
sort=1;

disp('start')
tic
filenamestruct=dir([mscamprefix,'*.avi']);
if isempty(filenamestruct)
    filenamestruct=dir([mscamprefix,'_','*.avi']);
end  
lengk=sum(~cellfun(@isempty,{filenamestruct.name}));

if sort==1
for k=1:lengk
    ft=filenamestruct(k).name;
    num_c=ft(findstr(ft,mscamprefix)+length(mscamprefix):findstr(ft,'.avi')-1);
    if isequal(num_c(1),'_')
        num_c=num_c(2:end);
    end
    num_ind=str2num(num_c);
    filenamet{num_ind}=ft;
end
else
    for k=1:lengk
    ft=filenamestruct(k).name;
    filenamet{k}=ft;
    end
end
%concatenate
sign=1;
num2read=[0];
concatenatedvideo=[];
if lengk>max_vid
    lengk1=max_vid;
else
    lengk1=lengk;
end
for k=1:lengk1
    v=VideoReader(filenamet{k});
    p=0;
    Vidt=[];
    while hasFrame(v)
        p=p+1;
        k11=readFrame(v);
        if length(size(k11))>2
            Vidt(:,:,p)=rgb2gray(k11);
        else
            Vidt(:,:,p)=k11;
        end
    end
    Vidt=uint8(Vidt);

    %continue
    concatenatedvideo(:,:,sign:sign+length(Vidt(1,1,:))-1)=uint8(Vidt);
    num2read(k+1)=length(Vidt(1,1,:));
    sign=sign+length(Vidt(1,1,:));
    disp(['concatenate ',num2str(k)]);
end
disp('concatenate fin')
%abandon the first and last frame of the videos as it usually
%has problems
concatenatedvideo=concatenatedvideo(:,:,2:end-1);

a1=uint8(concatenatedvideo);
% save('concatenated_vessel_video.m','a1');

toc;        