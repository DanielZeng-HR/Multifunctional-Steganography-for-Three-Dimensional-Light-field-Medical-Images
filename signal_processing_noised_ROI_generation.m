clc
clear all
close all

% 设置输入输出文件夹路径
input_folder = 'D:\X.W.Li materials\InIm鲁邦水印\EIA_seg_dataset\try_EIA_seg_test_images_lung_11';
output_folder = 'D:\X.W.Li materials\InIm鲁邦水印\EIA_seg_dataset\try_EIA_seg_test_images';

% 获取所有图像文件（支持常见图像格式）
img_files = dir(fullfile(input_folder, '*.*'));
img_files = img_files(~[img_files.isdir]);  % 去掉文件夹

% 设置目标SNR
target_snr = 20;

% 遍历每张图片
for i = 1:length(img_files)
    % 读取图像
    img_name = img_files(i).name;
    img_path = fullfile(input_folder, img_name);
    img = imread(img_path);
    
    % 若为彩色图像，转换为double逐通道处理
    if size(img, 3) == 3
        img_noised = zeros(size(img), 'like', img);
        for ch = 1:3
            img_noised(:,:,ch) = imnoise_custom(img(:,:,ch), target_snr);
        end
    else
        img_noised = imnoise_custom(img, target_snr);
    end
    
    % 保存加噪图像
    imwrite(uint8(img_noised), fullfile(output_folder, img_name));
end

disp('所有图像已处理并保存完成。');

%% --- 自定义加噪函数 ---
function noisy_img = imnoise_custom(img, snr_db)
    img = double(img);
    signal_power = mean(img(:).^2);
    snr_linear = 10^(snr_db/10);
    noise_power = signal_power / snr_linear;
    noise = sqrt(noise_power) * randn(size(img));
    noisy_img = img + noise;
    noisy_img = min(max(noisy_img, 0), 255);  % 限制像素在 [0, 255]
end
