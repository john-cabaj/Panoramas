% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');

function H = match(image1, image2, sample_num, k)

% Find SIFT keypoints for each image
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
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

non_zero_indices = find(match);
max_c = 0;
max_inlier_points = zeros(1,2);
max_inlier_projs = zeros(1,2);

for i = 1 : k
   p1 = zeros(1,2);
   p2 = zeros(1,2);
    
   samples = randsample(non_zero_indices, sample_num);
   
   for j = 1 : sample_num
        p1(j,:) = [loc1(samples(j),2),loc1(samples(j),1)];
        p2(j,:) = [loc2(match(samples(j)),2),loc2(match(samples(j)),1)];
   end
   
   H = homography(p1,p2);
   c = 0;
   inlier_points = zeros(1,2);
   inlier_projs = zeros(1,2);
   inlier_point = zeros(3,1);
   inlier_proj = zeros(3,1);
   
   for k = 1 : size(non_zero_indices, 2)
           inlier_point(:,1) = [loc1(non_zero_indices(k),2),loc1(non_zero_indices(k),1),1];
           inlier_proj(:,1) = [loc2(match(non_zero_indices(k)),2),loc2(match(non_zero_indices(k)),1),1];
           
           proj = H*inlier_point;
           ssd = (inlier_proj(1) - proj(1))^2 + (inlier_proj(2) - proj(2))^2;
          
           if(ssd < 0.6)  
               c = c+1;
               if(c == 1)
                    inlier_points(1,:) = inlier_point(1:2,1);
                    inlier_projs(1,:) = inlier_proj(1:2,1);
               else
                   new_row = [inlier_point(1,1),inlier_point(2,1)];
                   inlier_points = [inlier_points; new_row];
                   new_row = [inlier_proj(1,1),inlier_proj(2,1)];
                   inlier_projs = [inlier_projs; new_row];
               end
           end
   end
   
   if(c > max_c)
      max_c = c;
      max_inlier_points = inlier_points;
      max_inlier_projs = inlier_projs;
   end
end

H = homography(max_inlier_points,max_inlier_projs);

% % Create a new image showing the two images side by side.
% im3 = appendimages(im1,im2);
% 
% % Show a figure with lines joining the accepted matches.
% figure('Position', [100 100 size(im3,2) size(im3,1)]);
% colormap('gray');
% imagesc(im3);
% hold on;
% cols1 = size(im1,2);cols1 = size(im1,2);
% for i = 1: size(max_inlier_points,1)
%     line([max_inlier_points(i,1) max_inlier_projs(i,1)+cols1], ...
%          [max_inlier_points(i,2) max_inlier_projs(i,2)], 'Color', 'c');
% end
% hold off;
% num = sum(match > 0);
fprintf('Found %d matches.\n', max_c);




