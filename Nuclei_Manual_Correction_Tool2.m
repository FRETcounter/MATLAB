%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


function I = Nuclei_Manual_Correction_Tool2 (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, pathName)

I = ~I;
fontSize = 10;
f.GraphicsSmoothing = 'off';
opengl software
%**************************************************************************
%************************ Display *****************************************
handles.H = figure (500);
%********************* Full Screen Figure *********************************
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);% Maximize figure.
%**************************************************************************
%if the image is 16 bit then convert it to 8 bit (for visualization only)
ground_truth = uint8( (double(ground_truth) - double(min(ground_truth(:)))) /(double(max(ground_truth(:))) - double(min(ground_truth(:)))) * 255 );

if Invert_Raw_Image ==1
    ground_truth = imcomplement(ground_truth);
else
    ground_truth = ground_truth;
end

subplot(3, 3, 3);
imshow(ground_truth, []);
title(['Original Image  '      FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');

%**************************************************************************
BW = ~I;
%%************** to avoide missing pixels**********************************
se = strel('disk',0, 8);
BW = imdilate(BW, se);
burnedImage = I;
%**************************************************************************
BW_RGB = cat(3, BW, BW, BW);
BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
%Ground Trouth Raw Image *********************************
GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
%*********************************************************
Red = (1-BW_RGB).*GT_RGB + BW_RGB;
Green = (1-BW_RGB).*GT_RGB;
Blue = (1-BW_RGB).*GT_RGB;
C = cat(3, Red, Green, Blue);
subplot(3, 3, [1, 2, 4, 5, 7, 8]);
imshow(C, [])
title('Draw in this window', 'FontSize', fontSize);
axis on;
again = true;
lineCount = 0;
% Create a binary image for all the lines we will draw.
cumulativeBinaryImage = false(size(burnedImage));

%*****************************************************************
Fuse_I = [];  %This is important for button-8, Show Old Result.
%*****************************************************************


%mkdir('Segmented_Reference_Mask') %where to save results
Subfolder_path_and_name = [pathName 'Nucl_Segmented_Reference_Mask'];
mkdir(Subfolder_path_and_name) %where to save results



while again && lineCount < 1000
    choice = menu('Select what to do. Once finished click Done', ...
        'Keyboard Mode',...
        'Crop & See',...
        'Preview',...
        'Done',...
        'Hide Nuclei',...
        'Show Nuclei',...
        'Save Current Correction',...
        'Show Old Result',...
        'Draw by Connected Lines',...
        'Add Single Point',...
        'Clean Image',...
        'Eraser',...
        'Draw&Fill',...
        'Separating Line', ...
        'Exit');
    
    
    try
        
        if choice ==1  % To move to the keyboard mode
            burnedImage = Nuclei_Correction_Magnification_Mode(cumulativeBinaryImage, ground_truth, burnedImage, ground_truth, Fuse_I);
            BW =  ~burnedImage;
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==2   % Crop and See
            try
                Gr =  ground_truth;  %current frame
                subplot(3, 3, [1, 2, 4, 5, 7, 8]);
                h = imrect;
                cordinates = wait(h)
                Crop_I = [];
                End = (numel(Memb_Array));
                
                for k = 1:End;
                    Gr = Memb_Array{k};
                    Gr = uint8( (double(Gr) - double(min(Gr(:)))) /(double(max(Gr(:))) - double(min(Gr(:)))) * 255 );
                    
                    Gr_ROI = imcrop(Gr, cordinates);
                    % Add a white line at the right side
                    [M N] = size(Gr_ROI);
                    Gr_ROI(:, N) =255;
                    %***********************************
                    Crop_I{k} = Gr_ROI;
                    Cr = Crop_I{1,k} ;
                    figure (503)
                    imshow(Cr, []);
                    text('String',(k), ...
                        'HorizontalAlignment','left','VerticalAlignment','top',...
                        'Position',[1 1 1],'color','red');
                    %     M(k) = getframe(gcf);
                end
                
                close(figure(503));
                % close (figure (3001));
                Z = cell2mat(Crop_I);
                implay(Z);
            catch
                continue
            end
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==3;  %Preview
            Priv = ~burnedImage;
            figure, imshow(Priv, []);
            
            % clear the array in button 8, Show Old Result
            Fuse_I = [];
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        
        
        if choice ==5; %Hide Segmented Membrane in red
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(ground_truth, []);
            %title('A', 'FontSize', fontSize);
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==6;  %Show Segmented Membrane
            title('Segmented Membrane', 'FontSize', fontSize);
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==4   %Done
            
            % Save as a reference mask after each done
            Reference_Mask = ~burnedImage;      % reference mask
            imwrite(Reference_Mask, [Subfolder_path_and_name,['\Mask_', FileName_ground_truth]], 'tif', 'Compression','none');
            %******************************************************************
            
            burnedImage = burnedImage;
            close(handles.H)
            break
        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==7   %Save Work
            %SAVE_WORK = burnedImage;
            Reference_Mask = burnedImage;      % reference mask
            imwrite(Reference_Mask, [Subfolder_path_and_name,['\Mask_', FileName_ground_truth]], 'tif', 'Compression','none');
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==8  %Show Old Result
            %load the fusing image
            
            if  isempty (Fuse_I)
                
                try
                    [Fuse_fileNames, Fuse_pathName] = uigetfile({...
                        '*.jpg;*.tif;*.gif;*.bmp;*.png', 'All image files(*.jpg,*.tif,*.gif,*.bmp,*.png)';
                        '*.jpg;*.jpeg', 'JPEG files(*.jpg)';
                        '*.gif', 'GIF files(*.gif)';
                        '*.tif;*.tiff', 'TIFF files(*.tif)';
                        '*.bmp', 'BMP files(*.bmp)';
                        '*.png', 'PNG files(*.png)';
                        '*.*', 'All Files (*.*)'}, 'Open an image');
                    
                    Fuse_fileNames       = fullfile(Fuse_pathName, Fuse_fileNames);
                    Fuse_filelist = dir([fileparts(Fuse_fileNames) filesep '*.tif']);
                    Fuse_I = imread(Fuse_fileNames);
                    ground_truth = ground_truth;
                    %             subplot(3, 3, [1, 2, 4, 5, 7, 8]);
                    Fuse_I = uint8( (double(Fuse_I) - double(min(Fuse_I(:)))) /(double(max(Fuse_I(:))) - double(min(Fuse_I(:)))) * 255 );
                    Both_Fused = imadd(Fuse_I, ground_truth);
                    
                    
                    
                    BW = ~burnedImage;
                    BW_RGB = cat(3, BW, BW, BW);
                    BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
                    GT_RGB = cat(3, Both_Fused, Both_Fused, Both_Fused);
                    GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
                    Red = (1-BW_RGB).*GT_RGB + BW_RGB;
                    Green = (1-BW_RGB).*GT_RGB;
                    Blue = (1-BW_RGB).*GT_RGB;
                    C = cat(3, Red, Green, Blue);
                    subplot(3, 3, [1, 2, 4, 5, 7, 8]);
                    imshow(C, [])
                    
                catch
                    continue
                end
                
                
                
                
            else
                Fuse_I = imread(Fuse_fileNames);
                ground_truth = ground_truth;
                %             subplot(3, 3, [1, 2, 4, 5, 7, 8]);
                Fuse_I = uint8( (double(Fuse_I) - double(min(Fuse_I(:)))) /(double(max(Fuse_I(:))) - double(min(Fuse_I(:)))) * 255 );
                Both_Fused = imadd(Fuse_I, ground_truth);
                
                
                
                BW = ~burnedImage;
                BW_RGB = cat(3, BW, BW, BW);
                BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
                GT_RGB = cat(3, Both_Fused, Both_Fused, Both_Fused);
                GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
                Red = (1-BW_RGB).*GT_RGB + BW_RGB;
                Green = (1-BW_RGB).*GT_RGB;
                Blue = (1-BW_RGB).*GT_RGB;
                C = cat(3, Red, Green, Blue);
                subplot(3, 3, [1, 2, 4, 5, 7, 8]);
                imshow(C, [])
                
                
            end

        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==9  % Connected Lines
            
            line_type = 'impoly';
            line_type = str2func(line_type);
            
            lineCount = lineCount + 1;
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            hLine = line_type(gca);
            caption = sprintf('Draw here.  Original Image with %d interface.', lineCount);
            title(caption, 'FontSize', fontSize);
            singleLineBinaryImage = hLine.createMask();
            Both_Image = imadd(~burnedImage, singleLineBinaryImage);
            Both_Image = im2bw(Both_Image);
            
            burnedImage = ~Both_Image;
            
            
            %********************************************
            %*********** subplot(3, 3, 6) ***************
            
            
            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==10  % Draw a single point
            line_type = 'impoint';
            line_type = str2func(line_type);
            
            lineCount = lineCount + 1;
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            hLine = line_type(gca);
            caption = sprintf('Draw here.  Original Image with %d interface.', lineCount);
            title(caption, 'FontSize', fontSize);
            singleLineBinaryImage = hLine.createMask();
            Both_Image = imadd(~burnedImage, singleLineBinaryImage);
            Both_Image = im2bw(Both_Image);
            
            burnedImage = ~Both_Image;
            
            
            
            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==11  %Clean Image,  from 1- Unconnected edges followed by 2- single isolated pis
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            I = burnedImage;
            
            Cleaned_Image = bwmorph(~I, 'clean');
            
            BothImage = im2bw(Cleaned_Image);
            burnedImage = ~BothImage;

            
            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==12  %Eraser
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            I = burnedImage;
            %imshow(I);
            Z = im2uint8(I);
            style = 'imfreehand';
            eraser_type = str2func(style);
            
            %**************************************************************
            
            I = im2bw(I);
            hx = eraser_type(gca);
%             addNewPositionCallback(hx,@(p) title(mat2str(p,3)));
%             fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),...
%                 get(gca,'YLim'));
%             setPositionConstraintFcn(hx,fcn);
            wait(hx);
            maskImage = hx.createMask();
            inv_maskImage = ~maskImage;
            
            add = immultiply(inv_maskImage, ~I);
            add = im2bw(add);
            burnedImage = ~add;
       
            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
        end
        
        
        if choice ==13  %Draw&Fill
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            I = burnedImage;
            %imshow(I);
            Z = im2uint8(I);
            style = 'imfreehand';
            eraser_type = str2func(style);
            
            %**************************************************************
            
            I = im2bw(I);
            hx = eraser_type(gca);
            maskImage = hx.createMask();
            BothImage = imadd(~I, maskImage);
            
            BothImage = im2bw(BothImage);
            burnedImage = ~BothImage;

            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
        end
        
        
        if choice ==14  %Separating Line
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            
            I = ground_truth;
            AX = subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            
            %imshow(I);  %original raw image
            M = imfreehand(AX,'Closed',0);
            BWW = false(size(M.createMask));
            P0 = M.getPosition;
            
            %******************** NEW *************************************
            X = P0(:,1);
            Y = P0(:,2);
            
            A = round(X);
            B = round(Y);
            [HH WW] = size(I);
            Zer = zeros(HH,WW);
            Zer = im2bw(Zer);
            
            [Aray_H, ~] = size(A)
            for k = 1:Aray_H
                A(k);
                B(k);
                if k ==Aray_H
                    break
                end
                h = imline(gca,[A(k) A(k+1)], [B(k) B(k+1)]);
                Zer_Line = h.createMask();
                
                %                 SE = strel('square', 3);
                %                 Zer_Line = imdilate(Zer_Line, SE);
                
                New_Zer = imadd(Zer, Zer_Line);
                New_Zer = im2bw(New_Zer);
                %New_Zer = bwmorph(New_Zer, 'thin', inf);
                
                Zer = New_Zer;
            end
            
            F = bwmorph(New_Zer, 'bridge');%important step
            SE = strel('square', 1);
            F = imdilate(F, SE);
            FF = ~F;
            
            Separate = immultiply(~burnedImage, FF);
            Separate = im2bw(Separate);
            
            burnedImage = ~Separate;
            
            %**********************************************************
            %*********** subplot(3, 3, 9) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 3, 9)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            [NN LL] = bwlabel(Diff_I_Point, 4);
            if LL >=1
                BW_339 = Diff_I_Point;
                s  = regionprops(BW_339, 'centroid');
                centroids = cat(1, s.Centroid);
                imshow(ground_truth, [])
                title('ERROR: Single pixel was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                hold(imgca,'on')
                plot(imgca,centroids(:,1), centroids(:,2), 'r*')
                hold(imgca,'off')
                
            else
                subplot(3, 3, 9);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 3, [1, 2, 4, 5, 7, 8]) ************
            %Show the new manually corrected membrane
            BW = ~burnedImage;
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            C = cat(3, Red, Green, Blue);
            subplot(3, 3, [1, 2, 4, 5, 7, 8]);
            imshow(C, [])
        end
        
        if choice ==15  %Exit
            
            break
        end
        
        
    end
    I = BW;
end
end


