function main()

    srcImagesFolder = '..\..\testingImages\'; 
    srcImagesFiles = dir(strcat(srcImagesFolder, '*_panorama.jpg'));
    imageNames = {srcImagesFiles.name};
    numImages = numel(imageNames);
    image = imread(strcat(srcImagesFolder, srcImagesFiles(1).name));
    
    images = zeros([size(image) numImages], class(image));
    images(:,:,:,1) = image;
    
    for i = 2 : numImages
        images(:,:,:,i) = imread(strcat(srcImagesFolder, srcImagesFiles(i).name));
    end

    cylImages = cylinderProjection(images, numImages, 595);
    
    match(cylImages(:,:,:,1), cylImages(:,:,:,2));
end

