clc
close all
clear all

im=imread("D-s.jpg");

d1=zeros(1,255)
d2=zeros(1,255)



histogram = imhist(im) 
media_bajo= mean(mean(im))
desviacion_bajo=std2(im)


figure()


for i=1:254
    d1(i)= histograma(i+1) - histograma(i);
end

for i=2:254
    d2(i)= histograma(i-1) + histogram(i+1) - 2*histogram(i);

end
im_eq= histeq(im)

maximo_d1=max(d1)
minimo_d1=min(d1)
pixel_medianad1= find(d1==maximo)
maximo_d2=max(d2)
minimo_d2=min(d2)
pixel_medianad2= find(d2==maximo)

figure()
subplot(1,6,1), imshow(im)
subplot(1,6,2), plot(histogram)



histogram_actualizado= imhist(im_eq)
im_bw=imbinarize(imbw_eq,0.5)

subplot(1,6,3), imshow(im_eq)
subplot(1,6,4), plot(imbw)

media_alto= mean(mean(im_eq))
desviacion_alto=std2(im_eq)
im_neg= bircmp(im_eq, 'uint8');
   

subplot(1,6,5), imshow(im_neg)
subplot(1,6,6), plot(im_neg)


