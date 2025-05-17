function interfazPrincipal()
% interfazPrincipal() crea una interfaz con botones para diferentes
% funcionalidades de procesamiento de imágenes.
    % Crear la figura principal
    fig_principal = uifigure('Name', 'Procesamiento de Imágenes', ...
                             'Position', [100 100 400 370]); % Ajustar la altura

    % Crear los botones habilitados
    btn_umbralizacion = uibutton(fig_principal, ...
        'Position', [50 310 300 40], ...
        'Text', 'Umbralización', ...
        'ButtonPushedFcn', @(btn, event) abrirUmbralizacionApp());
    btn_transformaciones = uibutton(fig_principal, ...
        'Position', [50 260 300 40], ...
        'Text', 'Transformaciones de Intensidad', ...
        'ButtonPushedFcn', @(btn, event) abrirTransformacionesIntensidadApp());
    btn_transformaciones_tramos = uibutton(fig_principal, ...
        'Position', [50 210 300 40], ...
        'Text', 'Transformaciones por Tramos', ...
        'ButtonPushedFcn', @(btn, event) abrirTransformacionesTramosApp());
    btn_procesamiento_local = uibutton(fig_principal, ...
        'Position', [50 160 300 40], ...
        'Text', 'Procesamiento Local Histograma', ...
        'ButtonPushedFcn', @(btn, event) abrirProcesamientoLocalHistogramaApp());
    btn_realce_local_media_varianza = uibutton(fig_principal, ...
        'Position', [50 110 300 40], ...
        'Text', 'Realce Local Media y Varianza', ...
        'ButtonPushedFcn', @(btn, event) abrirRealceLocalMediaVarianzaApp());
    btn_filtrosEspaciales = uibutton(fig_principal, ...
        'Position', [50 60 300 40], ...
        'Text', 'Filtros Espaciales', ...
        'ButtonPushedFcn', @(btn, event) abrirFiltrosEspacialesApp());
    btn_deteccion_bordes = uibutton(fig_principal, ...
        'Position', [50 10 300 40], ...
        'Text', 'Detección de Bordes', ...
        'ButtonPushedFcn', @(btn, event) abrirDeteccionBordesApp());

    % Función para abrir la aplicación de umbralización
    function abrirUmbralizacionApp()
        disp('Abriendo aplicación de Umbralización');
        umbralizacionApp();
    end
    % Función para abrir la aplicación de transformaciones de intensidad
    function abrirTransformacionesIntensidadApp()
        disp('Abriendo aplicación de Transformaciones de Intensidad');
        transformacionesIntensidadApp();
    end
    % Función para abrir la aplicación de transformaciones por tramos
    function abrirTransformacionesTramosApp()
        disp('Abriendo aplicación de Transformaciones por Tramos');
        transformacionesTramosApp();
    end
    % Función para abrir la aplicación de procesamiento local del histograma
    function abrirProcesamientoLocalHistogramaApp()
        disp('Abriendo aplicación de Procesamiento Local Histograma');
        procesamientoLocalHistogramaApp();
    end
    % Función para abrir la aplicación de realce local basado en media y varianza
    function abrirRealceLocalMediaVarianzaApp()
        disp('Abriendo aplicación de Realce Local Media y Varianza');
        realceLocalMediaVarianzaApp();
    end
    % Función para abrir la aplicación de filtros espaciales
    function abrirFiltrosEspacialesApp()
        filtroEspacialApp(); % Llama a la función de la interfaz de filtros espaciales
    end
    % Función para abrir la aplicación de detección de bordes
    function abrirDeteccionBordesApp()
        deteccionBordesApp(); % Llama a la función de la interfaz de detección de bordes
    end
end
function umbralizacionApp()
    % Crear la figura principal
    fig = uifigure('Name', 'Umbralización', ...
                   'Position', [100 100 1200 600]); % Aumentar el ancho

    % Crear los ejes para las imágenes y los histogramas
    ax_original_image = uiaxes(fig, 'Position', [50 350 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original_image, 'Imagen Original');
    ax_corrected_image = uiaxes(fig, 'Position', [450 350 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_corrected_image, 'Resultado');
    ax_original_hist = uiaxes(fig, 'Position', [50 50 300 200]);
    title(ax_original_hist, 'Histograma Original');
    xlabel(ax_original_hist, 'Nivel de Gris');
    ylabel(ax_original_hist, 'Frecuencia');
    ax_corrected_hist = uiaxes(fig, 'Position', [450 50 300 200]);
    title(ax_corrected_hist, 'Histograma Resultado');
    xlabel(ax_corrected_hist, 'Nivel de Gris');
    ylabel(ax_corrected_hist, 'Frecuencia');

    % Ejes para la primera y segunda derivada
    ax_derivada1 = uiaxes(fig, 'Position', [800 350 300 200]);
    title(ax_derivada1, 'Primera Derivada');
    xlabel(ax_derivada1, 'Nivel de Gris');
    ylabel(ax_derivada1, 'Valor');
    
    ax_derivada2 = uiaxes(fig, 'Position', [800 50 300 200]);
    title(ax_derivada2, 'Segunda Derivada');
    xlabel(ax_derivada2, 'Nivel de Gris');
    ylabel(ax_derivada2, 'Valor');

    % Variables para almacenar las imágenes procesadas y el umbral manual
    original_image_gray = [];
    imagen_umbral_manual = [];
    umbral_manual_value = 128;
    imagen_umbral_mediana = [];
    histograma_umbral_mediana = [];
    imagen_umbral_derivada = [];
    histograma_umbral_derivada = [];
    imagen_ecualizada = [];  % Variable para almacenar la imagen ecualizada

    % Deslizador para el umbral manual
    sld_umbral = uislider(fig, ...
        'Position', [450 300 300 20], ...
        'Limits', [0 255], ...
        'Value', umbral_manual_value, ...
        'Visible', 'off', ...
        'ValueChangedFcn', @(sld, event) sliderUmbralValueChanged(sld.Value, ax_corrected_image, ax_corrected_hist));

    lbl_umbral = uilabel(fig, ...
        'Position', [760 300 60 20], ...
        'Text', ['Umbral: ', num2str(umbral_manual_value)], ...
        'Visible', 'off');

    % Menú desplegable para seleccionar el método
    dd_metodo = uidropdown(fig, ...
        'Position', [250 550 200 30], ...
        'Items', {'Original', 'Umbral Manual', 'Umbral (Mediana)', 'Umbral (Derivada)', 'Ecualización'}, ...
        'ValueChangedFcn', @(dd, event) metodoSeleccionado(dd.Value, ax_corrected_image, ax_corrected_hist));

    % Botón para cargar la imagen
    btn_load = uibutton(fig, 'Position', [50 550 150 30], ...
                        'Text', 'Cargar Imagen', ...
                        'ButtonPushedFcn', @(btn, event) cargarImagen(ax_original_image, ax_original_hist, ax_corrected_image, ax_corrected_hist));

    % Función para cargar la imagen
    function cargarImagen(ax_orig, ax_orig_hist, ax_res, ax_res_hist)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif', 'Archivos de Imagen'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                original_image = imread(filepath);
                if size(original_image, 3) == 3
                    original_image_gray = rgb2gray(original_image);
                else
                    original_image_gray = original_image;
                end
                imshow(original_image_gray, 'Parent', ax_orig);
                ax_orig.DataAspectRatio = [1 1 1];
                ax_orig.XLimMode = 'auto';
                ax_orig.YLimMode = 'auto';

                % Mostrar histograma original
                mostrarHistogramaComoBarras(original_image_gray, ax_orig_hist);

                % Aplicar ecualización y mostrarla
                imagen_ecualizada = histeq(original_image_gray);  % Guardamos la imagen ecualizada
                imshow(imagen_ecualizada, 'Parent', ax_res);
                ax_res.DataAspectRatio = [1 1 1];
                ax_res.XLimMode = 'auto';
                ax_res.YLimMode = 'auto';
                mostrarHistogramaComoBarras(imagen_ecualizada, ax_res_hist);

                % Aplicar todos los métodos para la visualización en el eje "Resultado"
                aplicarUmbralMedianaLocal(original_image_gray);
                aplicarUmbralDerivadaLocal(original_image_gray, ax_derivada1, ax_derivada2);  % Mostrar derivadas
                aplicarEcualizacionLocal(original_image_gray);  % Aquí se llama a la nueva función
                aplicarUmbralManualLocal(sld_umbral.Value, original_image_gray);
                % Mostrar la imagen original al cargar
                metodoSeleccionado('Original', ax_res, ax_res_hist);

            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end

    % Callback para el cambio del slider de umbral manual
    function sliderUmbralValueChanged(umbral_value, ax_umbral, ax_hist)
        umbral_manual_value = round(umbral_value);
        lbl_umbral.Text = ['Umbral: ', num2str(umbral_manual_value)];
        aplicarUmbralManualLocal(umbral_manual_value, original_image_gray, ax_umbral, ax_hist);
    end

    % Callback para la selección del método en el dropdown
    function metodoSeleccionado(metodo, ax_resultado, ax_hist_resultado)
        if ~isempty(original_image_gray)
            switch metodo
                case 'Original'
                    imshow(original_image_gray, 'Parent', ax_resultado);
                    mostrarHistogramaComoBarras(original_image_gray, ax_hist_resultado);
                    title(ax_resultado, 'Imagen Original');
                    title(ax_hist_resultado, 'Histograma Original');
                    sld_umbral.Visible = 'off';
                    lbl_umbral.Visible = 'off';
                case 'Umbral Manual'
                    imshow(imagen_umbral_manual, 'Parent', ax_resultado);
                    mostrarHistogramaComoBarras(imagen_umbral_manual, ax_hist_resultado);
                    title(ax_resultado, ['Umbral Manual (', num2str(umbral_manual_value), ')']);
                    title(ax_hist_resultado, ['Histograma (Umbral = ', num2str(umbral_manual_value), ')']);
                    sld_umbral.Visible = 'on';
                    lbl_umbral.Visible = 'on';
                case 'Umbral (Mediana)'
                    imshow(imagen_umbral_mediana, 'Parent', ax_resultado);
                    mostrarHistogramaComoBarras(imagen_umbral_mediana, ax_hist_resultado);
                    title(ax_resultado, ['Umbral (Mediana = ', num2str(median(original_image_gray(:))), ')']);
                    title(ax_hist_resultado, ['Histograma (Mediana)']);
                    sld_umbral.Visible = 'off';
                    lbl_umbral.Visible = 'off';
                case 'Umbral (Derivada)'
                    imshow(imagen_umbral_derivada, 'Parent', ax_resultado);
                    mostrarHistogramaComoBarras(imagen_umbral_derivada, ax_hist_resultado);
                    title(ax_resultado, ['Umbral (Derivada)']);
                    title(ax_hist_resultado, ['Histograma (Derivada)']);
                    sld_umbral.Visible = 'off';
                    lbl_umbral.Visible = 'off';
                case 'Ecualización'
                    imshow(imagen_ecualizada, 'Parent', ax_resultado);  % Mostrar la imagen ecualizada en escala de grises
                    mostrarHistogramaComoBarras(imagen_ecualizada, ax_hist_resultado);  % Mostrar el histograma de la imagen ecualizada
                    title(ax_resultado, 'Imagen Ecualizada');
                    title(ax_hist_resultado, 'Histograma Ecualizado');
                    sld_umbral.Visible = 'off';
                    lbl_umbral.Visible = 'off';
            end
            ax_resultado.DataAspectRatio = [1 1 1];
            ax_resultado.XLimMode = 'auto';
            ax_resultado.YLimMode = 'auto';
            xlabel(ax_hist_resultado, 'Nivel de Gris');
            ylabel(ax_hist_resultado, 'Frecuencia');
        else
            cla(ax_resultado);
            title(ax_resultado, 'Resultado');
            cla(ax_hist_resultado);
            title(ax_hist_resultado, 'Histograma Resultado');
        end
    end

    % Función local para aplicar el umbral manual y actualizar la variable
    function aplicarUmbralManualLocal(umbral_value, img_gray, ax_umbral, ax_hist)
        if ~isempty(img_gray)
            imagen_umbral_manual = img_gray > umbral_value;
            if nargin > 2 % Si los axes se proporcionan, actualizar la visualización
                imshow(imagen_umbral_manual, 'Parent', ax_umbral);
                ax_umbral.DataAspectRatio = [1 1 1];
                ax_umbral.XLimMode = 'auto';
                ax_umbral.YLimMode = 'auto';
                mostrarHistogramaComoBarras(uint8(imagen_umbral_manual) * 255, ax_hist);
            end
        end
    end

    % Función local para aplicar el umbral basado en la mediana y guardar el resultado
    function aplicarUmbralMedianaLocal(img_gray)
        if ~isempty(img_gray)
            mediana_umbral = median(img_gray(:));
            imagen_umbral_mediana = img_gray > mediana_umbral;
            histograma_umbral_mediana = imhist(uint8(imagen_umbral_mediana) * 255);
        end
    end

    % Función local para aplicar el umbral basado en la derivada del histograma y guardar el resultado
    function aplicarUmbralDerivadaLocal(img_gray, ax_der1, ax_der2)
        if ~isempty(img_gray)
            histogram_data = imhist(img_gray);
            derivada1 = diff(double(histogram_data));
            derivada2 = diff(derivada1);

            % Mostrar la primera derivada
            plot(ax_der1, 1:length(derivada1), derivada1, 'k');
            title(ax_der1, 'Primera Derivada');
            xlabel(ax_der1, 'Nivel de Gris');
            ylabel(ax_der1, 'Valor');

            % Mostrar la segunda derivada
            plot(ax_der2, 1:length(derivada2), derivada2, 'k');
            title(ax_der2, 'Segunda Derivada');
            xlabel(ax_der2, 'Nivel de Gris');
            ylabel(ax_der2, 'Valor');
            
            % Umbral basado en la derivada
            umbral_derivada = find(derivada1(1:end-1) > 0 & derivada1(2:end) <= 0, 1);
            if isempty(umbral_derivada)
                umbral_derivada = round(graythresh(img_gray) * 255);
            end
            imagen_umbral_derivada = img_gray > umbral_derivada;
            histograma_umbral_derivada = imhist(uint8(imagen_umbral_derivada) * 255);
        end
    end

    % Función para mostrar el histograma como barras (no imagen en escala de grises)
    function mostrarHistogramaComoBarras(img, ax)
        histogram_data = imhist(img);
        bar(ax, 0:255, histogram_data, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'k');
        xlim(ax, [0 255]);
        title(ax, 'Histograma Resultado');
        xlabel(ax, 'Nivel de Gris');
        ylabel(ax, 'Frecuencia');
    end
end

function transformacionesIntensidadApp()
% transformacionesIntensidadApp() crea una interfaz gráfica para aplicar
% transformaciones de intensidad (negativa, logarítmica, exponencial).

    % Crear la figura principal
    fig = uifigure('Name', 'Transformaciones de Intensidad', ...
                   'Position', [100 100 900 600]);

    % Ejes para la imagen original y su histograma
    ax_original_image = uiaxes(fig, 'Position', [50 350 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original_image, 'Imagen Original');
    ax_original_hist = uiaxes(fig, 'Position', [50 50 300 200]);
    title(ax_original_hist, 'Histograma Original');
    xlabel(ax_original_hist, 'Nivel de Gris');
    ylabel(ax_original_hist, 'Frecuencia');

    % Ejes para la imagen transformada y su histograma
    ax_transformed_image = uiaxes(fig, 'Position', [550 350 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_transformed_image, 'Imagen Transformada');
    ax_transformed_hist = uiaxes(fig, 'Position', [550 50 300 200]);
    title(ax_transformed_hist, 'Histograma Transformado');
    xlabel(ax_transformed_hist, 'Nivel de Gris');
    ylabel(ax_transformed_hist, 'Frecuencia');

    % Variables para almacenar la imagen
    original_image_gray = [];

    % Menú desplegable para seleccionar la transformación
    lbl_transformacion = uilabel(fig, 'Position', [370 520 120 20], 'Text', 'Transformación:');
    dd_transformacion = uidropdown(fig, ...
        'Position', [370 490 150 30], ...
        'Items', {'Negativa', 'Logarítmica', 'Exponencial'}, ...
        'ValueChangedFcn', @(dd, event) aplicarTransformacion(dd.Value));

    % Controles para los parámetros de las transformaciones
    sld_parametro = uislider(fig, ...
        'Position', [370 420 150 20], ...
        'Limits', [0.01 10], ... % Rango inicial para log y exp
        'Value', 1, ...
        'Visible', 'off', ...
        'ValueChangedFcn', @(sld, event) actualizarTransformacion());
    lbl_parametro = uilabel(fig, ...
        'Position', [530 420 60 20], ...
        'Text', 'Factor:', ...
        'Visible', 'off');
    txt_parametro = uieditfield(fig, ...
        'Position', [590 420 50 20], ...
        'Value', '1', ...
        'Visible', 'off', ...
        'ValueChangedFcn', @(txt, event) actualizarSlider(str2double(txt.Value)));

    % Botón para cargar la imagen
    btn_load = uibutton(fig, 'Position', [150 550 150 30], ...
                        'Text', 'Cargar Imagen', ...
                        'ButtonPushedFcn', @(btn, event) cargarImagen());

    % Funciones internas
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif', 'Archivos de Imagen'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                original_image = imread(filepath);
                if size(original_image, 3) == 3
                    original_image_gray = im2double(rgb2gray(original_image)); % Convertir a double [0, 1]
                else
                    original_image_gray = im2double(original_image); % Convertir a double [0, 1]
                end
                imshow(original_image_gray, 'Parent', ax_original_image);
                histogram(ax_original_hist, original_image_gray(:), 256);
                title(ax_original_hist, 'Histograma Original');
                xlabel(ax_original_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_original_hist, 'Frecuencia');
                % Aplicar la transformación inicial (Negativa por defecto)
                aplicarTransformacion('Negativa');
            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end

    function aplicarTransformacion(tipoTransformacion)
        if ~isempty(original_image_gray)
            transformed_image = [];
            switch tipoTransformacion
                case 'Negativa'
                    transformed_image = 1 - original_image_gray;
                    sld_parametro.Visible = 'off';
                    lbl_parametro.Visible = 'off';
                    txt_parametro.Visible = 'off';
                case 'Logarítmica'
                    c = sld_parametro.Value;
                    transformed_image = c * log1p(original_image_gray); % log1p(x) = log(1+x) para evitar log(0)
                    sld_parametro.Limits = [0.1 10];
                    sld_parametro.Value = c;
                    lbl_parametro.Text = 'Factor (c):';
                    sld_parametro.Visible = 'on';
                    lbl_parametro.Visible = 'on';
                    txt_parametro.Visible = 'on';
                    txt_parametro.Value = num2str(c);
                case 'Exponencial'
                    a = sld_parametro.Value;
                    transformed_image = exp(a * original_image_gray) - 1; % Restar 1 para que el rango empiece en 0
                    % Escalar para que esté en [0, 1] (aproximadamente)
                    max_val = max(exp(a) - 1, 1);
                    transformed_image = transformed_image / max_val;
                    transformed_image(transformed_image < 0) = 0;
                    transformed_image(transformed_image > 1) = 1;
                    sld_parametro.Limits = [0.1 10];
                    sld_parametro.Value = a;
                    lbl_parametro.Text = 'Factor (a):';
                    sld_parametro.Visible = 'on';
                    lbl_parametro.Visible = 'on';
                    txt_parametro.Visible = 'on';
                    txt_parametro.Value = num2str(a);
            end

            if ~isempty(transformed_image)
                imshow(transformed_image, 'Parent', ax_transformed_image);
                histogram(ax_transformed_hist, transformed_image(:), 256);
                title(ax_transformed_hist, ['Histograma ', tipoTransformacion]);
                xlabel(ax_transformed_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_transformed_hist, 'Frecuencia');
            end
        end
    end

    function actualizarTransformacion()
        selected_transform = dd_transformacion.Value;
        aplicarTransformacion(selected_transform);
        % Actualizar el valor del cuadro de texto al cambiar el slider
        if strcmp(selected_transform, 'Logarítmica') || strcmp(selected_transform, 'Exponencial')
            txt_parametro.Value = num2str(sld_parametro.Value);
        end
    end

    function actualizarSlider(valor)
        selected_transform = dd_transformacion.Value;
        if (strcmp(selected_transform, 'Logarítmica') || strcmp(selected_transform, 'Exponencial')) && ~isnan(valor)
            sld_parametro.Value = valor;
            aplicarTransformacion(selected_transform);
        end
    end

end

function transformacionesTramosApp()
% transformacionesTramosApp() crea una interfaz gráfica para aplicar
% transformaciones de intensidad por tramos.

    % Crear la figura principal
    fig = uifigure('Name', 'Transformaciones de Intensidad por Tramos', ...
                   'Position', [100 100 950 650]);

    % Ejes para la imagen original y su histograma
    ax_original_image = uiaxes(fig, 'Position', [50 380 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original_image, 'Imagen Original');
    ax_original_hist = uiaxes(fig, 'Position', [50 80 300 200]);
    title(ax_original_hist, 'Histograma Original');
    xlabel(ax_original_hist, 'Nivel de Gris (0-1)');
    ylabel(ax_original_hist, 'Frecuencia');

    % Ejes para la imagen transformada y su histograma
    ax_transformed_image = uiaxes(fig, 'Position', [600 380 300 200], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_transformed_image, 'Imagen Transformada');
    ax_transformed_hist = uiaxes(fig, 'Position', [600 80 300 200]);
    title(ax_transformed_hist, 'Histograma Transformado');
    xlabel(ax_transformed_hist, 'Nivel de Gris (0-1)');
    ylabel(ax_transformed_hist, 'Frecuencia');

    % Variables para almacenar la imagen (double)
    original_image_double = [];

    % Panel para los controles de los tramos
    pnl_tramos = uipanel(fig, 'Title', 'Control de Tramos', 'Position', [370 80 200 500]);

    % Etiquetas y campos de edición para los puntos de control y pendientes
    lbl_r1 = uilabel(pnl_tramos, 'Position', [20 450 60 20], 'Text', 'r1 (0-1):');
    edt_r1 = uieditfield(pnl_tramos, 'Position', [90 450 80 20], 'Value', '0.2', 'ValueChangedFcn', @(edt, event) actualizarTransformacion());

    lbl_s1 = uilabel(pnl_tramos, 'Position', [20 420 60 20], 'Text', 's1 (0-1):');
    edt_s1 = uieditfield(pnl_tramos, 'Position', [90 420 80 20], 'Value', '0.5', 'ValueChangedFcn', @(edt, event) actualizarTransformacion());

    lbl_r2 = uilabel(pnl_tramos, 'Position', [20 390 60 20], 'Text', 'r2 (0-1):');
    edt_r2 = uieditfield(pnl_tramos, 'Position', [90 390 80 20], 'Value', '0.8', 'ValueChangedFcn', @(edt, event) actualizarTransformacion());

    lbl_s2 = uilabel(pnl_tramos, 'Position', [20 360 60 20], 'Text', 's2 (0-1):');
    edt_s2 = uieditfield(pnl_tramos, 'Position', [90 360 80 20], 'Value', '0.2', 'ValueChangedFcn', @(edt, event) actualizarTransformacion());

    % Botón para cargar la imagen
    btn_load = uibutton(fig, 'Position', [150 600 150 30], ...
                        'Text', 'Cargar Imagen', ...
                        'ButtonPushedFcn', @(btn, event) cargarImagen());

    % Funciones internas
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif', 'Archivos de Imagen'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                original_image = imread(filepath);
                if size(original_image, 3) == 3
                    original_image_double = im2double(rgb2gray(original_image)); % Convertir a double [0, 1]
                else
                    original_image_double = im2double(original_image); % Convertir a double [0, 1]
                end
                imshow(original_image_double, 'Parent', ax_original_image);
                histogram(ax_original_hist, original_image_double(:), 256);
                title(ax_original_hist, 'Histograma Original');
                xlabel(ax_original_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_original_hist, 'Frecuencia');
                % Aplicar la transformación inicial
                actualizarTransformacion();
            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end

    function actualizarTransformacion()
        if ~isempty(original_image_double)
            try
                r1_str = edt_r1.Value;
                s1_str = edt_s1.Value;
                r2_str = edt_r2.Value;
                s2_str = edt_s2.Value;

                r1 = str2double(r1_str);
                s1 = str2double(s1_str);
                r2 = str2double(r2_str);
                s2 = str2double(s2_str);

                if isnan(r1) || isnan(s1) || isnan(r2) || isnan(s2) || r1 < 0 || r1 > 1 || s1 < 0 || s1 > 1 || r2 < 0 || r2 > 1 || s2 < 0 || s2 > 1 || r1 >= r2
                    uialert(fig, 'Los valores de r1, s1, r2, s2 deben ser números entre 0 y 1, y r1 debe ser menor que r2.', 'Error en los parámetros');
                    return;
                end

                transformed_image = zeros(size(original_image_double));

                % Tramo 1: [0, r1] -> [0, s1]
                if r1 ~= 0
                    m1 = s1 / r1;
                else
                    m1 = 0;
                end
                b1 = 0;
                indices1 = (original_image_double >= 0) & (original_image_double <= r1);
                transformed_image(indices1) = m1 * original_image_double(indices1) + b1;

                % Tramo 2: [r1, r2] -> [s1, s2]
                if (r2 - r1) ~= 0
                    m2 = (s2 - s1) / (r2 - r1);
                else
                    m2 = 0;
                end
                b2 = s1 - m2 * r1;
                indices2 = (original_image_double > r1) & (original_image_double <= r2);
                transformed_image(indices2) = m2 * original_image_double(indices2) + b2;

                % Tramo 3: [r2, 1] -> [s2, 1]
                if (1 - r2) ~= 0
                    m3 = (1 - s2) / (1 - r2);
                else
                    m3 = 0;
                end
                b3 = s2 - m3 * r2;
                indices3 = (original_image_double > r2) & (original_image_double <= 1);
                transformed_image(indices3) = m3 * original_image_double(indices3) + b3;

                imshow(transformed_image, 'Parent', ax_transformed_image);
                histogram(ax_transformed_hist, transformed_image(:), 256);
                title(ax_transformed_hist, 'Histograma Transformado (Tramos)');
                xlabel(ax_transformed_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_transformed_hist, 'Frecuencia');

            catch ME
                uialert(fig, ['Error al aplicar la transformación: ', ME.message], 'Error');
            end
        end
    end

end

function procesamientoLocalHistogramaApp()
% procesamientoLocalHistogramaApp() crea una interfaz gráfica para realizar
% el procesamiento local del histograma (versión optimizada).

    % Crear la figura principal
    fig = uifigure('Name', 'Procesamiento Local del Histograma', ...
                   'Position', [100 100 900 650]);
    % Ejes para la imagen original y su histograma
    ax_original_image = uiaxes(fig, 'Position', [50 350 350 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original_image, 'Imagen Original');
    ax_original_hist = uiaxes(fig, 'Position', [50 50 350 250]);
    title(ax_original_hist, 'Histograma Original');
    xlabel(ax_original_hist, 'Nivel de Gris (0-1)');
    ylabel(ax_original_hist, 'Frecuencia');
    % Ejes para la imagen transformada y su histograma
    ax_resultado_image = uiaxes(fig, 'Position', [500 350 350 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_resultado_image, 'Imagen Procesada');
    ax_resultado_hist = uiaxes(fig, 'Position', [500 50 350 250]);
    title(ax_resultado_hist, 'Histograma Procesado');
    xlabel(ax_resultado_hist, 'Nivel de Gris (0-1)');
    ylabel(ax_resultado_hist, 'Frecuencia');
    % Variables para almacenar la imagen (double)
    original_image_double = [];
    % Panel para los controles
    pnl_controles = uipanel(fig, 'Title', 'Controles', 'Position', [50 610 800 35]);
    % Etiqueta y campo de edición para el tamaño de la ventana
    lbl_ventana = uilabel(pnl_controles, 'Position', [20 10 150 20], 'Text', 'Tamaño de Ventana (impar):');
    edt_ventana = uieditfield(pnl_controles, 'Position', [180 10 60 20], 'Value', '3', 'ValueChangedFcn', @(edt, event) procesarImagenLocal());
    % Botón para cargar la imagen
    btn_load = uibutton(pnl_controles, 'Position', [300 5 150 25], ...
                        'Text', 'Cargar Imagen', ...
                        'ButtonPushedFcn', @(btn, event) cargarImagen());
    % Función para cargar la imagen
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.jfif', 'Archivos de Imagen'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                imagenOriginal = imread(filepath);
                if size(imagenOriginal, 3) > 1
                    original_image_double = im2double(rgb2gray(imagenOriginal));
                else
                    original_image_double = im2double(imagenOriginal);
                end
                imshow(original_image_double, 'Parent', ax_original_image);
                histogram(ax_original_hist, original_image_double(:), 256);
                title(ax_original_hist, 'Histograma Original');
                xlabel(ax_original_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_original_hist, 'Frecuencia');
                % Procesar la imagen después de cargar
                procesarImagenLocal();
            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end
    % Función para realizar el procesamiento local del histograma (OPTIMIZADA - aunque la optimización completa del histograma deslizante es compleja)
    function imagenResultado = procesarImagenLocalOptimizado(imagenDouble, ventanaSize)
        [filas, columnas] = size(imagenDouble);
        imagenResultado = zeros(filas, columnas);
        offset = floor(ventanaSize / 2);
        for i = 1:filas
            for j = 1:columnas
                filaInicio = max(1, i - offset);
                filaFin = min(filas, i + offset);
                columnaInicio = max(1, j - offset);
                columnaFin = min(columnas, j + offset);
                vecindadLocal = imagenDouble(filaInicio:filaFin, columnaInicio:columnaFin);
                histogramaLocal = imhist(vecindadLocal(:), 256);
                cdfLocal = cumsum(histogramaLocal) / numel(vecindadLocal);
                valorPixelCentral = imagenDouble(i, j);
                indicePixelCentral = round(valorPixelCentral * 255) + 1;
                if indicePixelCentral >= 1 && indicePixelCentral <= 256
                    imagenResultado(i, j) = cdfLocal(indicePixelCentral);
                else
                    imagenResultado(i, j) = valorPixelCentral;
                end
            end
        end
    end

    function procesarImagenLocal()
        if ~isempty(original_image_double)
            ventanaSize = str2double(edt_ventana.Value);
            if isnan(ventanaSize) || ventanaSize < 1 || mod(ventanaSize, 2) == 0
                uialert(fig, 'El tamaño de la ventana debe ser un entero impar mayor o igual a 1.', 'Error');
                return;
            end
            progress = uiprogressdlg(fig,'Title','Procesando','Message','Calculando...','Indeterminate','on');
            drawnow;
            try
                imagenResultado = procesarImagenLocalOptimizado(original_image_double, ventanaSize); % Llama a la función optimizada
                close(progress);
                imshow(imagenResultado, 'Parent', ax_resultado_image);
                histogram(ax_resultado_hist, imagenResultado(:), 256);
                title(ax_resultado_hist, 'Histograma Procesado');
                xlabel(ax_resultado_hist, 'Nivel de Gris (0-1)');
                ylabel(ax_resultado_hist, 'Frecuencia');
            catch ME
                close(progress);
                uialert(fig, ['Error durante el procesamiento: ', ME.message], 'Error');
            end
        end
    end
end

function realceLocalMediaVarianzaApp()
% realceLocalMediaVarianzaApp() realiza el realce local basado en media y
% varianza locales y globales, incluyendo un método simplificado.
    % Crear la figura principal
    fig = uifigure('Name', 'Realce Local Media y Varianza', ...
                   'Position', [100 100 1000 750]); % Aumentar altura para el nuevo botón
    % Ejes para la imagen original
    ax_original = uiaxes(fig, 'Position', [50 430 300 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original, 'Imagen Original');
    % Ejes para la imagen realzada
    ax_realzada = uiaxes(fig, 'Position', [650 430 300 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_realzada, 'Resultado Realce');
    % Panel de control
    pnl_control = uipanel(fig, 'Title', 'Controles', 'Position', [50 50 900 350]); % Aumentar altura
    % Botón para cargar la imagen
    btn_cargar = uibutton(pnl_control, 'Position', [20 270 150 30], 'Text', 'Cargar Imagen', ...
                         'ButtonPushedFcn', @(btn, event) cargarImagen());
    % **Nuevo botón para el realce simplificado (siguiendo el ejemplo)**
    btn_realce_simple = uibutton(pnl_control, 'Position', [200 270 200 30], 'Text', 'Realce Simple (Ejemplo)', ...
                                 'ButtonPushedFcn', @(btn, event) aplicarRealceSimple());
    % Separador
    uipanel(pnl_control, 'Position', [20 255 860 2], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'none');
    % Etiquetas y campos de edición para las constantes del realce avanzado
    lbl_k0 = uilabel(pnl_control, 'Position', [20 220 80 20], 'Text', 'K0 (0-1):');
    edt_k0 = uieditfield(pnl_control, 'Position', [110 220 60 20], 'Value', '0.5', 'ValueChangedFcn', @(edt, event) actualizarRealceAvanzado());
    lbl_k1 = uilabel(pnl_control, 'Position', [20 190 80 20], 'Text', 'K1 (>=1):');
    edt_k1 = uieditfield(pnl_control, 'Position', [110 190 60 20], 'Value', '1.5', 'ValueChangedFcn', @(edt, event) actualizarRealceAvanzado());
    lbl_k2 = uilabel(pnl_control, 'Position', [20 160 80 20], 'Text', 'K2 (>=1):');
    edt_k2 = uieditfield(pnl_control, 'Position', [110 160 60 20], 'Value', '0.2', 'ValueChangedFcn', @(edt, event) actualizarRealceAvanzado());
    lbl_e = uilabel(pnl_control, 'Position', [20 130 80 20], 'Text', 'E (0-4):');
    edt_e = uieditfield(pnl_control, 'Position', [110 130 60 20], 'Value', '2', 'ValueChangedFcn', @(edt, event) actualizarRealceAvanzado());
    % Checkbox para procesamiento automático de constantes del realce avanzado
    chk_auto = uicheckbox(pnl_control, 'Position', [20 90 200 20], 'Text', 'Calcular K y E automáticamente', ...
                           'ValueChangedFcn', @(chk, event) actualizarEstadoAuto());
    % Variables para almacenar la imagen
    originalImage = [];
    isColorImage = false;
    globalMean = 0;
    globalVariance = 0;
    automaticMode = false;
    % Función para cargar la imagen
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.jfif;*.pgm', 'Archivos de Imagen'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                originalImage = imread(filepath);
                imshow(originalImage, 'Parent', ax_original);
                isColorImage = size(originalImage, 3) == 3;
                if isColorImage
                    grayImage = rgb2gray(originalImage);
                    globalMean = mean(grayImage(:));
                    globalVariance = var(double(grayImage(:)));
                else
                    globalMean = mean(originalImage(:));
                    globalVariance = var(double(originalImage(:)));
                end
                actualizarRealceAvanzado(); % Llama a la función de realce avanzado por defecto
            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end
    % Función para actualizar el estado del modo automático (para el realce avanzado)
    function actualizarEstadoAuto()
        automaticMode = chk_auto.Value;
        edt_k0.Enable = ~automaticMode;
        edt_k1.Enable = ~automaticMode;
        edt_k2.Enable = ~automaticMode;
        edt_e.Enable = ~automaticMode;
        actualizarRealceAvanzado();
    end
    % Función para calcular automáticamente las constantes (metodología simple - para el realce avanzado)
    function [k0_auto, k1_auto, k2_auto, e_auto] = calcularConstantesAutomatico(meanGlobal, varianceGlobal)
        normalizedVariance = varianceGlobal / (255^2);
        normalizedMean = meanGlobal / 255;
        k0_auto = 0.3 + 0.4 * (1 - normalizedVariance);
        k1_auto = 1.5 + 0.5 * normalizedMean;
        k2_auto = 0.2 + 0.3 * (1 - normalizedMean);
        e_auto = 1.0 + 2 * normalizedVariance;
    end
    % Función para aplicar el realce avanzado (para escala de grises)
    function enhancedImage = realzarImagenGrisAvanzado(image, k0, k1, k2, E)
        localMean = imfilter(double(image), fspecial('average', 3), 'replicate');
        localVariance = imfilter(double(image).^2, fspecial('average', 3), 'replicate') - localMean.^2;
        M = globalMean;
        VAR = globalVariance;
        enhancedImage = double(image);
        for i = 1:numel(image)
            if localVariance(i) < k2 * VAR && localMean(i) < k0 * M
                enhancedImage(i) = image(i) * k1^E;
            elseif localVariance(i) < k2 * VAR && localMean(i) >= k0 * M && localMean(i) <= k1 * M
                enhancedImage(i) = image(i) * k1^(E * (1 - (localMean(i) - k0 * M) / ((k1 - k0) * M)));
            else
                enhancedImage(i) = image(i);
            end
        end
        enhancedImage(enhancedImage < 0) = 0;
        enhancedImage(enhancedImage > 255) = 255;
        enhancedImage = uint8(enhancedImage);
    end
    % Función para aplicar el realce avanzado (para color)
    function enhancedImage = realzarImagenColorAvanzado(image, k0, k1, k2, E)
        hsvImage = rgb2hsv(image);
        vChannel = hsvImage(:,:,3);
        realzarV = realzarImagenGrisAvanzado(uint8(vChannel * 255), k0, k1, k2, E) / 255;
        hsvImage(:,:,3) = realzarV;
        enhancedImage = hsv2rgb(hsvImage);
        enhancedImage = uint8(enhancedImage * 255);
    end
    % Función para actualizar el realce avanzado basada en los valores de los controles
    function actualizarRealceAvanzado()
        if ~isempty(originalImage)
            k0_str = strtrim(edt_k0.Value);
            k1_str = strtrim(edt_k1.Value);
            k2_str = strtrim(edt_k2.Value);
            e_str = strtrim(edt_e.Value);
            k0 = str2double(k0_str);
            k1 = str2double(k1_str);
            k2 = str2double(k2_str);
            E = str2double(e_str);
            if isnan(k0) || k0 < -eps || k0 > 1 + eps || ...
               isnan(k1) || k1 < 1 - eps || ...
               isnan(k2) || k2 < 1 - eps || ...
               isnan(E) || E < -eps || E > 4 + eps
                uialert(fig, 'Los valores de K0 (0-1), K1 (>=1), K2 (>=1) y E (0-4) deben ser numéricos y estar dentro de los rangos especificados.', 'Error en los parámetros');
                return;
            end
            if automaticMode
                [k0, k1, k2, E] = calcularConstantesAutomatico(globalMean, globalVariance);
                edt_k0.Value = num2str(k0, '%.3f');
                edt_k1.Value = num2str(k1, '%.3f');
                edt_k2.Value = num2str(k2, '%.3f');
                edt_e.Value = num2str(E, '%.3f');
            end
            if ~isColorImage
                realzada = realzarImagenGrisAvanzado(originalImage, k0, k1, k2, E);
            else
                realzada = realzarImagenColorAvanzado(originalImage, k0, k1, k2, E);
            end
            imshow(realzada, 'Parent', ax_realzada);
        end
    end
    % **Nueva función para aplicar el realce simple (siguiendo el ejemplo)**
    function aplicarRealceSimple()
        if ~isempty(originalImage)
            imagen1 = im2double(originalImage);
            media_g = mean(imagen1(:));
            devStd_g = std(imagen1(:));
            pix = 5;
            masc_prom = (1/pix^2)*ones(pix);
            media_l = imfilter(imagen1,masc_prom, 'replicate'); % Usar 'replicate' para bordes
            devStd_l = imfilter( (imagen1-media_l).^2 ,masc_prom, 'replicate'); % Usar 'replicate'
            k0 = 0.8; % Valores fijos como en el ejemplo
            k2 = 0.0005;
            m1 = media_l <= k0*media_g;
            m2 = devStd_l <= k2*devStd_g;
            mascara_realce = and(m1,not(m2));
            imshow(mascara_realce, 'Parent', ax_realzada); % Mostrar la máscara como resultado
        end
    end
end

function filtroEspacialApp()
% filtroEspacialApp() crea una interfaz gráfica para aplicar filtros
% espaciales configurables a imágenes.

    % Crear la figura principal
    fig = uifigure('Name', 'Filtro Espacial en Dominio Espacial', ...
                   'Position', [100 100 1100 700]);

    % Ejes para la imagen original
    ax_original = uiaxes(fig, 'Position', [50 400 300 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_original, 'Imagen Original');

    % Ejes para la imagen filtrada
    ax_filtrada = uiaxes(fig, 'Position', [400 400 300 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    title(ax_filtrada, 'Imagen Filtrada');

    % Ejes para el Kernel
    ax_kernel = uiaxes(fig, 'Position', [750 400 300 250], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]); % Corregido
    title(ax_kernel, 'Kernel de Convolución');
    ax_kernel.YDir = 'reverse'; % Invertir el eje Y para visualización intuitiva

    % Panel de control
    pnl_control = uipanel(fig, 'Title', 'Controles del Filtro', 'Position', [50 50 1000 300]);

    % Botón para cargar la imagen
    btn_cargar = uibutton(pnl_control, 'Position', [20 240 150 30], 'Text', 'Cargar Imagen', ...
                         'ButtonPushedFcn', @(btn, event) cargarImagen());

    % Selección del tipo de filtro
    lbl_tipo_filtro = uilabel(pnl_control, 'Position', [20 200 120 20], 'Text', 'Tipo de Filtro:');
    dd_tipo_filtro = uidropdown(pnl_control, 'Position', [150 200 150 20], ...
                                 'Items', {'Manual (Plano)', 'Manual (Destornillador)', 'fspecial (Average)', 'fspecial (Gaussian)', 'fspecial (Motion)'}, ...
                                 'ValueChangedFcn', @(dd, event) actualizarControlesFiltro());

    % Controles para el tamaño del kernel
    lbl_tamano_kernel = uilabel(pnl_control, 'Position', [20 160 120 20], 'Text', 'Tamaño Kernel:');
    sld_tamano_kernel = uislider(pnl_control, 'Position', [150 160 150 20], ...
                                  'Limits', [3 21], 'Value', 5, ...
                                  'ValueChangedFcn', @(sld, event) actualizarKernelManualSlider(round(sld.Value)));

    lbl_valor_tamano = uilabel(pnl_control, 'Position', [310 160 30 20], 'Text', '5');

    % Tabla para definir el kernel manual
    tbl_kernel_manual = uitable(pnl_control, 'Position', [20 20 350 130], ...
                                 'Data', ones(5)/25, 'ColumnEditable', true, ...
                                 'ColumnWidth', {50}, 'Visible', 'on', ...
                                 'CellEditCallback', @(tbl, event) actualizarKernelManualTabla(tbl.Data));

    % Botón para aplicar el filtro
    btn_aplicar_filtro = uibutton(pnl_control, 'Position', [200 240 150 30], 'Text', 'Aplicar Filtro', ...
                                  'ButtonPushedFcn', @(btn, event) aplicarFiltroBoton());

    % Variables para almacenar la imagen y el kernel
    originalImage = [];
    currentKernel = ones(5)/25; % Kernel de suavizado plano por defecto

    % Función para cargar la imagen
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.jfif;*.pgm'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            try
                originalImage = imread(filepath);
                imshow(originalImage, 'Parent', ax_original);
                % La aplicación del filtro ahora se hace con el botón
            catch ME
                uialert(fig, ['Error al cargar la imagen: ', ME.message], 'Error');
            end
        end
    end

    % Función para actualizar los controles del filtro según la selección
    function actualizarControlesFiltro()
        selectedFilter = dd_tipo_filtro.Value;
        kernelSize = round(sld_tamano_kernel.Value);
        if mod(kernelSize, 2) == 0
            kernelSize = kernelSize + 1;
            sld_tamano_kernel.Value = kernelSize;
            lbl_valor_tamano.Text = num2str(kernelSize);
        end
        switch selectedFilter
            case {'Manual (Plano)', 'Manual (Destornillador)'}
                lbl_tamano_kernel.Enable = 'on';
                sld_tamano_kernel.Enable = 'on';
                tbl_kernel_manual.Visible = 'on';
                actualizarKernelManual(kernelSize);
            case {'fspecial (Average)'}
                lbl_tamano_kernel.Enable = 'on';
                sld_tamano_kernel.Enable = 'on';
                tbl_kernel_manual.Visible = 'off';
                currentKernel = fspecial('average', kernelSize);
                visualizarKernel(currentKernel);
            case {'fspecial (Gaussian)'}
                lbl_tamano_kernel.Enable = 'on';
                sld_tamano_kernel.Enable = 'on';
                tbl_kernel_manual.Visible = 'off';
                currentKernel = fspecial('gaussian', kernelSize, 1); % Sigma fijo por ahora
                visualizarKernel(currentKernel);
            case {'fspecial (Motion)'}
                lbl_tamano_kernel.Enable = 'on';
                sld_tamano_kernel.Enable = 'on';
                tbl_kernel_manual.Visible = 'off';
                currentKernel = fspecial('motion', kernelSize, 45); % Length y angle fijos
                visualizarKernel(currentKernel);
        end
    end

    % Función para actualizar el tamaño del kernel manualmente (slider)
    function actualizarKernelManualSlider(kernelSize)
        if mod(kernelSize, 2) == 0
            kernelSize = kernelSize + 1;
            sld_tamano_kernel.Value = kernelSize;
        end
        lbl_valor_tamano.Text = num2str(kernelSize);
        actualizarKernelManual(kernelSize);
    end

    % Función interna para actualizar el kernel manual basado en el tamaño
    function actualizarKernelManual(kernelSize)
        newData = ones(kernelSize) / (kernelSize^2); % Kernel plano por defecto
        if strcmp(dd_tipo_filtro.Value, 'Manual (Destornillador)')
            center = floor(kernelSize/2) + 1;
            newData = zeros(kernelSize);
            newData(center, center) = 1;
        end
        tbl_kernel_manual.Data = newData;
        currentKernel = newData;
        visualizarKernel(currentKernel);
    end

    % Función para actualizar el kernel manualmente desde la tabla
    function actualizarKernelManualTabla(kernelData)
        currentKernel = kernelData;
        kernelSize = size(currentKernel, 1);
        sld_tamano_kernel.Value = kernelSize;
        lbl_valor_tamano.Text = num2str(kernelSize);
        visualizarKernel(currentKernel);
    end

    % Función para aplicar el filtro cuando se pulsa el botón
    function aplicarFiltroBoton(btn, event)
        if ~isempty(originalImage)
            if size(originalImage, 3) == 3 % Imagen a color
                % Aplicar el filtro a cada canal por separado
                filteredImageR = imfilter(originalImage(:,:,1), currentKernel, 'replicate');
                filteredImageG = imfilter(originalImage(:,:,2), currentKernel, 'replicate');
                filteredImageB = imfilter(originalImage(:,:,3), currentKernel, 'replicate');
                filteredImage = cat(3, filteredImageR, filteredImageG, filteredImageB);
            else % Imagen en escala de grises
                filteredImage = imfilter(originalImage, currentKernel, 'replicate');
            end
            imshow(filteredImage, 'Parent', ax_filtrada);
        end
    end

    % Función para visualizar el kernel
    function visualizarKernel(kernel)
        cla(ax_kernel);
        imagesc(ax_kernel, kernel);
        colormap(ax_kernel, 'jet');
        colorbar(ax_kernel, 'peer', ax_kernel);
        title(ax_kernel, 'Kernel de Convolución');
        axis(ax_kernel, 'tight', 'equal');
        if size(kernel, 1) <= 21
            ax_kernel.XTick = 1:size(kernel, 2);
            ax_kernel.YTick = 1:size(kernel, 1);
            ax_kernel.XGrid = 'on';
            ax_kernel.YGrid = 'on';
        else
            ax_kernel.XTick = [];
            ax_kernel.YTick = [];
        end
    end

    % Inicializar la visualización del kernel
    visualizarKernel(currentKernel);

end

function deteccionBordesApp()
% detecciondebordesapp() crea una interfaz gráfica avanzada para la detección de
% bordes usando diferentes técnicas y combinaciones de kernels.
    % Crear la figura principal
    fig = uifigure('Name', 'Detección Avanzada de Bordes', 'Position', [100 100 1400 800]);
    % Panel para la imagen original
    pnl_original = uipanel(fig, 'Title', 'Imagen Original', 'Position', [50 500 400 250]);
    ax_original = uiaxes(pnl_original, 'Position', [20 20 360 210], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    % Panel para la imagen con bordes detectados
    pnl_bordes = uipanel(fig, 'Title', 'Bordes Detectados', 'Position', [480 500 400 250]);
    ax_bordes = uiaxes(pnl_bordes, 'Position', [20 20 360 210], 'XTick', [], 'YTick', [], 'DataAspectRatio', [1 1 1]);
    % Panel de controles
    pnl_controles = uipanel(fig, 'Title', 'Controles de Detección de Bordes', 'Position', [50 50 1300 400]);
    % Botón para cargar la imagen
    btn_cargar = uibutton(pnl_controles, 'Position', [20 320 200 40], 'Text', 'Cargar Imagen', ...
                         'ButtonPushedFcn', @(btn, event) cargarImagen());
    % Selección del tipo de filtro
    lbl_tipo_filtro = uilabel(pnl_controles, 'Position', [250 330 150 20], 'Text', 'Tipo de Filtro:');
    dd_tipo_filtro = uidropdown(pnl_controles, 'Position', [410 330 200 20], ...
                             'Items', {'Sobel', 'Prewitt', 'Laplaciano (Básico)', 'Laplaciano (Diagonal)', 'Laplaciano (Combinación)', 'Canny', 'Roberts', 'Marr-Hildreth', 'Combinación Laplaciana', 'Kernel Personalizado'}, ...
                             'ValueChangedFcn', @(dd, event) actualizarControlesFiltro());
    % Panel para entrada de kernel personalizado
    pnl_kernel_personalizado = uipanel(pnl_controles, 'Title', 'Kernel Personalizado', 'Position', [250 20 550 150], 'Visible', 'off');
    lbl_tamano_kernel = uilabel(pnl_kernel_personalizado, 'Position', [20 110 120 20], 'Text', 'Tamaño del Kernel:');
    dd_tamano_kernel = uidropdown(pnl_kernel_personalizado, 'Position', [150 110 100 20], 'Items', {'3x3', '5x5', '7x7'}, 'Value', '3x3', ...
                                 'ValueChangedFcn', @(dd, event) actualizarTablaKernel());
    tbl_kernel = uitable(pnl_kernel_personalizado, 'Position', [20 20 510 80], 'Data', zeros(3, 3), 'ColumnEditable', true);
    % Panel para parámetros de Canny
    pnl_canny = uipanel(pnl_controles, 'Title', 'Parámetros Canny', 'Position', [250 180 300 140], 'Visible', 'off');
    lbl_canny_umbral_bajo = uilabel(pnl_canny, 'Position', [20 80 120 20], 'Text', 'Umbral Bajo:');
    sld_canny_umbral_bajo = uislider(pnl_canny, 'Position', [150 80 120 20], 'Limits', [0 1], 'Value', 0.1);
    lbl_canny_umbral_alto = uilabel(pnl_canny, 'Position', [20 40 120 20], 'Text', 'Umbral Alto:');
    sld_canny_umbral_alto = uislider(pnl_canny, 'Position', [150 40 120 20], 'Limits', [0 1], 'Value', 0.3);
    % Panel para parámetros de Marr-Hildreth
    pnl_marr_hildreth = uipanel(pnl_controles, 'Title', 'Parámetros Marr-Hildreth', 'Position', [580 180 300 140], 'Visible', 'off');
    lbl_sigma_mh = uilabel(pnl_marr_hildreth, 'Position', [20 80 100 20], 'Text', 'Sigma:');
    sld_sigma_mh = uislider(pnl_marr_hildreth, 'Position', [130 80 160 20], 'Limits', [1 10], 'Value', 1.5);
    if isprop(sld_sigma_mh, 'Step')
        sld_sigma_mh.Step = 0.1; % Un tamaño de paso razonable
    end
    lbl_tamano_mh = uilabel(pnl_marr_hildreth, 'Position', [20 40 100 20], 'Text', 'Tamaño Filtro:');
    sld_tamano_mh = uislider(pnl_marr_hildreth, 'Position', [130 40 160 20], 'Limits', [3 21], 'Value', 5);
    if isprop(sld_tamano_mh, 'Step')
        sld_tamano_mh.Step = 2; % Un tamaño de paso razonable para el tamaño del filtro (entero)
    end
    % Panel para combinación Laplaciana
    pnl_combinacion_laplaciana = uipanel(pnl_controles, 'Title', 'Combinación Laplaciana', 'Position', [20 20 870 150], 'Visible', 'off');
    chk_lap_basico = uicheckbox(pnl_combinacion_laplaciana, 'Position', [20 100 150 20], 'Text', 'Laplaciano Básico', 'Value', false);
    chk_lap_diagonal = uicheckbox(pnl_combinacion_laplaciana, 'Position', [180 100 150 20], 'Text', 'Laplaciano Diagonal', 'Value', false);
    chk_lap_combinacion_simple = uicheckbox(pnl_combinacion_laplaciana, 'Position', [340 100 200 20], 'Text', 'Laplaciano Combinación Simple', 'Value', false);
    lbl_operacion_logica = uilabel(pnl_combinacion_laplaciana, 'Position', [20 60 150 20], 'Text', 'Operación Lógica:');
    dd_operacion_logica = uidropdown(pnl_combinacion_laplaciana, 'Position', [180 60 100 20], 'Items', {'OR', 'AND'}, 'Value', 'OR');
    lbl_umbral_combinacion = uilabel(pnl_combinacion_laplaciana, 'Position', [300 60 150 20], 'Text', 'Umbral para Combinación:');
    sld_umbral_combinacion = uislider(pnl_combinacion_laplaciana, 'Position', [460 60 150 20], 'Limits', [0 255], 'Value', 50);
    btn_aplicar_combinacion = uibutton(pnl_combinacion_laplaciana, 'Position', [650 50 200 40], 'Text', 'Aplicar Combinación', ...
                                         'ButtonPushedFcn', @(btn, event) aplicarCombinacionLaplaciana());
    % Checkbox para aplicar a color
    chk_aplicar_color = uicheckbox(pnl_controles, 'Position', [20 270 300 20], 'Text', 'Aplicar a imagen a color (si es RGB)', 'Value', false);
    % Botón para aplicar el filtro principal
    btn_aplicar = uibutton(pnl_controles, 'Position', [20 210 200 40], 'Text', 'Aplicar Filtro', ...
                           'ButtonPushedFcn', @(btn, event) aplicarFiltroBasico());
    % Área de texto para mostrar información y análisis
    txt_info = uilabel(pnl_controles, 'Position', [900 50 450 300], ...
                       'Text', {'Información y Análisis:', ''}, ...
                       'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    % Variables para almacenar la imagen
    originalImage = [];
    grayImage = [];
    % Variable para almacenar el kernel personalizado
    kernelPersonalizado = [];
    % Función para cargar la imagen
    function cargarImagen()
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.gif'}, 'Seleccionar Imagen');
        if ischar(filename)
            filepath = fullfile(pathname, filename);
            originalImage = imread(filepath);
            imshow(originalImage, 'Parent', ax_original);
            if size(originalImage, 3) == 3
                grayImage = rgb2gray(originalImage);
            else
                grayImage = originalImage;
            end
            % Limpiar la visualización anterior
            cla(ax_bordes);
            title(ax_bordes, 'Bordes Detectados');
            txt_info.Text = {'Información y Análisis:', 'Imagen cargada.'};
            % Reiniciar kernel personalizado al cargar nueva imagen
            kernelPersonalizado = [];
            dd_tipo_filtro.Value = 'Sobel'; % Reset filtro seleccionado
            actualizarControlesFiltro();
        end
    end
    % Función para actualizar la visibilidad de los controles del filtro
    function actualizarControlesFiltro()
        selectedFilter = dd_tipo_filtro.Value;
        pnl_canny.Visible = strcmp(selectedFilter, 'Canny');
        pnl_marr_hildreth.Visible = strcmp(selectedFilter, 'Marr-Hildreth');
        pnl_combinacion_laplaciana.Visible = strcmp(selectedFilter, 'Combinación Laplaciana');
        pnl_kernel_personalizado.Visible = strcmp(selectedFilter, 'Kernel Personalizado');
        % Actualizar la tabla del kernel si se selecciona "Kernel Personalizado"
        if strcmp(selectedFilter, 'Kernel Personalizado')
            actualizarTablaKernel();
        end
    end
    % Función para actualizar la tabla del kernel personalizado
    function actualizarTablaKernel()
        selectedSize = dd_tamano_kernel.Value;
        switch selectedSize
            case '3x3'
                tbl_kernel.Data = zeros(3, 3);
            case '5x5'
                tbl_kernel.Data = zeros(5, 5);
            case '7x7'
                tbl_kernel.Data = zeros(7, 7);
        end
    end
    % Función para obtener el kernel personalizado de la tabla
    function kernel = obtenerKernelPersonalizado()
        kernelData = tbl_kernel.Data;
        % Verificar si la tabla contiene solo números
        if ~all(isfinite(kernelData(:)))
            uialert(fig, 'El kernel personalizado debe contener solo valores numéricos.', 'Error en Kernel');
            kernel = [];
            return;
        end
        kernel = double(kernelData);
    end
    % Función para aplicar los filtros básicos (Sobel, Prewitt, Laplaciano simple, Canny, Roberts, Marr-Hildreth) y el kernel personalizado
    function aplicarFiltroBasico()
        if isempty(grayImage)
            uialert(fig, 'Por favor, carga una imagen primero.', 'Advertencia');
            return;
        end
        selectedFilter = dd_tipo_filtro.Value;
        applyColor = chk_aplicar_color.Value;
        bordes = [];
        info = '';
        if strcmp(selectedFilter, 'Kernel Personalizado')
            kernelPersonalizado = obtenerKernelPersonalizado();
            if isempty(kernelPersonalizado)
                return; % No aplicar filtro si el kernel es inválido
            end
            if size(originalImage, 3) == 3 && applyColor
                bordes_r = imfilter(double(originalImage(:,:,1)), kernelPersonalizado, 'replicate');
                bordes_g = imfilter(double(originalImage(:,:,2)), kernelPersonalizado, 'replicate');
                bordes_b = imfilter(double(originalImage(:,:,3)), kernelPersonalizado, 'replicate');
                bordes = max(cat(3, abs(bordes_r), abs(bordes_g), abs(bordes_b)), [], 3);
                info = sprintf('Kernel Personalizado (%dx%d) aplicado a color.', size(kernelPersonalizado, 1), size(kernelPersonalizado, 2));
            else
                bordes = imfilter(double(grayImage), kernelPersonalizado, 'replicate');
                info = sprintf('Kernel Personalizado (%dx%d) aplicado.', size(kernelPersonalizado, 1), size(kernelPersonalizado, 2));
            end
        else
            if size(originalImage, 3) == 3 && applyColor
                img_r = double(originalImage(:,:,1));
                img_g = double(originalImage(:,:,2));
                img_b = double(originalImage(:,:,3));
                switch selectedFilter
                    case 'Sobel'
                        [bordes_r, info_r] = aplicarSobel(img_r);
                        [bordes_g, info_g] = aplicarSobel(img_g);
                        [bordes_b, info_b] = aplicarSobel(img_b);
                        bordes = max(cat(3, bordes_r, bordes_g, bordes_b), [], 3);
                        info = ['Sobel aplicado a color. ', info_r];
                    case 'Prewitt'
                        [bordes_r, info_r] = aplicarPrewitt(img_r);
                        [bordes_g, info_g] = aplicarPrewitt(img_g);
                        [bordes_b, info_b] = aplicarPrewitt(img_b);
                        bordes = max(cat(3, bordes_r, bordes_g, bordes_b), [], 3);
                        info = ['Prewitt aplicado a color. ', info_r];
                    case 'Laplaciano (Básico)'
                        kernel = [0 1 0; 1 -4 1; 0 1 0];
                        bordes_r = abs(imfilter(img_r, kernel, 'replicate'));
                        bordes_g = abs(imfilter(img_g, kernel, 'replicate'));
                        bordes_b = abs(imfilter(img_b, kernel, 'replicate'));
                        bordes = max(cat(3, bordes_r, bordes_g, bordes_b), [], 3);
                        info = 'Laplaciano (Básico) aplicado a color.';
                    case 'Laplaciano (Diagonal)'
                        kernel = [1 1 1; 1 -8 1; 1 1 1];
                        bordes_r = abs(imfilter(img_r, kernel, 'replicate'));
                        bordes_g = abs(imfilter(img_g, kernel, 'replicate'));
                        bordes_b = abs(imfilter(img_b, kernel, 'replicate'));
                        bordes = max(cat(3, bordes_r, bordes_g, bordes_b), [], 3);
                        info = 'Laplaciano (Diagonal) aplicado a color.';
                    case 'Laplaciano (Combinación)'
                        lap1 = imfilter(img_r, [0 1 0; 1 -4 1; 0 1 0], 'replicate');
                        lap2 = imfilter(img_r, [1 0 -1; 0 0 0; -1 0 1], 'replicate');
                        bordes_r = abs(lap1) | abs(lap2);
                        lap1 = imfilter(img_g, [0 1 0; 1 -4 1; 0 1 0], 'replicate');
                        lap2 = imfilter(img_g, [1 0 -1; 0 0 0; -1 0 1], 'replicate');
                        bordes_g = abs(lap1) | abs(lap2);
                        lap1 = imfilter(img_b,img_b, [0 1 0; 1 -4 1; 0 1 0], 'replicate');
                        lap2 = imfilter(img_b, [1 0 -1; 0 0 0; -1 0 1], 'replicate');
                        bordes_b = abs(lap1) | abs(lap2);
                        bordes = max(cat(3, bordes_r, bordes_g, bordes_b), [], 3);
                        info = 'Laplaciano (Combinación) aplicado a color.';
                    case 'Canny'
                        umbral_bajo = sld_canny_umbral_bajo.Value;
                        umbral_alto = sld_canny_umbral_alto.Value;
                        if umbral_bajo >= umbral_alto || umbral_bajo <= 0 || umbral_alto >= 1
                            uialert(fig, 'Umbrales Canny inválidos.', 'Error');
                            return;
                        end
                        bordes_r = edge(originalImage(:,:,1), 'Canny', [umbral_bajo umbral_alto]);
                        bordes_g = edge(originalImage(:,:,2), 'Canny', [umbral_bajo umbral_alto]);
                        bordes_b = edge(originalImage(:,:,3), 'Canny', [umbral_bajo umbral_alto]);
                        bordes = bordes_r | bordes_g | bordes_b;
                        info = sprintf('Canny aplicado a color (Bajo: %.2f, Alto: %.2f).', umbral_bajo, umbral_alto);
                    case 'Roberts'
                        bordes_r = edge(originalImage(:,:,1), 'Roberts');
                        bordes_g = edge(originalImage(:,:,2), 'Roberts');
                        bordes_b = edge(originalImage(:,:,3), 'Roberts');
                        bordes = bordes_r | bordes_g | bordes_b;
                        info = 'Roberts aplicado a color.';
                    case 'Marr-Hildreth'
                        sigma = sld_sigma_mh.Value;
                        filterSize = round(sld_tamano_mh.Value);
                        h = fspecial('log', filterSize, sigma);
                        filteredImage_r = imfilter(img_r, h, 'replicate');
                        filteredImage_g = imfilter(img_g, h, 'replicate');
                        filteredImage_b = imfilter(img_b, h, 'replicate');
                        bordes_r = edge(filteredImage_r, 'zerocross');
                        bordes_g = edge(filteredImage_g, 'zerocross');
                        bordes_b = edge(filteredImage_b, 'zerocross');
                        bordes = bordes_r | bordes_g | bordes_b;
                        info = sprintf('Marr-Hildreth aplicado a color (Sigma: %.2f, Tamaño: %d).', sigma, filterSize);
                    otherwise
                        uialert(fig, 'Filtro no reconocido.', 'Error');
                        return;
                end
            else
                im_procesar = double(grayImage);
                switch selectedFilter
                    case 'Sobel'
                        [bordes, info] = aplicarSobel(im_procesar);
                    case 'Prewitt'
                        [bordes, info] = aplicarPrewitt(im_procesar);
                    case 'Laplaciano (Básico)'
                        kernel = [0 1 0; 1 -4 1; 0 1 0];
                        bordes = abs(imfilter(im_procesar, kernel, 'replicate'));
                        info = 'Laplaciano (Básico) aplicado.';
                    case 'Laplaciano (Diagonal)'
                        kernel = [1 1 1; 1 -8 1; 1 1 1];
                        bordes = abs(imfilter(im_procesar, kernel, 'replicate'));
                        info = 'Laplaciano (Diagonal) aplicado.';
                    case 'Laplaciano (Combinación)'
                        lap1 = imfilter(im_procesar, [0 1 0; 1 -4 1; 0 1 0], 'replicate');
                        lap2 = imfilter(im_procesar, [1 0 -1; 0 0 0; -1 0 1], 'replicate');
                        bordes = abs(lap1) | abs(lap2) > 0; % Using > 0 for binary OR
                        info = 'Laplaciano (Combinación) aplicado.';
                    case 'Canny'
                        umbral_bajo = sld_canny_umbral_bajo.Value;
                        umbral_alto = sld_canny_umbral_alto.Value;
                        if umbral_bajo >= umbral_alto || umbral_bajo <= 0 || umbral_alto >= 1
                            uialert(fig, 'Umbrales Canny inválidos.', 'Error');
                            return;
                        end
                        bordes = edge(uint8(grayImage), 'Canny', [umbral_bajo umbral_alto]);
                        info = sprintf('Canny aplicado (Bajo: %.2f, Alto: %.2f).', umbral_bajo, umbral_alto);
                    case 'Roberts'
                        bordes = edge(uint8(grayImage), 'Roberts');
                        info = 'Roberts aplicado.';
                    case 'Marr-Hildreth'
                        sigma = sld_sigma_mh.Value;
                        filterSize = round(sld_tamano_mh.Value);
                        h = fspecial('log', filterSize, sigma);
                        filteredImage = imfilter(im_procesar, h, 'replicate');
                        bordes = edge(filteredImage, 'zerocross');
                        info = sprintf('Marr-Hildreth aplicado (Sigma: %.2f, Tamaño: %d).', sigma, filterSize);
                    otherwise
                        uialert(fig, 'Filtro no reconocido.', 'Error');
                        return;
                end
            end
        end
        if ~isempty(bordes)
            imshow(bordes, [], 'Parent', ax_bordes);
            title(ax_bordes, sprintf('Bordes Detectados con %s', selectedFilter));
            txt_info.Text = {'Información y Análisis:', 'Imagen cargada.', info, analizarResultados(selectedFilter, bordes)};
        end
    end
    % Función para aplicar la combinación de Laplacianos
    function aplicarCombinacionLaplaciana()
        if isempty(grayImage)
            uialert(fig, 'Por favor, carga una imagen primero.', 'Advertencia');
            return;
        end
        im_procesar = double(grayImage);
        bordes_lap1 = [];
        bordes_lap2 = [];
        bordes_lap3 = [];
        applied_kernels = {};
        if chk_lap_basico.Value
            kernel = [0 1 0; 1 -4 1; 0 1 0];
            bordes_lap1 = abs(imfilter(im_procesar, kernel, 'replicate')) > sld_umbral_combinacion.Value;
            applied_kernels = [applied_kernels, 'Laplaciano Básico'];
        end
        if chk_lap_diagonal.Value
            kernel = [1 1 1; 1 -8 1; 1 1 1];
            bordes_lap2 = abs(imfilter(im_procesar, kernel, 'replicate')) > sld_umbral_combinacion.Value;
            applied_kernels = [applied_kernels, 'Laplaciano Diagonal'];
        end
        if chk_lap_combinacion_simple.Value
            lap1 = imfilter(im_procesar, [0 1 0; 1 -4 1; 0 1 0], 'replicate');
            lap2 = imfilter(im_procesar, [1 0 -1; 0 0 0; -1 0 1], 'replicate');
            bordes_lap3 = (abs(lap1) | abs(lap2)) > sld_umbral_combinacion.Value;
            applied_kernels = [applied_kernels, 'Laplaciano Combinación Simple'];
        end
        if isempty(applied_kernels)
            uialert(fig, 'Seleccione al menos un kernel Laplaciano para combinar.', 'Advertencia');
            return;
        end
        operacion = dd_operacion_logica.Value;
        bordes_combinados = [];
        if ~isempty(bordes_lap1)
            bordes_combinados = bordes_lap1;
        end
        if strcmp(operacion, 'OR')
            if ~isempty(bordes_lap2)
                bordes_combinados = bordes_combinados | bordes_lap2;
            end
            if ~isempty(bordes_lap3)
                bordes_combinados = bordes_combinados | bordes_lap3;
            end
        elseif strcmp(operacion, 'AND')
            if ~isempty(bordes_lap2)
                if isempty(bordes_combinados)
                    bordes_combinados = bordes_lap2;
                else
                    bordes_combinados = bordes_combinados & bordes_lap2;
                end
            end
            if ~isempty(bordes_lap3)
                if isempty(bordes_combinados)
                    bordes_combinados = bordes_lap3;
                else
                    bordes_combinados = bordes_combinados & bordes_lap3;
                end
            end
        end
        if ~isempty(bordes_combinados)
            imshow(bordes_combinados, [], 'Parent', ax_bordes);
            title(ax_bordes, sprintf('Combinación Laplaciana (%s)', operacion));
            info = sprintf('Combinación Laplaciana aplicada con kernels: %s y operación %s.', strjoin(applied_kernels, ', '), operacion);
            txt_info.Text = {'Información y Análisis:', 'Imagen cargada.', info, analizarResultados('Combinación Laplaciana', bordes_combinados)};
        end
    end
    % Funciones auxiliares para aplicar filtros básicos
    function [bordes, info] = aplicarSobel(image)
        sobel_x = fspecial('sobel');
        sobel_y = sobel_x';
        bordes = sqrt(imfilter(image, sobel_x).^2 + imfilter(image, sobel_y).^2);
        info = 'Filtro Sobel aplicado.';
    end
    function [bordes, info] = aplicarPrewitt(image)
        prewitt_x = fspecial('prewitt');
        prewitt_y = prewitt_x';
        bordes = sqrt(imfilter(image, prewitt_x).^2 + imfilter(image, prewitt_y).^2);
        info = 'Filtro Prewitt aplicado.';
    end
    % Función para analizar los resultados
    function analisis = analizarResultados(filtro, bordes)
        num_bordes = sum(bordes(:) > mean(bordes(:)));
        intensidad_promedio_borde = mean(bordes(bordes(:) > mean(bordes(:))));
        analisis = sprintf('Análisis (%s):\nPíxeles de borde aprox.: %d\nIntensidad prom. borde: %.2f', filtro, num_bordes, intensidad_promedio_borde);
    end
    % Inicializar la interfaz
    actualizarControlesFiltro();
end