function homography = ransac(image1, image2)

% Find SIFT keypoints for each image
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

ind=find(match);
r_match(:,1)=ind;
r_match(:,2)=match(ind);

non_zero_indices = find(match);
max_c = 0;
max_inlier_points = zeros(1,2);
max_inlier_projs = zeros(1,2);
		
result=0;
for K=1:100
    r_value=rand(1);
    r_index=floor(r_value*size(r_match,1));
    if r_index==0
        r_index=1;
    end
    x=floor(loc1(r_match(r_index,1),1));
    y=floor(loc1(r_match(r_index,1),2));
    xprime=floor(loc2(r_match(r_index,2),1));
    yprime=floor(loc2(r_match(r_index,2),2));
    
    x_j=floor(loc1(non_zero_indices(r_index),1));
    y_j=floor(loc1(non_zero_indices(r_index),2));
    xprime_j=floor(loc2(match(non_zero_indices(r_index)),1));
    yprime_j=floor(loc2(match(non_zero_indices(r_index)),2));
    
    count=0;l=1;
    H=[1 0 xprime-x;0 1 yprime-y;0 0 1];
    H_j=[1 0 xprime_j-x_j;0 1 yprime_j-y_j;0 0 1];
    
    
   c = 0;
   inlier_points = zeros(1,2);
   inlier_projs = zeros(1,2);
   inlier_point = zeros(3,1);
   inlier_proj = zeros(3,1);
   
    for j=1:size(r_match,1)
       Hdash=H*[loc1(r_match(j,1),1) loc1(r_match(j,1),2) 1]';
       Hdash_j=H_j*[loc1(non_zero_indices(j),1),loc1(non_zero_indices(j),2),1]';
       
       ssd=(loc2(r_match(j,2),1)-Hdash(1))^2+(loc2(r_match(j,2),2)-Hdash(2))^2;
       ssd_j=(loc2(match(non_zero_indices(j)),1) - Hdash_j(1))^2 + (loc2(match(non_zero_indices(j)),2) - Hdash_j(2))^2;
            if(ssd<0.6) 
                count=count+1;
                p(l,1)=loc1(r_match(j,1),1);
                p(l,2)=loc1(r_match(j,1),2);
				pprime(l,1)=loc2(r_match(j,2),1);
				pprime(l,2)=loc2(r_match(j,2),2);
                l=l+1;
            end
    end
       if result<count
          result=count;
          Hprime=H;
          p_inliers=p;
		  pprime_inliers=pprime;
         
       end
end

p_inliers(:,3)=1;
pprime_inliers(:,3)=1;
h=pprime_inliers\p_inliers;
homography=h';

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);cols1 = size(im1,2);
for i = 1: result
    line([p_inliers(i,2) pprime_inliers(i,2)+cols1], ...
         [p_inliers(i,1) pprime_inliers(i,1)], 'Color', 'c');
end
hold off;
num = sum(match > 0);
fprintf('Found %d matches.\n', num);