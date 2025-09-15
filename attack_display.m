clc
close all
clear all

%% 直方图平移信息隐藏
%读入信息
size_1 = 2156;  % size_1 = 215;  size_2 = 383;
size_2 = 3836;
candidate_name = 'rocket_launcher';
% IMG_saliency = double(imread(['D:\X.W.Li materials\InIm鲁邦水印\ROI提取\Unet-EI图像提取\UNet_',candidate_name,'_20.jpg']));  % UNet_lung_11_20.jpg  % D:\X.W.Li materials\InIm医学水印\Cameraman.bmp
% IMG_saliency = imresize(IMG_saliency,[size_1,size_2],'nearest');
% min_val = min(IMG_saliency(:));  % 找到矩阵的最小值
% max_val = max(IMG_saliency(:));  % 找到矩阵的最大值
% IMG_saliency = uint8(round((IMG_saliency - min_val) / (max_val - min_val) * 255));
IMG = double(imresize((imread(['D:\X.W.Li materials\第三阶段\单目图像生成EIA\integral-imaging-pickup-ZHR\results\N77N137F2.8G3.1_',candidate_name,'\elemental_image_array.jpg'])),[size_1,size_2],'nearest'));
min_val = min(IMG(:));  % 找到矩阵的最小值
max_val = max(IMG(:));  % 找到矩阵的最大值
IMG = uint8(round((IMG - min_val) / (max_val - min_val) * 255));
% figure; imshow(uint8(IMG_saliency));
% title('IMG_saliency');
% figure; imshow(uint8(IMG));
% title('IMG');
% I_original=IMG;
% fid = fopen('D:\X.W.Li materials\InIm鲁邦水印\medical.txt', 'rt');
% [txt,txt_len] = fread(fid, inf, 'uint8'); 


%% Guassain filtering
sigma = 5;  % 设置高斯滤波的标准差
Gaussian_filtered = imgaussfilt(IMG, sigma,'FilterSize', 9);  % , 'FilterSize', 3: 3*3滤波
imwrite(Gaussian_filtered, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\Gaussian_filtered.png');
title('高斯滤波图像');


%% Guassain noise 
Gaussian_noised =  uint8(imnoise(double(IMG)/255, 'gaussian', 0, 0.1)*255);
imwrite(Gaussian_noised, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\Gaussian_noised.png');


%% cropping ROI
Cropped_value = 125;
ROI_cropped =  IMG;
ROI_cropped(1278:1718, 1278:1718, :) = Cropped_value;
imwrite(ROI_cropped, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\ROI_cropped.png');
size_1 = 2156;  % size_1 = 215;  size_2 = 383;
size_2 = 3836;

%% JPEG 
Embed_uint8 = IMG;
imwrite(Embed_uint8, 'compressed_image.jpg', 'jpg', 'Quality', 75);  % 将矩阵保存为 JPEG 格式，同时可以指定压缩质量. 75 是压缩质量
IMG_JPEG = imread('compressed_image.jpg'); % 读取并显示压缩后的图像
imwrite(IMG_JPEG, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\IMG_JPEG.png');

% [txt_out, Extracted_logo] = extract_watermark_dualSVD(IMG_JPEG, rows_LSB_interval_3, ...
%     cols_LSB_interval_3, rows_LSB_interval_4, cols_LSB_interval_4,rows_Max,...
%     cols_Max, end_number_LSB_3, end_number_LSB_4, end_number_Max,txtb, min_P_index,...
%     P, move, len, rows_RONI, cols_RONI, RONI_length, root_num, U1, V1,S,af, setLength_logo,...
%     Embedded_RONI, max_val, min_val);
% 
% disp(txt_out);
% subplot(2,2,4);
% imshow(uint8(Extracted_logo));
% title('JPEG压缩logo');

%% rescaling 
scale_factor = 0.5;  % 缩放比例（0.5表示缩小到原来的50%）
Embed_rescaled = imresize(IMG, scale_factor);
new_size = [size_1, size_2];  % 将矩阵重新缩放到200x200的大小
IMG_Rescaling = imresize(Embed_rescaled, new_size);
imwrite(IMG_Rescaling, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\IMG_Rescaling.png');


%% rotate
IMG_Rotated = imrotate(IMG, 40);
IMG_Rotated = IMG_Rotated(1170:3325, 165:4000, :);
imwrite(IMG_Rotated, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\IMG_Rotated.png');

%% speckle noise
Speckle_noised = imnoise(IMG, 'speckle', 0.04);
imwrite(Speckle_noised, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\Speckle_noised.png');


% [txt_out, Extracted_logo] = extract_watermark_dualSVD(Speckle_noised, rows_LSB_interval_3, ...
%     cols_LSB_interval_3, rows_LSB_interval_4, cols_LSB_interval_4,rows_Max,...
%     cols_Max, end_number_LSB_3, end_number_LSB_4, end_number_Max,txtb, min_P_index,...
%     P, move, len, rows_RONI, cols_RONI, RONI_length, root_num, U1, V1,S,af, setLength_logo,...
%     Embedded_RONI, max_val, min_val);
% 
% disp(txt_out);
% subplot(2,2,2);
% imshow(uint8(Extracted_logo));
% title('speckle noised logo');


%% salt pepper noise
salt_noised = imnoise(IMG, 'salt & pepper', 0.05);  % 参数 0.05 是噪声密度，可以根据需要调整
imwrite(salt_noised, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\salt_noised.png');


%% cropping RONI
RONI_cropped =  IMG;
RONI_cropped(278:718, 878:1318, :) = Cropped_value;
imwrite(RONI_cropped, 'D:\X.W.Li materials\InIm鲁邦水印\ROI提取\attack\RONI_cropped.png');


function ncc_value = ncc(image1, image2)
    % 计算图像的归一化互相关系数（NCC）
    image1 = double(image1(:));
    image2 = double(image2(:));
    ncc_value = sum((image1 - mean(image1)) .* (image2 - mean(image2))) / ...
    sqrt(sum((image1 - mean(image1)).^2) * sum((image2 - mean(image2)).^2));
end

