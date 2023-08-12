clear
clc
close all

% Choose sample
ind = 4;

% 0 = horizontal, 1 = vertical
key = 1;

% percent of reduction
percent = 25;

% Define file paths
a = dir("/Users/macbook/Documents/answers/ComputerVisionProjects-main/SeamCarvingmethod/SamplesDataset/");
path = [a(ind).folder '/' a(ind).name '/'];
b = dir(path);
img_loc = [path b(6).name];
smap_loc = [path b(7).name];
dmap_loc = [path b(4).name];
grad_loc = [path b(5).name];
yolo_loc = [path b(8).name];

% Read images
img = imread(img_loc);
smap = im2double(imread(smap_loc));
dmap = im2double(imread(dmap_loc));
gmap = im2double(rgb2gray(imread(grad_loc)));
yolo = imread(yolo_loc);

% Convert yolo image to binary
yolo_binary = yolo;
yolo_binary(yolo_binary == img) = 0;
yolo_binary(yolo_binary ~= 0) = 255;
yolo_binary = rgb2gray(im2double(yolo_binary));

% Normalize images
smap = normalizeImage(smap);
dmap = normalizeImage(dmap);
gmap = normalizeImage(gmap);
yolo_binary = normalizeImage(yolo_binary);

% Save original image
og_img = img;

% Set parameters
iters = floor(size(img, 1) * (percent / 100));
gmap_imp = 0.2;
% rate of depth importance, between 1 to 4
if key == 1
    depth_imp = 0.5;
    gmap_imp = 0.3;
else
    depth_imp = 4;
end

% rate of edge importance, between 1 to 4
edge_imp = 4;


% Rotate images if key is 1 (vertical)
if key == 1
    img = imrotate(img, 90);
    smap = imrotate(smap, 90);
    dmap = imrotate(dmap, 90);
    gmap = imrotate(gmap, 90);
    yolo_binary = imrotate(yolo_binary, 90);
    iters = floor(size(img, 2) * (percent / 100));
end

tic
for p = 1:iters
    [r, c, ~] = size(img);
    imshow(img)
    
    % Calculate importance matrix
    h = imgradient(rgb2gray(img), 'sobel');
    v = imgradient(rgb2gray(img), 'prewitt');
    impmat = v + h;
    impmat = edge_imp * normalizeImage(impmat) + depth_imp * dmap + gmap_imp * gmap + 0.4 * yolo_binary + smap;
    
    % Calculate cost matrix
    cost = zeros(r, c);
    cost(1, :) = impmat(1, :);
    for i = 2:r
        for j = 1:c
            cost(i, j) = min([cost(i-1, max(j-1, 1)), cost(i-1, j), cost(i-1, min(j+1, c))]) + impmat(i, j);
        end
    end
    
    % Find min cost from bottom row
    [~, miny] = min(cost(r, :));
    
    % Find min cost path till the top and shift cells accordingly
    for i = r:-1:1
        upminy = cost(max(i-1, 1), max(miny-1, 1));
        mincost = inf;
        for j = max(miny-1, 1):min(miny+1, c)
            if i == 1
                break;
            end
            if cost(i-1, j) < mincost
                mincost = cost(i-1, j);
                upminy = j;
            end
        end
        img(i, miny:end-1, :) = img(i, miny+1:end, :);
        smap(i, miny:end-1, :) = smap(i, miny+1:end, :);
        dmap(i, miny:end-1, :) = dmap(i, miny+1:end, :);
        gmap(i, miny:end-1, :) = gmap(i, miny+1:end, :);
        yolo_binary(i, miny:end-1, :) = yolo_binary(i, miny+1:end, :);
        miny = upminy;
    end
    
    img = img(:, 1:c-1, :);
    smap = smap(:, 1:c-1, :);
    dmap = dmap(:, 1:c-1, :);
    gmap = gmap(:, 1:c-1, :);
    yolo_binary = yolo_binary(:, 1:c-1, :);
end
timeTaken = toc;

disp(timeTaken);

if key == 1
    img = imrotate(img, -90);
    impmat = imrotate(impmat, -90);
end

% Display the final resized image
figure;
subplot(1,3,1);
imshow(im2double(og_img), []);
title('Original Image');
subplot(1,3,2);
imshow(im2double(img), []);
title('Resized Image');
subplot(1,3,3);
imshow(impmat, []);
title('Energy Map');

% Helper function to normalize the image
function normalized = normalizeImage(img)
    normalized = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end
