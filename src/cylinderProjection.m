function cylImages = cylinderProjection(images, numImages, focalLength)

    cylImages = zeros([size(images(:,:,:,1)) numImages], class(images(:,:,:,1)));
    
    for i = 1 : numImages
        image = images(:,:,:,i);
        x_c = size(image, 2) / 2;
        y_c = size(image, 1) / 2;
        
        for x = 1 : size(image, 2)
            for y = 1 : size(image, 1)
                x_b = focalLength * atan((x - x_c) / focalLength) + x_c;
                y_b = focalLength * (y - y_c) / sqrt((x - x_c)^2 + focalLength^2) + y_c;
               
                cylImages(round(y_b),round(x_b),:,i) = image(y,x,:);
            end
        end
    end
    
end

