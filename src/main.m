function main()

    srcImagesFolder = '..\..\testingImages\'; 
    srcImagesFiles = dir(strcat(srcImagesFolder, '*_panorama.jpg'));
    imageNames = {srcImagesFiles.name};
    numImages = numel(imageNames);
    image = imread(strcat(srcImagesFolder, srcImagesFiles(1).name));
    
    images = zeros([size(image) numImages], class(image));
    
    for i = 1 : numImages
        images(:,:,:,i) = imread(strcat(srcImagesFolder, srcImagesFiles(i).name));
    end

    cylImages = cylinderProjection(images, numImages, 595);
    
    offsets = zeros(1,2);
    x_offset_total = 0;
    y_offset_total = 0;
    
    for i = 1 : numImages
        if(i < numImages)
            H = match(cylImages(:,:,:,i+1), cylImages(:,:,:,i), 4, 500);
            offsets(i,:) = [H(1,3), H(2,3)];
        else
            H = match(cylImages(:,:,:,1), cylImages(:,:,:,i), 4, 500);
            offsets(i,:) = [H(1,3), H(2,3)];
        end
        
        x_offset_total = x_offset_total + offsets(i,1);
        y_offset_total = x_offset_total + offsets(i,2);
    end
    
    x_offset = floor(H(1,3));
    y_offset = floor(H(2,3));
    new_image = uint8(zeros(size(image,1)+y_offset_total,2*size(image,2)+x_offset_total,3));
%     image2 = cylImages(:,:,:,5);
%     image1 = cylImages(:,:,:,4);
%     x_limit = size(image,2) + x_offset;
%     y_limit = size(image,1) + y_offset;
%     
%    	for x = 1 : size(new_image,2)
%        for y = 1 : size(new_image,1)
%            if(x > x_limit)
%                 if(y > y_offset)
%                     new_image(y,x,:) = image1(y-y_offset,x-x_limit,:);
%                 end
%            else
%                if(y <= size(image2,1))
%                     new_image(y,x,:) = image2(y,x,:);
%                end
%            end
%        end
%     end
    
    figure, imshow(new_image);
end

