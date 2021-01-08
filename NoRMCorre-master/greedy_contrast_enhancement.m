%greedy iterative contrast enhancement

%delta: (1+delta) will represent the ratio of difference between neiboring pixels I(p) and I(q) before and after processing, i.e. (I'(p)-I'(q))/((I(p)-I(q))=1+delta.
function result=greedy_contrast_enhancement(delta,I)

I=double(I);

I1=I;
P=unique(sort(reshape(I1,size(I1,1)*size(I1,2),1)))'; L=min(P); U=max(P);
I1=sweepandpush(I1,P,delta,U,1);

I2=U*ones(size(I))-I1;
P=unique(sort(reshape(I2,size(I2,1)*size(I2,2),1)))'; L=min(P); U=max(P);
I2=sweepandpush(I2,P,delta,U,1);
    
result=U*ones(size(I))-I2;
result=uint8(result);
result=medfilt2(result);
end

function res=sweepandpush(I,P,delta,U,i)
        s=P(i);
        if i>length(P)
            res=I;
        else
        BW=I>s;
        AREA=bwlabel(BW);
        kernal=[-1,-1,-1;-1,8,-1;-1,-1,-1];
        deltah=zeros(size(I));
        for i1=1:max(AREA(:))
            AREA1=I.*double(AREA==i1);
            [y,x]=find(AREA1>0);
            criticalmap=double(imfilter(AREA1,kernal)<0);
            deltamax=min(delta,(U-s)/(max(AREA1(:))-s)-1);            
            for i2=min(y):max(y)
                for i3=min(x):max(x)
                    if AREA1(i2,i3)>0&&criticalmap(i2,i3)==1
                        if deltamax+deltah(i2,i3)>delta
                            deltamax=deltamax-deltah(i2,i3);   
                        end    
                        AREA1(i2,i3)=(1 + deltamax)*(AREA1(i2,i3)-s)+s;
                        deltah(i2,i3)=deltah(i2,i3)+deltamax;
                    end
                end
            end
            I(AREA==i1)=0;
            I=I+sweepandpush(AREA1,P,delta,U,i+1);
        end
        res=I;
        end
end
    
