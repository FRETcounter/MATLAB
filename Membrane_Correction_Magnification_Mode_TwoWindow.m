function burnedImage = Membrane_Correction_Magnification_Mode_TwoWindow(cumulativeBinaryImage, Dilate_GT, burnedImage, ground_truth, Fuse_I, FileName_ground_truth)
fontSize = 10;
f.GraphicsSmoothing = 'off';
opengl software

%Use KeyBoardShortCut.m to find the reference number of a keyboard key

while 1 == 1
    w = waitforbuttonpress;
    try
        switch w
            case 1 % keyboard
                key = get(gcf,'currentcharacter');
                
                
                if key==27 % (the Esc key)
                    burnedImage = burnedImage;
                    break
                    
                    
                elseif key==32   %Space key  (free hand draw)
                    f.GraphicsSmoothing = 'off';
                    opengl software
                    
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
                            
                            %                 SE = strel('square', 3);
                            %                 Zer_Line = imdilate(Zer_Line, SE);
                            
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
                            subplot(3, 5, 10);
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
                            
                            BWW = bwmorph(BWW, 'thin', inf);   % added 20 Sep. 2016
                            
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
                    
                    
                elseif key==122   % z key used to erase a region
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
                    
                    
                    
                elseif key== 104  %H key hide membrane
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    imshow(Dilate_GT, []);
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                elseif key==103  %G keyboard will show the membrane again
                    title('Segmented Membrane', 'FontSize', fontSize);
                    %change it to RED lines
                    BW = ~burnedImage;
                    
                    %Added to avoide missing pixels
                    se = strel('disk',0, 8);
                    %BW = bwmorph(BW, 'thin', Inf);
                    %BW = bwmorph(BW, 'spur', Inf);
                    BW = imdilate(BW, se);%************** 1st time
                    
                    
                    BW_RGB = cat(3, BW, BW, BW);
                    BW_RGB = double(BW_RGB(:,:,1))./double(max(BW_RGB(:)));
                    
                    Dilate_GT_RGB = cat(3, Dilate_GT, Dilate_GT, Dilate_GT);
                    Dilate_GT_RGB = double(Dilate_GT_RGB(:,:,1))./double(max(Dilate_GT_RGB(:)));
                    
                    Red = (1-BW_RGB).*Dilate_GT_RGB + BW_RGB;
                    Green = (1-BW_RGB).*Dilate_GT_RGB;
                    Blue = (1-BW_RGB).*Dilate_GT_RGB;
                    
                    C = cat(3, Red, Green, Blue);
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    imshow(C, [])
                    title(['Apply manual correction in this Image  ' FileName_ground_truth], 'FontSize', fontSize, 'Interpreter', 'none');
                    
                    
                    
                elseif key==98  %b key will do break and remove
                    style = 'imline';
                    eraser_type = str2func(style);
                    
                    BW = ~burnedImage;
                    
                    subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                    hx = eraser_type(gca);
                    addNewPositionCallback(hx,@(p) title(mat2str(p,3)));
                    fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),...
                        get(gca,'YLim'));
                    setPositionConstraintFcn(hx,fcn);
                    %wait(hx);
                    maskImage = hx.createMask();
                    se = strel('disk',1, 8);
                    %se = strel('square',2);  % never use. It will shift the image
                    maskImage = imdilate(maskImage, se);
                    maskImage = ~maskImage;
                    BW_with_Cut = immultiply(maskImage, BW);
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
                    %now remove any remaining spurs after the break (added 24 Nov. 2016)
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
                    
                    
                elseif key==109  %Press M to mark a region only (no action)
                    try
                        
                        line_type = 'imrect';
                        line_type = str2func(line_type);
                        
                        lineCount = lineCount + 1;
                        subplot(3, 5, [1, 2, 6, 7, 11, 12]);
                        hLine = line_type(gca);
                    end
                    
                elseif key==99  %Press C to clean the image
                    I = ~burnedImage;
                    s = [10,10];  %pad the image
                    I = padarray(I,s,0,'both');
                    burned_I = bwmorph(I, 'thin', Inf); %1-Thin
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
                    
                    
                elseif key==111   % o key used to show old mask
                    
                    if isempty(Fuse_I)
                        msgbox('No previous frame was selected');
                        break
                    else
                        
                        Fuse_I =  Fuse_I;
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
                
                
        end
        
        
        burnedImage = burnedImage;
        
    end
end

