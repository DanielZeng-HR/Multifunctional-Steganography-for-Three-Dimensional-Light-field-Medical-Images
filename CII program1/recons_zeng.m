clc
clear all
chac = 'rotate';
for L=3:3:39
    
% Out=recon_conven_zeng(['D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\对比实验-single-SVD\'...
%     chac, '\Extracted_logo.tif'],30,L);

% Out=recon_conven_zeng(['D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\'...
%     chac, '\Extracted_logo.tif'],30,L);

Out=recon_conven_zeng(['D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\对比实验-single-SVD-十所\'...
    chac, '\Extracted_logo.tif'],30,L);

% Out=recon_conven_zeng(['D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\dual-SVD-十所\'...
%     chac, '\Extracted_logo.tif'],30,L);

sp1=sprintf('outimage%02d.tif',L);
imwrite(uint8(Out(551:1450,551:1450)),[...
    'D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\对比实验-single-SVD-十所\',chac,'\',sp1]);

% imwrite(uint8(Out(551:1450,551:1450)),[...
%     'D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\dual-SVD-十所\',chac,'\',sp1]);

% imwrite(uint8(Out(551:1450,551:1450)),[...
%     'D:\X.W.Li materials\InIm鲁邦水印\隐写代码完整版\CII program1\',chac,'\',sp1]);
end
