function V=general_avi_read(fname)

vid=VideoReader(fname);
i=1;
V={};
while hasFrame(vid)
    f=readFrame(vid);
    if length(size(f))==3
        V{i}=uint8(rgb2gray(f));
    else
        V{i}=uint8(f);
    end
    disp(num2str(i))
    i=i+1;
end