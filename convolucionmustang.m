clc;
clear;
close all;


im = imread('mustang.bmp');


if size(im, 3) == 3
    im = rgb2gray(im);
end


im = double(im);


figure('Name', 'Detección de Bordes', 'NumberTitle', 'off');
set(gcf, 'Position', [100, 100, 1200, 600]);  % [x y ancho alto]


subplot(2,3,1);
imshow(uint8(im), 'InitialMagnification', 'fit');
title('Imagen Original');


sobel_x = fspecial('sobel');
sobel_y = sobel_x';
sobel_edges = sqrt(imfilter(im, sobel_x).^2 + imfilter(im, sobel_y).^2);
subplot(2,3,2);
imshow(sobel_edges, [], 'InitialMagnification', 'fit');
title('Sobel');


prewitt_x = fspecial('prewitt');
prewitt_y = prewitt_x';
prewitt_edges = sqrt(imfilter(im, prewitt_x).^2 + imfilter(im, prewitt_y).^2);
subplot(2,3,3);
imshow(prewitt_edges, [], 'InitialMagnification', 'fit');
title('Prewitt');


laplacian_edges = imfilter(im, fspecial('laplacian', 0.5));
subplot(2,3,4);
imshow(laplacian_edges, [], 'InitialMagnification', 'fit');
title('Laplaciano');


canny_edges = edge(uint8(im), 'Canny');
subplot(2,3,5);
imshow(canny_edges, 'InitialMagnification', 'fit');
title('Canny');


roberts_edges = edge(uint8(im), 'Roberts');
subplot(2,3,6);
imshow(roberts_edges, 'InitialMagnification', 'fit');
title('Roberts');
 %%el mejor parece ser sobelo prewitt