clc 
close all
clear all

im=imread("D-s.jpg")
hist_in=imhist(im)
im_double= double(im)






c=5;

im_sal= c*log10(1+im_double);

im_sal_norm = im_sal ./ max(max(im_sal));

im_out= uint8(im_sal_norm*255);

hist_out= imhist(im_out)



figure()
subplot(2,2,1),imshow(im)
subplot(2,2,2),plot(hist_in)
subplot(2,2,3),imshow(im_out)
subplot(2,2,4),plot(hist_out)
