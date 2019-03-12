%**************************************************************************
%**************************************************************************
%**************************************************************************
%                  Developed by Mustafa Sami, RIKEN BDR
%**************************************************************************
%**************************************************************************
%**************************************************************************


function I = Manual_Correction_Tool2_TwoWindow (I, ground_truth, Memb_Array, FileName_ground_truth, Invert_Raw_Image, Previous_ground_truth, Previous_FileName_ground_truth, pathName)

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
%if the image is 16 bit then convert it to 8 bit
ground_truth = uint8( (double(ground_truth) - double(min(ground_truth(:)))) /(double(max(ground_truth(:))) - double(min(ground_truth(:)))) * 255 );



if Invert_Raw_Image ==1
    ground_truth = imcomplement(ground_truth);  % no dilation for the EM. However, in membrane correction
    %we applied dilation to improve the apearance of the image
else
    ground_truth = ground_truth;
end

subplot(3, 5, 5);
imshow(ground_truth, []);
title(['Current Image  '      FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');

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
subplot(3, 5, [1, 2, 6, 7, 11, 12]);
imshow(C, [])
title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
axis on;
again = true;
lineCount = 0;
% Create a binary image for all the lines we will draw.
cumulativeBinaryImage = false(size(burnedImage));

%************************************************************
% Show the previous frame. 

Corrected_Memb_Path=([pathName, 'Memb_Segmented_Reference_Mask']);
LLIST= getAllFiles(Corrected_Memb_Path);

if isempty(LLIST)
    
    subplot(3, 5, [3, 4, 8, 9, 13, 14]);
    imshow(Previous_ground_truth, [])
    title(['Start with the same image'  Previous_FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
    BW_Previous = true(size(Previous_ground_truth));
    
else
    %     Previous_FileName = (['Mask_', Previous_FileName_ground_truth]);
    %     PPATH = [pwd,'\Segmented_Reference_Mask'];
    
    PPATH = [pathName,'Memb_Segmented_Reference_Mask'];
    Previous_FileName = (['Mask_', Previous_FileName_ground_truth]);
    
    %BW_Previous = getImage(Previous_FileName,PPATH);
    BW_Previous = imread(fullfile(PPATH, Previous_FileName));
    
    BW_Previous = ~BW_Previous;
    
    BW_RGB_Previous = cat(3, BW_Previous, BW_Previous, BW_Previous);
    BW_RGB_Previous = double(BW_RGB_Previous(:,:,1))./double(max(BW_RGB_Previous(:)));
    %Ground Trouth Raw Image *********************************
    GT_RGB_Previous = cat(3, Previous_ground_truth, Previous_ground_truth, Previous_ground_truth);
    GT_RGB_Previous = double(GT_RGB_Previous(:,:,1))./double(max(GT_RGB_Previous(:)));
    %*********************************************************
    Red_Previous = (1-BW_RGB_Previous).*GT_RGB_Previous;
    Green_Previous = (1-BW_RGB_Previous).*GT_RGB_Previous + BW_RGB_Previous;
    Blue_Previous = (1-BW_RGB_Previous).*GT_RGB_Previous ;
    C_Previous = cat(3, Red_Previous, Green_Previous, Blue_Previous);
    subplot(3, 5, [3, 4, 8, 9, 13, 14]);
    imshow(C_Previous, [])
    
    title(['Previous Raw Image   '  Previous_FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
end

%*****************************************************************
Fuse_I = [];  %This is important for button-8, Show Old Result.
%*****************************************************************


%mkdir('Segmented_Reference_Mask') %where to save results

Subfolder_path_and_name = [pathName 'Memb_Segmented_Reference_Mask'];
mkdir(Subfolder_path_and_name) %where to save results


%**************************************************************************


while again && lineCount < 1000
    choice = menu('Select what to do. Once finished click Done', ...
        'Keyboard Mode',...
        'Crop & See',...
        'Preview Current Image', ...
        'Done',...
        'Hide Membrane',...
        'Show Membrane', ...
        'Save as Reference Mask',...
        'Overlap Old Result',...
        'Active Contour', ...
        'Draw Connected Lines',...
        'Add Point',...
        'Clean Image',...
        'Break and Remove',...
        'Free Hand Draw',...
        'Eraser',...
        'Exit');
    try
        
        if choice ==1  % To move to the keyboard mode
            burnedImage = Membrane_Correction_Magnification_Mode_TwoWindow(cumulativeBinaryImage, ground_truth, burnedImage, ground_truth, Fuse_I, FileName_ground_truth);
            BW =  ~burnedImage;
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==2   % Crop and See
            try
                Gr =  ground_truth;  %current frame
                subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                h = imrect;
                cordinates = wait(h)
                Crop_I = [];
                End = (numel(Memb_Array));
                
                for k = 1:End
                    Gr = Memb_Array{k};
                    Gr = uint8( (double(Gr) - double(min(Gr(:)))) /(double(max(Gr(:))) - double(min(Gr(:)))) * 255 );
                    
                    Gr_ROI = imcrop(Gr, cordinates);
                    
                    Crop_I{k} = Gr_ROI;
                    Cr = Crop_I{1,k} ;
                    Cr = padarray(Cr, [12 12], 'both');
                    Cr = cat(3, Cr, Cr, Cr);
                    figure (503)
                    imshow(Cr, []);
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                    text('String',(k), ...
                        'HorizontalAlignment','left','VerticalAlignment','top',...
                        'Position',[1 1 1],'color','red');
                    %     M(k) = getframe(gcf);
                    
                    tim = getframe(gca);
                    tim2 = tim.cdata;
                    
                    Image_Numb{k} = tim2;
                    
                end
                
                close(figure(503));
                % close (figure (3001));
                %Z = cell2mat(Image_Numb);
                %implay(Z);
                
                figure, montage(Image_Numb)
                clear Crop_I
            catch
                continue
            end
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==3  %Preview
            Priv = ~burnedImage;
            figure, imshow(Priv, []);
            
            % clear the array in button 8, Show Old Result
            Fuse_I = [];
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==10 %Draw Straight Line
            
            line_type = 'imline';
            line_type = str2func(line_type);
            
            lineCount = lineCount + 1;
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            hLine = line_type(gca);
            caption = sprintf('Draw here.  Current Image with %d interface.', lineCount);
            title(caption, 'FontSize', fontSize);
            singleLineBinaryImage = hLine.createMask();
            Both_Image = imadd(~burnedImage, singleLineBinaryImage);
            Both_Image = im2bw(Both_Image);
            
            burnedImage = ~Both_Image;
            
            
            %********************************************
            %*********** subplot(3, 5, 10) ***************
            %Show any broken edge available
            
            I_Subplot336 = ~burnedImage;
            subplot(3, 5, 10)
            I_Edge = bwmorph(I_Subplot336, 'spur', inf);
            Diff_I_Edge = imabsdiff(I_Subplot336, I_Edge);
            [NN LL] = bwlabel(Diff_I_Edge, 4);
            if LL >=1
                BW_336 = Diff_I_Edge;
                BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                C_336 = cat(3, Red_336, Green_336, Blue_336);
                subplot(3, 5, 10);
                imshow(C_336, [])
                title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
            else
                subplot(3, 5, 10);
                imshow(Diff_I_Edge, [])
                title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, 15) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 5, 15)
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
                subplot(3, 5, 15);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==5 %Hide Segmented Membrane in red
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(ground_truth, []);
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            %title('A', 'FontSize', fontSize);
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==6  %Show Segmented Membrane
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==4   %Done
            
            % Save as a reference mask after each done
            Reference_Mask = burnedImage;      % reference mask
            imwrite(Reference_Mask, [Subfolder_path_and_name,['\Mask_', FileName_ground_truth]], 'tif', 'Compression','none')
            %******************************************************************
            
            burnedImage = burnedImage;
            close(handles.H)
            break
        end
        
        %**********************************************************************
        %**********************************************************************
        if choice ==13  % for Break and Remove button
            style = 'imline';
            eraser_type = str2func(style);
            
            BW = ~burnedImage;
            
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            hx = eraser_type(gca);
%             addNewPositionCallback(hx,@(p) title(mat2str(p,3)));
%             fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),...
%                 get(gca,'YLim'));
%             setPositionConstraintFcn(hx,fcn);
            %wait(hx);
            maskImage = hx.createMask();
            se = strel('disk',1, 8);
            %se = strel('square',2);  % never use. It will shift the image
            maskImage = imdilate(maskImage, se);
            maskImage = ~maskImage;
            BW_with_Cut = immultiply(maskImage, BW);
            BW_with_Cut = im2bw(BW_with_Cut);
            BW_with_Cut = bwmorph(BW_with_Cut, 'thin', Inf);
            remove_spur = bwmorph(BW_with_Cut, 'spur', Inf);
            
            Dilat_remove_spur = imdilate(remove_spur, se);
            
            % Add the missing pixels during the thinning
            Missing_Pixel = imsubtract(Dilat_remove_spur, BW);
            Missing_Pixel = im2bw(Missing_Pixel);
            %figure, imshow(Missing_Pixel);
            burnedImage = ~Dilat_remove_spur;
            burnedImage = imadd(burnedImage, Missing_Pixel);
            burnedImage = im2bw(burnedImage);
            %now remove any remaining spurs after the break 
            burnedImage = bwmorph(~burnedImage, 'spur', Inf);
            burnedImage = ~burnedImage;
            %**********************************************************************
            %********************************************
            %*********** subplot(3, 5, 10) ***************
            %Show any broken edge available
            I_Subplot336 = burnedImage;
            
            I_Edge = bwmorph(I_Subplot336, 'spur', inf);
            
            Diff_I_Edge = imabsdiff(burnedImage, I_Edge);
            [NN LL] = bwlabel(Diff_I_Edge, 4);
            if LL >=1
                BW_336 = Diff_I_Edge;
                BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                C_336 = cat(3, Red_336, Green_336, Blue_336);
                subplot(3, 5, 10);
                imshow(C_336, [])
                title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                
            else
                subplot(3, 5, 10);
                imshow(Diff_I_Edge, [])
                title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
            end
            %**********************************************************************
            %**********************************************************************
            %*********** subplot(3, 5, 15) ***************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 5, 15)
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
                subplot(3, 5, 15);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
                
            end
            %**********************************************************
            %**********************************************************
            %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==7   %Save Work
            %SAVE_WORK = burnedImage;
            Reference_Mask = burnedImage;      % reference mask
            imwrite(Reference_Mask, [Subfolder_path_and_name,['\Mask_', FileName_ground_truth]], 'tif', 'Compression','none')
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
                    %             subplot(3, 5, [1, 2, 6, 7, 11, 12]);
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
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    imshow(C, [])
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                    
                catch
                    continue
                end
                
            else
                Fuse_I = imread(Fuse_fileNames);
                ground_truth = ground_truth;
                %             subplot(3, 5, [1, 2, 6, 7, 11, 12]);
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
                subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                imshow(C, [])
                title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                
                
            end
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        
        if choice ==9 % for Active Contour
            %edit1_val_num = 3;
            
            prompt={'Enter a number of vertix rate (3 = 1 vertex per pixel) '};
            name = 'Theta Value';
            defaultans = {'3'};  %default
            options.Interpreter = 'tex';
            answer = inputdlg(prompt,name,[3 40],defaultans,options);
            SMOOTH_RATE = str2num(answer{1,1});
            
            BW = burnedImage;
            
            imshow(ground_truth, []);
            hold on
            [xCenter, yCenter] = ginput(1);
            hold off
            Obj = bwselect(BW,xCenter,yCenter,4);
            %Obj = Select_Obj(BW);    % Selected Object
            %fuse the selected object with the ground truth
            Z = im2uint8(Obj);  %need to change the binary image to uint8 for fusing
            C = imfuse(Z, ground_truth,'diff','Scaling','joint');
            imshow(C, []);
            
            Obj = imresize(Obj, 3,'nearest');
            B = bwboundaries(Obj, 8);
            b = B{1};
            b = (b + 1)/3;
            b_smooth = b(1:SMOOTH_RATE:end,:); %contour rate defult is 2 because the size of the image was upsampled by 2
            Xx = b_smooth(:, 1);
            Yy = b_smooth(:, 2);
            poly = [Yy, Xx];
            hx = impoly(gca, poly);
            wait(hx);
            NEW_maskImage = hx.createMask();
            
            %************** New  *********************
            BW = im2bw(BW);
            Clean_ROI = imadd(NEW_maskImage, BW);
            Clean_ROI = im2bw(Clean_ROI);
            % find the contour of the corrected Obj
            str_element = strel('disk',1, 8);
            Contour_Dil = imdilate(NEW_maskImage,str_element);
            Contour = imabsdiff(NEW_maskImage, Contour_Dil);
            cont = ~Contour;
            Corrected_Memb = immultiply(cont,Clean_ROI);
            burnedImage = Corrected_Memb;
            
            subplot(3, 5, 15);
            imshow(burnedImage, [])
            BW = ~burnedImage;
            
            
            BW_RGB = cat(3, BW, BW, BW);
            BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
            
            GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
            GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
            
            Red = (1-BW_RGB).*GT_RGB + BW_RGB;
            Green = (1-BW_RGB).*GT_RGB;
            Blue = (1-BW_RGB).*GT_RGB;
            
            C = cat(3, Red, Green, Blue);
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==11  % Draw a single point
            line_type = 'impoint';
            line_type = str2func(line_type);
            
            lineCount = lineCount + 1;
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            hLine = line_type(gca);
            caption = sprintf('Draw here.  Currrent Image with %d interface.', lineCount);
            title(caption, 'FontSize', fontSize);
            singleLineBinaryImage = hLine.createMask();
            Both_Image = imadd(~burnedImage, singleLineBinaryImage);
            Both_Image = im2bw(Both_Image);
            
            burnedImage = ~Both_Image;
            
            
            %********************************************
            %*********** subplot(3, 5, 10) ***************
            %Show any broken edge available
            
            I_Subplot336 = ~burnedImage;
            subplot(3, 5, 10)
            I_Edge = bwmorph(I_Subplot336, 'spur', inf);
            Diff_I_Edge = imabsdiff(I_Subplot336, I_Edge);
            [NN LL] = bwlabel(Diff_I_Edge, 4);
            if LL >=1
                BW_336 = Diff_I_Edge;
                BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                C_336 = cat(3, Red_336, Green_336, Blue_336);
                subplot(3, 5, 10);
                imshow(C_336, [])
                title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                
            else
                subplot(3, 5, 10);
                imshow(Diff_I_Edge, [])
                title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, 15) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 5, 15)
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
                subplot(3, 5, 15);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]) ************
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==12  %Clean Image,  from 1- Unconnected edges followed by 2- single isolated pis
            I = ~burnedImage;
            s = [10,10];  %pad the image
            I = padarray(I,s,0,'both');
            burned_I = bwmorph(I, 'thin', Inf); %Thin
            burned_I = bwmorph(burned_I, 'spur', Inf);  %4-spur removal
            burnedImage = bwmorph(burned_I, 'clean'); % 5-clean the image from isolated single pixels
            burnedImage = burnedImage(1+s(1):end-s(1),1+s(2):end-s(2)); % remove the padding
            
            burnedImage = RemoveSingelPixelObject(burnedImage);
            
            burnedImage = ~burnedImage;
            
            %**********************************************************************
            %********************************************
            %*********** subplot(3, 5, 10) ***************
            %Show any broken edge available
            I_Subplot336 = burnedImage;
            
            I_Edge = bwmorph(I_Subplot336, 'spur', inf);
            
            Diff_I_Edge = imabsdiff(burnedImage, I_Edge);
            Diff_I_Edge = im2bw(Diff_I_Edge);
            
            [NN LL] = bwlabel(Diff_I_Edge, 4);
            if LL >=1
                BW_336 = Diff_I_Edge;
                BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                C_336 = cat(3, Red_336, Green_336, Blue_336);
                subplot(3, 5, 10);
                imshow(C_336, [])
                title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                
            else
                subplot(3, 5, 10);
                imshow(Diff_I_Edge, [])
                title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
            end
            %**********************************************************************
            %**********************************************************************
            %*********** subplot(3, 5, 15) ***************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 5, 15)
            I_Point = bwmorph(I_Subplot339, 'clean');
            Diff_I_Point = imabsdiff(I_Subplot339, I_Point);
            Diff_I_Point = im2bw(Diff_I_Point);
            
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
                subplot(3, 5, 15);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
                
            end
            %**********************************************************
            %**********************************************************
            %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        %**********************************************************************
        %**********************************************************************
        
        if choice ==14  %Free Hand Draw
            f.GraphicsSmoothing = 'off';
            opengl software
            %set (gcf, 'WindowButtonMotionFcn', {@mouseMove2, handles}); %show live mouse motion
            
            try
                
                I = ground_truth;
                AX = subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                
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
                    
                    New_Zer = imadd(Zer, Zer_Line);
                    New_Zer = imbinarize(New_Zer);
                    New_Zer = bwmorph(New_Zer, 'thin', inf);
                    
                    Zer = New_Zer;
                end
                
                F = New_Zer;
                
                burnedImage = ~burnedImage;
                Both = imadd(F, burnedImage);
                
                corrected = ~Both;
                BW_corrected = im2bw(corrected);
                burnedImage = BW_corrected;
                
                %********************************************
                %*********** subplot(3, 5, 10) ***************
                
                %Show any broken edge available
                
                I_Subplot336 = ~burnedImage;
                subplot(3, 5, 10)
                I_Edge = bwmorph(I_Subplot336, 'spur', inf);
                Diff_I_Edge = imabsdiff(I_Subplot336, I_Edge);
                [NN LL] = bwlabel(Diff_I_Edge, 4);
                if LL >=1
                    BW_336 = Diff_I_Edge;
                    BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                    BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                    GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                    GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                    Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                    Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                    Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                    C_336 = cat(3, Red_336, Green_336, Blue_336);
                    subplot(3, 5, 10);
                    imshow(C_336, [])
                    title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                    
                else
                    subplot(3, 5, 10);
                    imshow(Diff_I_Edge, [])
                    title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
                end
                
                %**********************************************************
                %*********** subplot(3, 5, 15) *****************************
                %Show any single pixel available
                
                I_Subplot339 = ~ burnedImage;
                subplot(3, 5, 15)
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
                    subplot(3, 5, 15);
                    imshow(Diff_I_Point, [])
                    title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
                end
                
                %**********************************************************
                %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
                subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                imshow(C, [])
                title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                
                
            catch
                
                try
                    f.GraphicsSmoothing = 'off';
                    opengl software
                    I = ground_truth;
                    AX = subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    %imshow(I);  %original raw image
                    M = imfreehand(AX,'Closed',0);
                    BWW = false(size(M.createMask));
                    P0 = M.getPosition;
                    D = ([0; cumsum(sum(abs(diff(P0)),2))]);
                    P = interp1(D,P0,D(1):.1:D(end),  'linear');
                    P = unique(round(P),'rows');
                    S = sub2ind(size(I),P(:,2),P(:,1));
                    BWW(S) = true;
                    
                    SSE =  strel('square',1);
                    BWW = imdilate(BWW, SSE);
                    
                    BWW = bwmorph(BWW, 'thin', inf);   
                    
                    burnedImage = ~burnedImage;
                    Both = imadd(BWW, burnedImage);
                    
                    corrected = ~Both;
                    BW_corrected = im2bw(corrected);
                    burnedImage = BW_corrected;
                    %********************************************
                    %*********** subplot(3, 5, 10) ***************
                    %Show any broken edge available
                    
                    I_Subplot336 = ~burnedImage;
                    subplot(3, 5, 10)
                    I_Edge = bwmorph(I_Subplot336, 'spur', inf);
                    Diff_I_Edge = imabsdiff(I_Subplot336, I_Edge);
                    [NN LL] = bwlabel(Diff_I_Edge, 4);
                    if LL >=1
                        BW_336 = Diff_I_Edge;
                        BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                        BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                        GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                        GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                        Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                        Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                        Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                        C_336 = cat(3, Red_336, Green_336, Blue_336);
                        subplot(3, 5, 10);
                        imshow(C_336, [])
                        title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
                        
                    else
                        subplot(3, 5, 10);
                        imshow(Diff_I_Edge, [])
                        title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
                    end
                    
                    %**********************************************************
                    %*********** subplot(3, 5, 15) *****************************
                    %Show any single pixel available
                    
                    I_Subplot339 = ~ burnedImage;
                    subplot(3, 5, 15)
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
                        subplot(3, 5, 15);
                        imshow(Diff_I_Point, [])
                        title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
                    end
                    
                    %**********************************************************
                    %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    imshow(C, [])
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                catch
                    
                    
                    %waitfor(msgbox('Failed again. Please try again from the begining.'));
                    
                    %**************************************************************
                    %********** Show the currently available membrane *************
                    %**************************************************************
                    
                    title('Segmented Membrane', 'FontSize', fontSize);
                    %change it to RED lines
                    BW = ~burnedImage;
                    
                    BW_RGB = cat(3, BW, BW, BW);
                    BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
                    
                    GT_RGB = cat(3, ground_truth, ground_truth, ground_truth);
                    GT_RGB = double(GT_RGB(:,:,1))./double(max(GT_RGB(:)));
                    
                    Red = (1-BW_RGB).*GT_RGB + BW_RGB;
                    Green = (1-BW_RGB).*GT_RGB;
                    Blue = (1-BW_RGB).*GT_RGB;
                    
                    C = cat(3, Red, Green, Blue);
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    imshow(C, [])
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                    continue  % Break out to the while loop
                    
                end
                
            end
            
        end
        
        %**************************************************************************
        %**************************************************************************
        
        if choice ==15  %Eraser
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            I = burnedImage;
            %imshow(I);
            Z = im2uint8(I);
            style = 'imfreehand';
            eraser_type = str2func(style);
            
            %**************************************************************
            
            I = im2bw(I);
            hx = eraser_type(gca);
            addNewPositionCallback(hx,@(p) title(mat2str(p,3)));
            fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),...
                get(gca,'YLim'));
            setPositionConstraintFcn(hx,fcn);
            wait(hx);
            maskImage = hx.createMask();
            inv_maskImage = ~maskImage;
            
            add = immultiply(inv_maskImage, ~I);
            add = im2bw(add);
            burnedImage = ~add;
            
            
            %********************************************
            %*********** subplot(3, 5, 10) ***************
            %Show any broken edge available
            
            I_Subplot336 = ~burnedImage;
            subplot(3, 5, 10)
            I_Edge = bwmorph(I_Subplot336, 'spur', inf);
            Diff_I_Edge = imabsdiff(I_Subplot336, I_Edge);
            [NN LL] = bwlabel(Diff_I_Edge, 4);
            if LL >=1
                BW_336 = Diff_I_Edge;
                BW_RGB_336 = cat(3, BW_336, BW_336, BW_336);
                BW_RGB_336 = double(BW_RGB_336(:,:,1))./double(max(BW_RGB_336(:)));
                GT_RGB_336 = cat(3, ground_truth, ground_truth, ground_truth);
                GT_RGB_336 = double(GT_RGB_336(:,:,1))./double(max(GT_RGB_336(:)));
                Red_336 = (1-BW_RGB_336).*GT_RGB_336 + BW_RGB_336;
                Green_336 = (1-BW_RGB_336).*GT_RGB_336;
                Blue_336 = (1-BW_RGB_336).*GT_RGB_336;
                C_336 = cat(3, Red_336, Green_336, Blue_336);
                subplot(3, 5, 10);
                imshow(C_336, [])
                title('ERROR: Broken edge was found. Please correct it now','FontSize', fontSize, 'Color', 'r');
            else
                subplot(3, 5, 10);
                imshow(Diff_I_Edge, [])
                title('OK: No broken edge found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, 15) *****************************
            %Show any single pixel available
            
            I_Subplot339 = ~ burnedImage;
            subplot(3, 5, 15)
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
                subplot(3, 5, 15);
                imshow(Diff_I_Point, [])
                title('OK: No single pixel found','FontSize', fontSize, 'Color', 'g');
            end
            
            %**********************************************************
            %*********** subplot(3, 5, [1, 2, 6, 7, 11, 12]); ************
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
            subplot(3, 5, [1, 2, 6, 7, 11, 12]);
            imshow(C, [])
            title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
            
        end
        
        %**************************************************************************
        %**************************************************************************
        
        if choice ==16    %Exit
            
            break
            
        end
        
    end
end

I = BW;
end


