clc;
clear all;

im = imread('imagen1.jpg'); % Cargar la imagen
imshow(im); % Mostrar la imagen
title('Seleccione las manchas (haga doble clic para añadir más círculos)');

if size(im, 3) == 1
    im = repmat(im, [1, 1, 3]); % Convertir a una imagen RGB si es en escala de grises
end

hImage = imshow(im); % Mostrar la imagen y obtener el handle de la imagen
hold on;

while true
   
    h = imellipse(gca); 
    position = wait(h); % Esperar a que el usuario termine de dibujar la elipse con doble clic
    
    
    mask = createMask(h, hImage);  % Pasamos el handle de la imagen al crear la máscara
    
    % Colorear la región de la imagen seleccionada de rojo
    im(:,:,1) = im(:,:,1) + uint8(mask) * 255;  % Aumentar el valor del canal rojo
    im(:,:,2) = im(:,:,2) - uint8(mask) * 255;  % Disminuir el valor del canal verde
    im(:,:,3) = im(:,:,3) - uint8(mask) * 255;  % Disminuir el valor del canal azul
    
    % Mostrar la imagen con la mancha coloreada de rojo
    imshow(im);
    title('Manchas marcadas en rojo.');
    
    % Esperar que el usuario haga un doble clic para seleccionar más manchas
    disp('Haga doble clic para seleccionar otra mancha o presione cualquier tecla para terminar.');

    % Detectar la acción de hacer un clic o un doble clic
    key = waitforbuttonpress;
    if key == 0  % Si el usuario hace un clic (o un doble clic), el proceso continúa
        continue;  % Si presionó clic, continuar seleccionando
    else
        break;  % Si presionó cualquier otra tecla, terminar el proceso
    end
end

% Guardar la imagen con manchas rojas
imwrite(im, 'manchas_rojas.jpg');
disp('Imagen con manchas rojas guardada como "manchas_rojas.jpg".');


