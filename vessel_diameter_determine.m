function diameter_map=vessel_diameter_determine(vessel)
diameter_map=vessel*0;
cline=find_central_line_func(vessel);

deadband=21; % arbitary deadband make sure the dia_line won't go out of the image
for i=deadband:size(cline,1)-deadband
    for j=deadband:size(cline,2)-deadband
        if cline(i,j)>0
            patch=vessel(i-1:i+1,j-1:j+1);
            dia_line=improfile(vessel,[i+(deadband-1) j-(deadband-1)],[i-(deadband-1) j+(deadband-1)]);
            diameterr=sum(dia_line>0);
            diameter_map(i,j)=diameterr;
        end
    end
end