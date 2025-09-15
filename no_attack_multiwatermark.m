clc
close all
clear all

%% 直方图平移信息隐藏
%读入信息
size_1 = 215;
size_2 = 383;
candidate_name = 'lung_11';
IMG_saliency = double(imread(['D:\X.W.Li materials\InIm鲁邦水印\ROI提取\Unet-EI图像提取\UNet_',candidate_name,'_20.jpg']));  % UNet_lung_11_20.jpg  % D:\X.W.Li materials\InIm医学水印\Cameraman.bmp
IMG_saliency = imresize(IMG_saliency,[size_1,size_2],'nearest');
min_val = min(IMG_saliency(:));  % 找到矩阵的最小值
max_val = max(IMG_saliency(:));  % 找到矩阵的最大值
IMG_saliency = uint8(round((IMG_saliency - min_val) / (max_val - min_val) * 255));
IMG = double(imresize(rgb2gray(imread(['D:\X.W.Li materials\第三阶段\单目图像生成EIA\integral-imaging-pickup-ZHR\results\N77N137F2.8G3.1_',candidate_name,'\elemental_image_array.jpg'])),[size_1,size_2],'nearest'));
min_val = min(IMG(:));  % 找到矩阵的最小值
max_val = max(IMG(:));  % 找到矩阵的最大值
IMG = uint8(round((IMG - min_val) / (max_val - min_val) * 255));
figure; imshow(uint8(IMG_saliency));
title('IMG_saliency');
figure; imshow(uint8(IMG));
title('IMG');
I_original=IMG;
fid = fopen('D:\X.W.Li materials\InIm鲁邦水印\medical.txt', 'rt');
[txt,txt_len] = fread(fid, inf, 'uint8'); 


%% 定义ROI；LSB和max区间
interval_1_min = 0;   interval_1_max = 51;
interval_2_min = 52;   interval_2_max = 102;
interval_3_min = 103;   interval_3_max = 153;
interval_4_min = 154;   interval_4_max = 204;
interval_5_min = 205;   interval_5_max = 255;
LSB_sequence = IMG_saliency((interval_3_min <= IMG_saliency) & (IMG_saliency <= interval_4_max));
Max_sequence = IMG_saliency((interval_5_min <= IMG_saliency) & (IMG_saliency <= interval_5_max));  % 把显著图中所有的符合interval 5的像素全部提取出来

%% 计算LSB容量 和 Max容量
count_interval_3 = sum(LSB_sequence >= interval_3_min & LSB_sequence <= interval_3_max);% 根据不同的区间划分并计算每个区间的数量
count_interval_4 = sum(LSB_sequence >= interval_4_min & LSB_sequence <= interval_4_max);
LSB_capacity = count_interval_3 * 2 + count_interval_4 * 1;

[rows_Max, cols_Max] = find((interval_5_min <= IMG_saliency) & (IMG_saliency <= interval_5_max));
IMG_Max_sequence = I_original(sub2ind(size(I_original), rows_Max, cols_Max));
figure;
[counts,binLocations] = imhist(IMG_Max_sequence);
bar(binLocations,counts)%直方图
title('IMG原始的直方图');
% counts = counts(interval_5_min+1:end);
P=find(counts==max(counts));
Z=find(counts==min(counts));
Max_capacity = counts(P);

%txt转换为二进制流
txtb=dec2bin(txt, 8);%转二进制
txtb=reshape(txtb',[],1);%二维变一维
txtb=str2num(txtb);
display(['嵌入信息长度：',num2str(txt_len*8)]);
display(['宿主最大容量：',num2str(Max_capacity + LSB_capacity)]);
if(txt_len * 8 > Max_capacity + LSB_capacity)
    display('隐藏信息过多，请更换载体图像！');
    return
end

%% 平移max-interval的直方图
% 初始化最小差值和位置
min_diff = Inf;  % 初始为无穷大
min_P_index = -1;
min_Z_index = -1;

% 遍历 x 和 y 中的每一个组合，计算 x - y
for i = 1:length(P)
    for j = 1:length(Z)
        diff = P(i) - Z(j);  % 计算 x - y
        if abs(diff) < min_diff    % 如果当前差值小于最小差值
            min_diff = diff;  % 更新最小差值
            min_P_index = i;  % 记录 x 中的位置
            min_Z_index = j;  % 记录 y 中的位置
        end
    end
end

if P(min_P_index) > Z(min_Z_index)%判断P和Z的大小
    move=-1;
    IMG_Max_sequence(IMG_Max_sequence<P(min_P_index)-1  &  IMG_Max_sequence>=Z(min_Z_index)-1) = IMG_Max_sequence(IMG_Max_sequence<P(min_P_index)-1  &  IMG_Max_sequence>=Z(min_Z_index)-1)+ move;
    
    figure;
    [counts,binLocations] = imhist(IMG_Max_sequence);
    bar(binLocations,counts)%直方图
    title('平移后的直方图+1')
else
    move=1;
    IMG_Max_sequence(IMG_Max_sequence>P(min_P_index)-1 & IMG_Max_sequence<=Z(min_Z_index)-1) = IMG_Max_sequence(IMG_Max_sequence>P(min_P_index)-1 & IMG_Max_sequence<=Z(min_Z_index)-1)+ move;
    
    figure;
    [counts,binLocations] = imhist(IMG_Max_sequence);
    bar(binLocations,counts)%直方图
    title('平移后的直方图-1')
end


%% histogram嵌入
txt_len=length(txtb);
len=1;
[m,n] = size(IMG_Max_sequence);
for i=1:m
    for j=1:n
        if(len<=txt_len)
            if((IMG_Max_sequence(i,j)==P(min_P_index)-1)&&(txtb(len)==1)) %txt=1----P-->P+move
                IMG_Max_sequence(i,j)=IMG_Max_sequence(i,j)+move;
                len=len+1;
            elseif((IMG_Max_sequence(i,j)==P(min_P_index)-1)&&(txtb(len)==0))
                len=len+1;
            end
        end
    end
end
end_number_Max = len;
IMG(sub2ind(size(IMG), rows_Max, cols_Max)) = IMG_Max_sequence;  %将处理后的像素放回原图

figure;
[ct,bin]=imhist(IMG_Max_sequence);
bar(bin,ct)
title('隐藏后直方图');

str_1 = sprintf('SSIM of Max_watermarking is %f', ssim(IMG, I_original));
disp(str_1);
str_2 = sprintf('PSNR of Max_watermarking is %f', psnr(IMG, I_original));
disp(str_2);
str_3 = sprintf('NCC of Max_watermarking is %f', ncc(IMG, I_original));
disp(str_3);

%% LSB 嵌入
[rows_LSB_interval_3, cols_LSB_interval_3] = find((interval_3_min <= IMG_saliency) & (IMG_saliency <= interval_3_max));
[rows_LSB_interval_4, cols_LSB_interval_4] = find((interval_4_min <= IMG_saliency) & (IMG_saliency <= interval_4_max));
IMG_LSB_interval_3 = I_original(sub2ind(size(I_original), rows_LSB_interval_3, cols_LSB_interval_3));
IMG_LSB_interval_4 = I_original(sub2ind(size(I_original), rows_LSB_interval_4, cols_LSB_interval_4));

%  interval_3：2bit写入
gray_len = length(IMG_LSB_interval_3);

% 遍历IMG_LSB_interval_3序列并嵌入textdata
for i = 1:gray_len
    if len <= txt_len
        % 获取二元序列中的两个元素
        bit1 = txtb(len);
        bit2 = txtb(len+1);
        
        % 修改灰度值序列中元素的最后两位bit
        IMG_LSB_interval_3(i) = bitset(IMG_LSB_interval_3(i), 1, bit1);  % 设置最后一位
        IMG_LSB_interval_3(i) = bitset(IMG_LSB_interval_3(i), 2, bit2);  % 设置倒数第二位
        
        % 更新二元序列的索引
        len = len + 2;
        end_number_LSB_3 = len;
    else
        end_number_LSB_3 = len;
        break;  % 如果二元序列元素已经全部嵌入，结束循环
    end
end

%  interval_4：1bit写入
gray_len = length(IMG_LSB_interval_4);

% 遍历IMG_LSB_interval_4序列并嵌入textdata
for i = 1:gray_len
    if len <= txt_len
        % 获取二元序列中的两个元素
        bit1 = txtb(len);
        
        % 修改灰度值序列中元素的最后两位bit
        IMG_LSB_interval_4(i) = bitset(IMG_LSB_interval_4(i), 1, bit1);  % 设置最后一位
        
        % 更新二元序列的索引
        len = len + 1;
        end_number_LSB_4 = len;
    else
        end_number_LSB_4 = len;
        break;  % 如果二元序列元素已经全部嵌入，结束循环
    end
end
IMG(sub2ind(size(IMG), rows_LSB_interval_3, cols_LSB_interval_3)) = IMG_LSB_interval_3;
IMG(sub2ind(size(IMG), rows_LSB_interval_4, cols_LSB_interval_4)) = IMG_LSB_interval_4;

str_1 = sprintf('SSIM of Max_LSB_watermarking is %f', ssim(IMG, I_original));
disp(str_1);
str_2 = sprintf('PSNR of Max_LSB_watermarking is %f', psnr(IMG, I_original));
disp(str_2);
str_3 = sprintf('NCC of Max_LSB_watermarking is %f', ncc(IMG, I_original));
disp(str_3);

%% Logo SVD嵌入
% RONI图像提取 & 像素重排
[rows_RONI, cols_RONI] = find((interval_1_min <= IMG_saliency) & (IMG_saliency <= interval_2_max));
IMG_RONI = I_original(sub2ind(size(I_original), rows_RONI, cols_RONI));  % RONI的像素值是通过显著图的像素大小来确定而不是宿主原图像的像素来确定

seq_length = length(IMG_RONI);
n = floor(sqrt(seq_length));  % 计算最接近的完全平方数
RONI_length = n^2;             % 重新计算完全平方数
truncated_IMG_RONI = IMG_RONI(1:RONI_length);
reshaped_IMG_RONI = reshape(truncated_IMG_RONI, [n, n]);

setLength_logo = n/2;
watermark_logo=(rgb2gray(imresize(imread('D:\X.W.Li materials\InIm鲁邦水印\Sichuan_University.png'), [setLength_logo setLength_logo])));

figure
subplot(2,2,1);
imshow(reshaped_IMG_RONI);
title('RONI image');
subplot(2,2,2);
imshow(watermark_logo);
title('Logo image');

% 嵌入logo
[LL HL LH HH]=dwt2(reshaped_IMG_RONI,'haar');
[U,S,V]=svd(LL);  %选LH子带进行奇异值分解
af=0.03;  %嵌入强度
Temp=S+af*double(watermark_logo);%加入水印后的对角阵
[U1,S1,V1]=svd(Temp); %再进行奇异值分解
CW=U*S1*V';  %嵌入水印后子带LL图像
% 做一级小波反变换
Embedded_RONI=idwt2(CW,HL,LH,HH,'haar');
CWI=uint8(Embedded_RONI);

subplot(2,2,3);
imshow(CWI);
title('含logo的RONI图像');

reshaped_sequence = reshape(Embedded_RONI, 1, []);
padded_sequence = [reshaped_sequence, zeros(1, seq_length - length(reshaped_sequence))];
IMG(sub2ind(size(IMG), rows_RONI, cols_RONI)) = padded_sequence;

str_1 = sprintf('SSIM of Max_LSB_RONIz_watermarking is %f', ssim(IMG, I_original));
disp(str_1);
str_2 = sprintf('PSNR of Max_LSB_RONIz_watermarking is %f', psnr(IMG, I_original));
disp(str_2);
str_3 = sprintf('NCC of Max_LSB_RONIz_watermarking is %f', ncc(IMG, I_original));
disp(str_3);

%% LSB 提取
IMG_LSB_interval_3 = IMG(sub2ind(size(IMG), rows_LSB_interval_3, cols_LSB_interval_3));
IMG_LSB_interval_4 = IMG(sub2ind(size(IMG), rows_LSB_interval_4, cols_LSB_interval_4));
extracted_IMG_LSB_interval_4 = [];
extracted_IMG_LSB_interval_3 = [];
% 提取IMG_LSB_interval_4最后一位
for i = 1:end_number_LSB_4 - end_number_LSB_3
        bit1 = bitget(IMG_LSB_interval_4(i), 1);
        extracted_IMG_LSB_interval_4 = [extracted_IMG_LSB_interval_4, bit1];
end
diff = sum(extracted_IMG_LSB_interval_4 ~= txtb(end_number_LSB_3:end_number_LSB_4-1).');
disp(['Number of wrong extraction in interval 4 LSB:',num2str(diff),' elments']);   % 校验提取是否一样, 空集泽一样

% 提取IMG_LSB_interval_3最后二位
for i = 1:length(IMG_LSB_interval_3)
        bit1 = bitget(IMG_LSB_interval_3(i), 1);
        bit2 = bitget(IMG_LSB_interval_3(i), 2);
        extracted_IMG_LSB_interval_3 = [extracted_IMG_LSB_interval_3, bit1, bit2];
end
diff = sum(extracted_IMG_LSB_interval_3 ~= txtb(end_number_Max:end_number_LSB_3-1).');
disp(['Number of wrong extraction in interval 3 LSB:',num2str(diff),' elments']);

%% histogram 提取
IMG_Max_sequence = IMG(sub2ind(size(IMG), rows_Max, cols_Max));
extracted_IMG_Max = [];

[m,n] = size(IMG_Max_sequence);
for i=1:m
    for j=1:n
        if(IMG_Max_sequence(i,j)==P(min_P_index)-1)
            extracted_IMG_Max = [extracted_IMG_Max 0];
            len=len+1;
        elseif(IMG_Max_sequence(i,j)==P(min_P_index)-1+move)
            extracted_IMG_Max = [extracted_IMG_Max 1];
        end
    end
end
diff = sum(extracted_IMG_Max ~= txtb(1:end_number_Max-1).');
disp(['Number of wrong extraction in Max Embedding: ',num2str(diff),' elements']);

txt_tot_extracted = [extracted_IMG_Max, extracted_IMG_LSB_interval_3, extracted_IMG_LSB_interval_4];
txt_str_num = reshape(txt_tot_extracted.', 8, []);%一维变二维
txt_str_num = txt_str_num.';
txt_out = num2str(txt_str_num);%转为二进制字符串
txt_out = bin2dec(txt_out);%转为0-255
txt_out = char(txt_out)';
disp(txt_out);

%% Logo 提取
[LL1 HL1 LH1 HH1]=dwt2(Embedded_RONI,'haar');
[U2,S2,V2]=svd(LL1); %对LL1进行奇异值分解
SN=U1*S2*V1';  %计算中间矩阵
WN=(SN-S)/af;  %提取水印
Extracted_logo=zeros(setLength_logo,setLength_logo);
for i=1:setLength_logo
    for j=1:setLength_logo
        Extracted_logo(i,j)=WN(i,j);
    end
end

subplot(2,2,4);
imshow(uint8(Extracted_logo));
title('提取的logo信息');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ncc_value = ncc(image1, image2)
    % 计算图像的归一化互相关系数（NCC）
    image1 = double(image1(:));
    image2 = double(image2(:));
    ncc_value = sum((image1 - mean(image1)) .* (image2 - mean(image2))) / ...
    sqrt(sum((image1 - mean(image1)).^2) * sum((image2 - mean(image2)).^2));
end

