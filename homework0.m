pins = imread('TestImgResized.jpg');
imshow(pins)
 %First reading in the pin image
 Red = pins(:,:,1);
 Green = pins(:,:,2);
 Blue = pins(:,:,3);
 filtPins(:,:,1) = medfilt2(Red);
 filtPins(:,:,2) = medfilt2(Green);
 filtPins(:,:,3) = medfilt2(Blue);
 %After filtering the pin image removing blur and noise
 imshow(filtPins)
 %Starting Process of Counting Pins
 %%Extracting each color threshold
bwPins = im2double(filtPins);
pinsR = squeeze(bwPins(:,:,1));
pinsG = squeeze(bwPins(:,:,2));
pinsB = squeeze(bwPins(:,:,3));
%extracting individual planes from the RGB Image
%based on the Matlab Color-Based Segmentation with Live Image Acquisition video
pinBinaryR = im2bw(pinsR,graythresh(pinsR));
pinBinaryG = im2bw(pinsG,graythresh(pinsG));
pinBinaryB = im2bw(pinsB,graythresh(pinsB));
pinBinary = imcomplement(pinBinaryR&pinBinaryG&pinBinaryB);
imshow(pinBinary);

se = strel('disk',7);
pinClean = imopen(pinBinary,se);
pinClean = imfill(pinClean,'holes');
imshow(pinClean);
[labels,numLabels] = bwlabel(pinClean);
disp(['Number of pins:' num2str(numLabels)]);

im = filtPins;
[r ,c, p] = size(im);
 
rLabel = zeros(r,c);
gLabel = zeros(r,c);
bLabel = zeros(r,c);
BW = pinClean;
st = regionprops(BW,'BoundingBox');
imshow(pinClean);

for i =1:numLabels
    
    hold on;
   thisBB = st(i).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
   
rLabel(labels==i) = median(pinsR(labels==i));
gLabel(labels==i) = median(pinsG(labels==i));
bLabel(labels==i) = median(pinsB(labels==i));

 
end

pinLabel = cat(3,rLabel,gLabel,bLabel);
imshow(pinLabel);
%%Get desired color
[x,y] = ginput(1);
selColor = pinLabel(floor(y),floor(x),:);
%%Convert to LAB color space 
C = makecform('srgb2lab');
imLAB = applycform(pinLabel,C);
imSelLAB = applycform(selColor,C);
%% Extract a* and b* value
imA = imLAB(:,:,2);
imB = imLAB(:,:,3);
imSelA = imSelLAB(1,2);
imSelB = imSelLAB(1,3);

distThresh = 20;
imMask = zeros(r,c);
imDist = hypot(imA - imSelA,imB-imSelB);
imMask (imDist <distThresh) = 1;
[cLabel,cNum] = bwlabel(imMask);
imSeg = repmat(selColor,[r,c,1]).*repmat(imMask,[1,1,3]);
imshow(imSeg);

%%Drawling Bounded box around selected color


BWseg= im2bw(imSeg,0.18);
imshow(BWseg);
pinLoc = regionprops(BWseg,'BoundingBox');
imshow(pins);
for i =1:cNum
    
    hold on;
   thisBB = pinLoc(i).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor',selColor,'LineWidth',2 )
   
rLabel(labels==i) = median(pinsR(labels==i));
gLabel(labels==i) = median(pinsG(labels==i));
bLabel(labels==i) = median(pinsB(labels==i));

 
end





 