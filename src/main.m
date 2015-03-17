function main()

    srcImagesFolder = '..\..\testingImages\'; 
    srcImagesFiles = dir(strcat(srcImagesFolder, '*.jpg'));
    imageNames = {srcImagesFiles.name};
    numImages = numel(imageNames);
    image = imread(strcat(srcImagesFolder, srcImagesFiles(1).name));
    
    images = zeros([size(image) numImages + 1], class(image));
    
    for i = 1 : numImages
        images(:,:,:,i) = imread(strcat(srcImagesFolder, srcImagesFiles(i).name));
    end
    
    cylImages = cylinderProjection(images, numImages, 595);
    
    offsets = zeros(1,2);
    x_ranges = ones(1,2);
    y_ranges = ones(1,2);
    x_offset_total = 0;
    y_offset_total = 0;
    up_growth = 0;
    down_growth = 0;
    
    for i = 1 : numImages - 1
        H = match(cylImages(:,:,:,i), cylImages(:,:,:,i+1), 4, 1000);
        
        offsets(i+1,:) = [H(1,3), H(2,3)];
        x_ranges(i,2) = x_offset_total + size(image, 2) + round(offsets(i+1,1));
        x_ranges(i+1,1) = x_ranges(i,2) + 1;
        x_offset_total = x_ranges(i,2);
        y_offset_total = y_offset_total + abs(round(offsets(i+1,2)));
        if(round(offsets(i+1,2)) > 0)
           down_growth = down_growth + abs(round(offsets(i+1,2)));
        else
           up_growth = up_growth + abs(round(offsets(i+1,2)));
        end
    end

    x_offset_total = x_offset_total + size(image,2);
    y_offset_total = y_offset_total + size(image,1);
    x_ranges(size(x_ranges,1),2) = x_offset_total;
    panorama = uint8(zeros(y_offset_total,x_offset_total,3));
    
    y_ranges(1,1) = up_growth + 1;
    y_ranges(1,2) = y_ranges(1,1) + size(image,1) - 1;
    
    for i = 2 : size(offsets,1)
       y_ranges(i,1) = y_ranges(i-1,1) + round(offsets(i,2)); 
       y_ranges(i,2) = y_ranges(i,1) + size(image,1) - 1; 
    end
    
    prev_x = 0;
    
    for i = 1 : numImages - 1
        image1 = cylImages(:,:,:,i);
        image2 = cylImages(:,:,:,i+1);
        
%         for x = x_ranges(i,1) : x_ranges(i,2)
%            for y = y_ranges(i,1) : y_ranges(i,2)
%                 panorama(y,x,:) = image(y - y_ranges(i,1) + 1,x - x_ranges(i,1) + 1,:);
%            end
%         end

        for x = 1 + abs(round(offsets(i,1))) : size(image1,2) - abs(round(offsets(i+1,1)))
           for y = 1 : size(image1,1)
                panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,:) = image1(y,x,:);
           end
        end
        
        prev_x = x;
        
        if(y_ranges(i,1) < y_ranges(i+1,1))
            for x = prev_x + 1 : size(image1,2)
               for y = 1 : y_ranges(i+1,2)
                    overlap = abs(round(offsets(i+1,1)));
                    distance1 = abs(x - prev_x - 1);
                    distance2 = abs(size(image1,2) - x + 1);
                    alpha1 = (overlap - distance1) / overlap;
                    alpha2 = (overlap - distance2) / overlap;
                    if(y < y_ranges(i+1,1))
                        weight1 = 1;
                        alpha1 = 1;
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = weight1*alpha1*image1(y,x,1);
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = weight1*alpha1*image1(y,x,2);
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = weight1*alpha1*image1(y,x,3);
                    elseif(y > size(image1,1))
                        weight2 = 1;
                        alpha2 = 1;
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = weight2*alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,1);
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = weight2*alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,2);
                        panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = weight2*alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,3);
                    else
                        weight1 = weight(image1(y,x,:));
                        weight2 = weight(image2(y-y_ranges(i+1,1)+1,x-prev_x+1,:));
                        if(weight1 ~= 0 && weight2 ~= 0)
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = alpha1*image1(y,x,1) ...
                                + alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,1);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = alpha1*image1(y,x,2) ...
                                + alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,2);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = alpha1*image1(y,x,3) ...
                                + alpha2*image2(y-y_ranges(i+1,1)+1,x-prev_x+1,3);
                        elseif(weight1 ~= 0)
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = image1(y,x,1);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = image1(y,x,2);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = image1(y,x,3);
                        elseif(weight2 ~= 0)
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = image2(y-y_ranges(i+1,1)+1,x-prev_x+1,1);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = image2(y-y_ranges(i+1,1)+1,x-prev_x+1,2);
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = image2(y-y_ranges(i+1,1)+1,x-prev_x+1,3);
                        else
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,1) = 0;
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,2) = 0;
                            panorama(y_ranges(i,1)+y-1,x_ranges(i,1)+x-1,3) = 0;
                        end
                    end
               end
            end
        else
            
        end
    end
    
    figure, imshow(panorama);
end

