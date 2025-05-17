
I = imread('image005.png');  % Cambia por tu imagen
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I);


h = fspecial('gaussian', [51 51], 20);
background = imfilter(I, h, 'replicate');


epsilon = 1e-6;
corrected = mat2gray(I ./ (background + epsilon));


figure('Name','Original vs Corregida','Position',[100 100 1000 600]);


subplot(2,2,1);
imshow(I);
title('Imagen Original');


subplot(2,2,2);
imhist(I);
title('Histograma Original');


subplot(2,2,3);
imshow(corrected);
title('Imagen Corregida (División)');


subplot(2,2,4);
imhist(corrected);
title('Histograma Corregida');
