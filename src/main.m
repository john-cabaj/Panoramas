function main()

    srcImagesFolder = '..\..\department\'; 
    srcImagesFiles = dir(strcat(srcImagesFolder, '*.jpg'));
    imageNames = {srcImagesFiles.name};
    numImages = numel(imageNames);
    image = imread(strcat(srcImagesFolder, srcImagesFiles(1).name));
    
    images = zeros([size(image) numImages], class(image));
    
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
%         else
%             H = match(cylImages(:,:,:,i), cylImages(:,:,:,1), 4, 1000);
%             offsets(i,:) = [H(1,3), H(2,3)];
%         end
        
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
    
    for i = 1 : numImages
        image = cylImages(:,:,:,i);
        
        for x = x_ranges(i,1) : x_ranges(i,2)
           for y = y_ranges(i,1) : y_ranges(i,2)
                panorama(y,x,:) = image(y - y_ranges(i,1) + 1,x - x_ranges(i,1) + 1,:);
           end
        end
    end
    
    figure, imshow(panorama);
end

