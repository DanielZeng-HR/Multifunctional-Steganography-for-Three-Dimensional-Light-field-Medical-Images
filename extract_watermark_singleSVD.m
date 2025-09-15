function [txt_out, Extracted_logo] = extract_watermark_singleSVD( IMG, rows_LSB_interval_3, ...
    cols_LSB_interval_3, rows_LSB_interval_4, cols_LSB_interval_4,rows_Max,...
    cols_Max, end_number_LSB_3, end_number_LSB_4, end_number_Max,txtb, min_P_index,...
    P, move, len, rows_RONI, cols_RONI, RONI_length, root_num,af, setLength_logo,...
    Embedded_RONI,max_val, min_val, HSw, Uw, Vw);

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
%     diff = sum(extracted_IMG_LSB_interval_4 ~= txtb(end_number_LSB_3:end_number_LSB_4-1).');
%     disp(['Number of wrong extraction in interval 4 LSB:',num2str(diff),' elments']);   % 校验提取是否一样, 空集泽一样

    % 提取IMG_LSB_interval_3最后二位
    for i = 1:length(IMG_LSB_interval_3)
            bit1 = bitget(IMG_LSB_interval_3(i), 1);
            bit2 = bitget(IMG_LSB_interval_3(i), 2);
            extracted_IMG_LSB_interval_3 = [extracted_IMG_LSB_interval_3, bit1, bit2];
    end
%     diff = sum(extracted_IMG_LSB_interval_3 ~= txtb(end_number_Max:end_number_LSB_3-1).');
%     disp(['Number of wrong extraction in interval 3 LSB:',num2str(diff),' elments']);

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
%     diff = sum(extracted_IMG_Max ~= txtb(1:end_number_Max-1).');
%     disp(['Number of wrong extraction in Max Embedding: ',num2str(diff),' elements']);

    txt_tot_extracted = [extracted_IMG_Max, extracted_IMG_LSB_interval_3, extracted_IMG_LSB_interval_4];
    seq_length = length(txt_tot_extracted);
    if mod(seq_length, 8) == 0
        txt_str_num = reshape(txt_tot_extracted.', 8, []);%一维变二维
        txt_str_num = txt_str_num.';
        txt_out = num2str(txt_str_num);%转为二进制字符串
        txt_out = bin2dec(txt_out);%转为0-255
        txt_out = char(txt_out)';
    else
        num_zeros_to_add = 8 - mod(seq_length, 8);
        padded_sequence = [txt_tot_extracted, zeros(1, num_zeros_to_add)];
        txt_str_num = reshape(padded_sequence.', 8, []);%一维变二维
        txt_str_num = txt_str_num.';
        txt_out = num2str(txt_str_num);%转为二进制字符串
        txt_out = bin2dec(txt_out);%转为0-255
        txt_out = char(txt_out)';
    end
    %% Logo 提取    
    padded_sequence = IMG(sub2ind(size(IMG), rows_RONI, cols_RONI));
    padded_sequence = padded_sequence(1:RONI_length);
    Extracted_RONI = reshape(padded_sequence, [root_num root_num]);
    [LLw, HLw, LHw, HHw] = dwt2(Extracted_RONI, 'haar');
    Hw = hess(LLw);
    [HUw_hat, HSbw_hat, HVw_hat] = svd(Hw);
    Sw_hat = (HSbw_hat - HSw)./af;
    w_hat = Uw*Sw_hat*Vw';
    Extracted_logo =uint8(w_hat);
end