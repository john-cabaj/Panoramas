function main()

    srcImagesFolder = '..\..\engineeringHall\'; 
    srcImagesFiles = dir(strcat(srcImagesFolder, '*.jpg'));
    imageNames = {srcImagesFiles.name};
    numImages = numel(imageNames);
    image = imread(strcat(srcImagesFolder, srcImagesFiles(1).name));
    
    images = zeros([size(image) numImages + 1], class(image));
    
    for i = 1 : numImages
        images(:,:,:,i) = imread(strcat(srcImagesFolder, srcImagesFiles(i).name));
    end
    
    cylImages = cylinderProjection(images, numImages, 682.05069);
    
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
       y_ranges(i,1) = y_ranges(i-1,1) - 1 + round(offsets(i,2)); 
       y_ranges(i,2) = y_ranges(i,1) + size(image,1) - 1; 
    end
    
    image = cylImages(:,:,:,1);
    for x = 1 : size(image,2)
        for y = 1 : size(image,1)
           panorama(y_ranges(1,1)+y,x_ranges(1,1)+x,:) = image(y,x,:); 
        end
    end
    
    
    for i = 2 : numImages
        image = cylImages(:,:,:,i); 
        
        for x = 1 : size(image,2)
            for y = 1 : size(image,1)
                if(x < abs(round(offsets(i,1))))
                    weight1 = weight(panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,:));
                    weight2 = weight(image(y,x,:));
                    overlap = abs(round(offsets(i,1)));
                    distance1 = x;
                    distance2 = abs(overlap - x);
                    alpha1 = (overlap - distance1) / overlap;
                    alpha2 = (overlap - distance2) / overlap;
                    
                    if(weight1 ~= 0 && weight2 ~= 0)
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1) = alpha1 * panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1) ...
                            + alpha2 * image(y,x,1);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2) = alpha1 * panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2) ...
                            + alpha2 * image(y,x,2);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3) = alpha1 * panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3) ...
                            + alpha2 * image(y,x,3);
                    elseif(weight1 ~= 0)
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1) = panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2) = panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3) = panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3);
                    elseif(weight2 ~= 0)
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1) = image(y,x,1);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2) = image(y,x,2);
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3) = image(y,x,3);
                    else
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,1) = 0;
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,2) = 0;
                        panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,3) = 0;
                    end
                else
                    panorama(y_ranges(i,1)+y,x_ranges(i,1)+x,:) = image(y,x,:); 
                end
            end
        end
    end
    
    figure, imshow(panorama);
end

