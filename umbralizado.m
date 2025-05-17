
[nombreArchivo, rutaArchivo] = uigetfile({'*.jpg;*.png;*.jpeg;*.gif;*.bmp'}, 'Selecciona la foto del carro');
if isequal(nombreArchivo, 0), return; end
rutaCompleta = fullfile(rutaArchivo, nombreArchivo);
try
    imagenOriginalRGB = imread(rutaCompleta);
    imagenHSV = rgb2hsv(double(imagenOriginalRGB) / 255);
    H = imagenHSV(:,:,1); S = imagenHSV(:,:,2); V = imagenHSV(:,:,3);
    [filas, columnas, ~] = size(imagenOriginalRGB);
    imagenModificadaHSV = imagenHSV;
catch problema, disp(['Error cargando imagen: ', problema.message]); return; end


toleranciaH = 0.1; toleranciaS = 0.2; toleranciaV = 0.2;


function sonParecidos = esColorSimilarHSV(color1_hsv, color2_hsv, tolH, tolS, tolV)
    diffH = abs(color1_hsv(1) - color2_hsv(1)); diffH = min(diffH, 1 - diffH);
    diffS = abs(color1_hsv(2) - color2_hsv(2));
    diffV = abs(color1_hsv(3) - color2_hsv(3));
    sonParecidos = (diffH <= tolH) && (diffS <= tolS) && (diffV <= tolV);
end


while true
    figure; imshow(hsv2rgb(imagenModificadaHSV));
    titulo = sprintf('Pinta aquí (Tolerancia H:%.2f, S:%.2f, V:%.2f). Clic derecho para terminar.', toleranciaH, toleranciaS, toleranciaV);
    title(titulo);
    [xPunto, yPunto, boton] = ginput(1);
    if boton == 3, break; end
    xPunto = round(xPunto); yPunto = round(yPunto);
    if xPunto < 1 || xPunto > columnas || yPunto < 1 || yPunto > filas, continue; end

   
    colorSeleccionadoHSV = imagenModificadaHSV(yPunto, xPunto, :);

 
    nuevoH = rand(); nuevoS = 0.8;
    nuevoColorHSV = [nuevoH, nuevoS, colorSeleccionadoHSV(3)];

  
    pixelesVisitados = false(filas, columnas);
    puntosPorRevisar = [xPunto, yPunto];
    vecinos = -2:2;
    while ~isempty(puntosPorRevisar)
        puntoActual = puntosPorRevisar(1,:); puntosPorRevisar(1,:) = [];
        xCentro = puntoActual(1); yCentro = puntoActual(2);
        for dy = vecinos, for dx = vecinos
            x = xCentro + dx; y = yCentro + dy;
            if x >= 1 && x <= columnas && y >= 1 && y <= filas && ~pixelesVisitados(y, x)
                colorActualHSV = imagenModificadaHSV(y, x, :);
                if esColorSimilarHSV(colorActualHSV, colorSeleccionadoHSV, toleranciaH, toleranciaS, toleranciaV)
                    imagenModificadaHSV(y, x, :) = nuevoColorHSV;
                    pixelesVisitados(y, x) = true;
                    puntosPorRevisar = [puntosPorRevisar; x, y];
                end
            end
        end, end
    end

   
    elementoEstructurante = strel('disk', 2);
    mascaraPintada = pixelesVisitados;
    mascaraExpandida = imdilate(mascaraPintada, elementoEstructurante);
    for y = 1:filas, for x = 1:columnas
        if mascaraExpandida(y, x)
            imagenModificadaHSV(y, x, 1) = nuevoH;
            imagenModificadaHSV(y, x, 2) = nuevoS;
        end
    end, end
end


figure; imshow(hsv2rgb(imagenModificadaHSV)); title('¡Listo!');
disp('¡Hecho! :)');