function [Extracted_logo] = extract_watermark_RONI(IMG, rows_RONI, cols_RONI,...
    RONI_length, root_num, U1, V1,S,af, setLength_logo, Embedded_RONI)

    %% LSB 提取
%     IMG_LSB_interval_3 = IMG(sub2ind(size(IMG), rows_LSB_interval_3, cols_LSB_interval_3));
%     IMG_LSB_interval_4 = IMG(sub2ind(size(IMG), rows_LSB_interval_4, cols_LSB_interval_4));
%     extracted_IMG_LSB_interval_4 = [];
%     extracted_IMG_LSB_interval_3 = [];
%     % 提取IMG_LSB_interval_4最后一位
%     for i = 1:end_number_LSB_4 - end_number_LSB_3
%             bit1 = bitget(IMG_LSB_interval_4(i), 1);
%             extracted_IMG_LSB_interval_4 = [extracted_IMG_LSB_interval_4, bit1];
%     end
% %     diff = sum(extracted_IMG_LSB_interval_4 ~= txtb(end_number_LSB_3:end_number_LSB_4-1).');
% %     disp(['Number of wrong extraction in interval 4 LSB:',num2str(diff),' elments']);   % 校验提取是否一样, 空集泽一样
% 
%     % 提取IMG_LSB_interval_3最后二位
%     for i = 1:length(IMG_LSB_interval_3)
%             bit1 = bitget(IMG_LSB_interval_3(i), 1);
%             bit2 = bitget(IMG_LSB_interval_3(i), 2);
%             extracted_IMG_LSB_interval_3 = [extracted_IMG_LSB_interval_3, bit1, bit2];
%     end
% %     diff = sum(extracted_IMG_LSB_interval_3 ~= txtb(end_number_Max:end_number_LSB_3-1).');
% %     disp(['Number of wrong extraction in interval 3 LSB:',num2str(diff),' elments']);

    %% histogram 提取
%     IMG_Max_sequence = IMG(sub2ind(size(IMG), rows_Max, cols_Max));
%     extracted_IMG_Max = [];
% 
%     [m,n] = size(IMG_Max_sequence);
%     for i=1:m
%         for j=1:n
%             if(IMG_Max_sequence(i,j)==P(min_P_index)-1)
%                 extracted_IMG_Max = [extracted_IMG_Max 0];
%                 len=len+1;
%             elseif(IMG_Max_sequence(i,j)==P(min_P_index)-1+move)
%                 extracted_IMG_Max = [extracted_IMG_Max 1];
%             end
%         end
%     end
% %     diff = sum(extracted_IMG_Max ~= txtb(1:end_number_Max-1).');
% %     disp(['Number of wrong extraction in Max Embedding: ',num2str(diff),' elements']);
% 
%     txt_tot_extracted = [extracted_IMG_Max, extracted_IMG_LSB_interval_3, extracted_IMG_LSB_interval_4];
%     seq_length = length(txt_tot_extracted);
%     if mod(seq_length, 8) == 0
%         txt_str_num = reshape(txt_tot_extracted.', 8, []);%一维变二维
%         txt_str_num = txt_str_num.';
%         txt_out = num2str(txt_str_num);%转为二进制字符串
%         txt_out = bin2dec(txt_out);%转为0-255
%         txt_out = char(txt_out)';
%     else
%         num_zeros_to_add = 8 - mod(seq_length, 8);
%         padded_sequence = [txt_tot_extracted, zeros(1, num_zeros_to_add)];
%         txt_str_num = reshape(padded_sequence.', 8, []);%一维变二维
%         txt_str_num = txt_str_num.';
%         txt_out = num2str(txt_str_num);%转为二进制字符串
%         txt_out = bin2dec(txt_out);%转为0-255
%         txt_out = char(txt_out)';
%     end
    %% Logo 提取    
    padded_sequence = IMG(sub2ind(size(IMG), rows_RONI, cols_RONI));
    padded_sequence = padded_sequence(1:RONI_length);
    kkk = Embedded_RONI;
    Extracted_RONI = reshape(padded_sequence, [root_num root_num]);
    [LL1 HL1 LH1 HH1]=dwt2(Extracted_RONI,'haar');
    [U2,S2,V2]=svd(LL1); %对LL1进行奇异值分解
    SN=U1*S2*V1';  %计算中间矩阵
    WN=(SN-S)/af;  %提取水印
    Extracted_logo=zeros(setLength_logo,setLength_logo);
    for i=1:setLength_logo
        for j=1:setLength_logo
            Extracted_logo(i,j)=WN(i,j);
        end
    end
end