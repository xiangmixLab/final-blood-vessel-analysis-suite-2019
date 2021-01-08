%greedy_contrast_enhancement_java
function res=greedy_contrast_enhancement_java(input,delta)
k=javaclasspath;
if isempty(k)
javaaddpath('D:\NoRMCorre-master\enhancement.jar');%may change base on where the jar is located
end
obj=enhancement.Contrast;

input1=zeros(size(input,1),size(input,2),3);
input1(:,:,1)=input;
input1(:,:,2)=input;
input1(:,:,3)=input;
input1=uint8(input1);

imwrite(input1,'input.jpg');
obj.startEnhancement('input.jpg','output.jpg',delta);

res=rgb2gray(imread('output.jpg'));
res=medfilt2(res);

delete('input.jpg');
delete('output.jpg');
