clc
clear all
for kkk=1:3
    
  if kkk==1 [X,map]=imresize(rgb2gray(imread('左下.png')), [900 900]);A1=double(X);bb=3; end
  if kkk==2 [X,map]=imresize(rgb2gray(imread('中间.png')), [900 900]);A1=double(X);bb=12; end
  if kkk==3 [X,map]=imresize(rgb2gray(imread('右上.png')), [900 900]);A1=double(X);bb=21; end  
   
aa=3;p=30;  %  aa=g; p为30*30的孔径

fy1=ones(900,900);

for nx_axis=-14:15  %% 30 
    for my_axis=-14:15  %% 30
    for axis_xp=-14:15  %% 30 pixels
        index1=round(-bb*axis_xp/aa);
        
        for axis_yp=-14:15  %% 30 pixels
            index2=round(-bb*axis_yp/aa);
            if (index2+900/2+my_axis*p) > 0 & (index2+900/2+my_axis*p) < 900 & (index1+900/2+nx_axis*p)> 0 & (index1+900/2+nx_axis*p)< 900
               fy1((my_axis+14)*p+axis_yp+15,(nx_axis+14)*p+axis_xp+15)=A1(index2+900/2+my_axis*p,index1+900/2+nx_axis*p);
           else
               fy1((my_axis+14)*p+axis_yp+15,(nx_axis+14)*p+axis_xp+15)=zeros(1,1);
          end
            
        end
    end
    end
end

%image(fy1);
if kkk==1 imwrite(uint8(fy1),'ele_turtle.tif'); end
 if kkk==2 imwrite(uint8(fy1),'ele_tree.tif');end
if kkk==3 imwrite(uint8(fy1),'ele_crocodile.tif');end

end
%
X1=imread('ele_turtle.tif');
X2=imread('ele_tree.tif');
X3=imread('ele_crocodile.tif');
figure; imshow(X1);
figure; imshow(X2);
figure; imshow(X3);
for k=1:900
    for kk=1:900
        XX(k,kk)=double(X1(k,kk));
               if double(X1(k,kk))==0
           XX(k,kk)=double(X2(k,kk));
           if double(X2(k,kk))==0
              XX(k,kk)=double(X3(k,kk));
           end
        end
    end
end
%       
figure; imshow(XX);
imwrite(uint8(XX),'ei_tur18_tree24_cro30.tif');
imshow(uint8(XX));
%}

