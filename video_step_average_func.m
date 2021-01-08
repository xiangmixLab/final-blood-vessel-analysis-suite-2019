function Y3=video_step_average_func(Y,step,optotune)

Y1={};
Y2={};
Y3={};

if optotune==1 %optotune vessel: each step is a complete recording, repeat. any recording that do not follow this is not "optotune vessel"
    ctt=1;
    for i=1:step:length(Y)-step
        Y1{ctt,1}=Y(i:i+step-1);
        ctt=ctt+1;
    end
    for i=1:step
        t=Y{1}*0;
        for j=1:size(Y1,1)
            t=t+Y1{j}{i};
        end
        t=t/size(Y1,1);
        Y2{i}=t;
    end
    Y3=Y1;
else
    ctt=1;
    for i=1:step:length(Y)-step
        t=double(Y{1}*0);
        for j=1:step
            t=t+double(Y{i+j-1});
        end
        t=t/step;
        Y2{ctt}=t;
        ctt=ctt+1;
    end
    Y3=Y2;
end


%% special:

%% making vid

