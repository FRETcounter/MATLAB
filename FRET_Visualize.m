function FRET_Visualize(X, Y, Z, MicPerPix, TimeInterv, StartFrame, EndFrame, Max_Hist, Min_Hist, parent_path)

Frames=[StartFrame:1:EndFrame];    % frame start and end

CC_individual=[];
L_individual=[];
RatioQuant_individual=[];
for i=Frames(1):1:Frames(length(Frames))
    CC_individual{i} = bwconncomp(X{i},4);
    L_individual{i} = bwlabel(X{i},4);
end

for i=Frames(1):1:Frames(length(Frames))
    CellCentroid{i}=table2array(struct2table(regionprops(CC_individual{i},'Centroid')));
    RatioQuant_individual{i}=RatioQuantification(L_individual{i},CC_individual{i}.NumObjects,Z{i}./Y{i}).';
end

for i=Frames(1):1:Frames(length(Frames))
    temp=[CellCentroid{i}(:,1),CellCentroid{i}(:,2),RatioQuant_individual{i}];
    CellCentroidsorted{i}=sortrows(temp,1);
    tempmin=min(CellCentroid{i});
    tempmax=max(CellCentroid{i});
    temp2x=linspace(tempmin(1),tempmax(1),5);
    temp2y=linspace(tempmin(2),tempmax(2),5);
    for j=1:1:4
        temp3x=find(temp2x(j)<CellCentroidsorted{i}(:,1)&CellCentroidsorted{i}(:,1)<temp2x(j+1));
        temp3y=find(temp2y(j)<CellCentroidsorted{i}(:,2)&CellCentroidsorted{i}(:,2)<temp2y(j+1));
        APposition{i,j}=CellCentroidsorted{i}(temp3y,1);
        DVposition{i,j}=CellCentroidsorted{i}(temp3x,2)-mean(CellCentroidsorted{i}(:,2));
        temp4=[APposition{i,j},CellCentroidsorted{i}(temp3y,3)];
        temp5=[DVposition{i,j},CellCentroidsorted{i}(temp3x,3)];
        temp6=sortrows(temp4,1);
        temp7=sortrows(temp5,1);
        ERKprofileAP{i,j}=movmean(temp6(:,2),20);
        ERKprofileDV{i,j}=movmean(temp7(:,2),20);
    end
end
%%

figure(3)
cmap=jet;
for j=1:1:4
    subplot(2,4,j)
    for i=1:1:10
        hold on
        plot(sortrows(DVposition{i,j},1)*MicPerPix/3,ERKprofileDV{i,j},'Color',cmap(round(((i-0)/10)*64),:),'LineWidth',2)
        axis square
        xlim([-20 20])
        ylim([0.95 1.20])
        xticks([-20:5:20])
        hold off
    end
end

subplot(2,4,[5,6,7,8])
colormap(jet)
hold on
for i=1:1:10
    imagesc(i+1,1,round((i/10)*64));
end
xlim([1 12])
axis equal
axis off
%%
figure(4)
temp=zeros(EndFrame,5);
shadecoloroptions={'k','g','c','m'};
for j=1:1:4
    for i=1:1:EndFrame
        temp(i,:)=[i,min(ERKprofileAP{i,j}),mean(ERKprofileAP{i,j}),max(ERKprofileAP{i,j}),std(ERKprofileAP{i,j})];
    end
    AveRate1(j)=(temp(5,3)-temp(1,3))/20; % dimention: min^(-1)
    AveRate2(j)=(temp(10,3)-temp(6,3))/20;
    [~,peakidx2(j)]=max(temp(:,3));
    shadedErrorBar(temp(:,1)*TimeInterv-TimeInterv,temp(:,3),temp(:,5),shadecoloroptions(j),0.8);
    hold on
    axis square
    xlim([0 45])
    ylim([0.95 1.20])
end
%%
[H W] = size(Y{1,1});
spacer=zeros(4,W);  % 340 is the width of the raw image

X_combined=[];
Y_combined=[];
Z_combined=[];

for i=1:1:EndFrame
    X_combined=[X_combined;spacer;X{Frames(i)}];
    Y_combined=[Y_combined;spacer;Y{Frames(i)}];
    Z_combined=[Z_combined;spacer;Z{Frames(i)}];
end
Ratio_combined=Z_combined./Y_combined;
%%
CC_combined = bwconncomp(X_combined,4); %Connected component
L_combined = bwlabel(X_combined,4);
RatioQuant_combined=RatioQuantification(L_combined,CC_combined.NumObjects,Ratio_combined);

MaxRatioValue = Max_Hist; %1.20  hist(RatioQuant_combined) %maximum
MinRatioValue = Min_Hist;  %0.95  hist(RatioQuant_combined) %minimum

BitRatio=ceil(255*(RatioQuant_combined-MinRatioValue)/(MaxRatioValue-MinRatioValue)+1);

LL = zeros(CC_combined.ImageSize); %preallocate

for i = 1:CC_combined.NumObjects
    if RatioQuant_combined(i) > MaxRatioValue
        LL(CC_combined.PixelIdxList{i}) = 256;    %fill in indices
    elseif RatioQuant_combined(i) < MinRatioValue
        LL(CC_combined.PixelIdxList{i}) = 1;
    else
        LL(CC_combined.PixelIdxList{i}) = BitRatio(i);
    end
end
%%
figure(1)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colormap_label = 'jet';
ZZ = colormap_label;  %colormap_label is the type of color map
bar_color = colormap_label;
ZZ = str2func(ZZ);
cmap = ZZ(256);
Lrgb = label2rgb(LL,cmap);

hold on
%figure(1001)
imshow(Lrgb,[])
colormap (bar_color)

colorbar('Ticks',[1:255*0.1/(MaxRatioValue-MinRatioValue):256],'TickLabels',{MinRatioValue:0.1:MaxRatioValue});


% save result as pdf file
fig = figure(1);
fig.PaperPositionMode='auto';

print(fig,[parent_path,'RawRatio'],'-dpdf','-fillpage')

hold off
end

%**************************************************************************
%**************************************************************************

function [ RatioQuant ] = RatioQuantification(ImageMatrix,NumObjects,Ratio)

for i = 1:NumObjects
    CellMask=ImageMatrix==i;
    RatioQuant(i)=mean(Ratio(CellMask));
end

end