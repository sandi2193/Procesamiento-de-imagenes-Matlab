% Cargar la imagen
img = imread('lena (1).jpg');  % Reemplazar con tu ruta de imagen
img_gray = rgb2gray(img);    % Convertir a escala de grises si es necesario

% Obtener las dimensiones de la imagen
[M, N] = size(img_gray);

% Realizar la Transformada Rápida de Fourier (FFT) de la imagen
F = fftshift(fft2(double(img_gray)));

% Crear el filtro Butterworth pasa-bajo
D0 = 300;         % Frecuencia de corte
n = 8;           % Orden del filtro

% Crear la malla de distancias (en el dominio de la frecuencia)
[u, v] = meshgrid(-floor(N/2):floor(N/2)-1, -floor(M/2):floor(M/2)-1);
D = sqrt(u.^2 + v.^2);

% Filtro Butterworth pasa-bajo
H = 1 ./ (1 + (D ./ D0).^(2*n));

% Mostrar el gráfico 3D del filtro Butterworth
figure;
surf(u, v, H);   % Mostrar la superficie 3D del filtro
shading interp;   % Suavizar la superficie
colormap('jet');  % Colormap para colores
colorbar;         % Agregar barra de color
title('Filtro Butterworth Pasa-Bajo en 3D');
xlabel('Frecuencia u');
ylabel('Frecuencia v');
zlabel('Valor del Filtro H');
view(3);          % Establecer vista 3D

% Aplicar el filtro en el dominio de la frecuencia
F_filtered = F .* H;

% Transformada inversa para obtener la imagen filtrada
img_filtered = real(ifft2(ifftshift(F_filtered)));

% Mostrar las imágenes
figure;
subplot(1, 2, 1);
imshow(uint8(img_gray));   % Imagen original
title('Imagen Original');

subplot(1, 2, 2);
imshow(uint8(img_filtered)); % Imagen filtrada
title('Imagen Filtrada');
