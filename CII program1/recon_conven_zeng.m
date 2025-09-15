function Out=recon_conven_zeng(sp1,p,L)

%%% sp1 = file name
%%% p = pixel number of elemental image
%%% L = distance

X=imread(sp1);
A1=double(X);
aa=3;

ts=2000;

fy1=zeros(ts,ts);
fy_ori=zeros(ts,ts);

[my,mx]=size(A1);
mmx=mx/p;mmy=my/p;

for x=-fix(mmx/2)+1:fix(mmx/2)  %% 30  mx=900,30/1 
   
   for y=-fix(mmy/2)+1:fix(mmy/2)  %% 30

      Re=A1( (y+fix(mmy/2)-1)*p+1:(y+fix(mmy/2)-1)*p+p,(x+fix(mmx/2)-1)*p+1:(x+fix(mmx/2)-1)*p+p);

  
       if L>=0
           Re2=fliplr(flipud(imresize(Re,abs(L)/aa)));
       end
        

       fy_ori(y*p-p/2*L/aa+1+ts/2:y*p+p/2*L/aa+ts/2,x*p-p/2*L/aa+1+ts/2:x*p+p/2*L/aa+ts/2)=...
       fy_ori(y*p-p/2*L/aa+1+ts/2:y*p+p/2*L/aa+ts/2,x*p-p/2*L/aa+1+ts/2:x*p+p/2*L/aa+ts/2)+Re2;

       clear Re2;
   end
end



ma=max(max(fy_ori));
mi=min(min(fy_ori));
Out=(fy_ori-mi)/(ma-mi)*255;

