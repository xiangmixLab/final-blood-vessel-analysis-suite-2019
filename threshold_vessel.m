function vessel=threshold_vessel(acontrast2)

acontrast21=localcontrast(acontrast2,0.5,0.8);
acontrast21=imadjust(acontrast21);
vessel=imbinarize(acontrast2,'adaptive');

vessel=bwareaopen(vessel,1600);

windowSize = 7;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(vessel), kernel, 'same');
binaryImage = blurryImage > 0.5; % Rethreshold

vessel=binaryImage;

se=strel('disk',3)
vessel=imclose(vessel,se);
se1=strel('disk',1)
vessel=imopen(vessel,se1);

vessel=bwareaopen(vessel,1600);