% --- Inicio del archivo laboratorioPrincipalUI.m ---

function laboratorioPrincipalUI()
    % --- Crear la figura principal del laboratorio ---
    screenSize = get(0, 'ScreenSize');
    figWidth = 500;
    figHeight = 480;
    figX = (screenSize(3) - figWidth) / 2;
    figY = (screenSize(4) - figHeight) / 2;

    hMainFig = figure('Name', 'Laboratorio de Procesamiento de Imágenes Digitales', ...
                      'Position', [figX, figY, figWidth, figHeight], ...
                      'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                      'Tag', 'mainAppWindow', ... 
                      'CloseRequestFcn', @mainApp_CloseRequestFcn);

    uicontrol(hMainFig, 'Style', 'text', 'String', 'Laboratorio de PDI', ...
              'Position', [50, figHeight-70, figWidth-100, 40], 'FontSize', 18, ...
              'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    buttonWidth = 300; buttonHeight = 45; spacing = 20;
    startY = figHeight - 100 - buttonHeight;

    % Botón 1 modificado para llamar al submenú
    uicontrol(hMainFig, 'Style', 'pushbutton', 'String', '1. Crecimiento de Regiones', ...
              'Position', [(figWidth-buttonWidth)/2, startY, buttonWidth, buttonHeight], ...
              'FontSize', 11, 'Callback', @gestionarSubMenuCrecimientoRegiones);

    startY = startY - buttonHeight - spacing;
    uicontrol(hMainFig, 'Style', 'pushbutton', 'String', '2. Filtrado Frecuencial', ...
              'Position', [(figWidth-buttonWidth)/2, startY, buttonWidth, buttonHeight], ...
              'FontSize', 11, 'Callback', @(s,e) launchActivityUI('filtradoFrecuencialUI', 'Filtrado Frecuencial'));

    startY = startY - buttonHeight - spacing;
    uicontrol(hMainFig, 'Style', 'pushbutton', 'String', '3. Detección de Rostros', ...
              'Position', [(figWidth-buttonWidth)/2, startY, buttonWidth, buttonHeight], ...
              'FontSize', 11, 'Callback', @(s,e) launchActivityUI('deteccionRostrosUI', 'Detección de Rostros'));

    startY = startY - buttonHeight - spacing;
    uicontrol(hMainFig, 'Style', 'pushbutton', 'String', '4. Filtro de Belleza', ...
              'Position', [(figWidth-buttonWidth)/2, startY, buttonWidth, buttonHeight], ...
              'FontSize', 11, 'Callback', @(s,e) launchActivityUI('filtroBellezaUI', 'Filtro de Belleza'));
    
    uicontrol(hMainFig, 'Style', 'pushbutton', 'String', 'Salir del Laboratorio', ...
              'Position', [(figWidth-buttonWidth)/2, 50, buttonWidth, buttonHeight], ...
              'FontSize', 11, 'BackgroundColor', [0.9, 0.6, 0.6], ...
              'Callback', @(s,e) mainApp_CloseRequestFcn(hMainFig)); 
end

% --- Funciones Auxiliares de UI Principal ---
function launchActivityUI(activityFunctionName, activityWindowName)
    existingWindow = findobj('Type', 'figure', 'Tag', activityWindowName);
    if ~isempty(existingWindow)
        figure(existingWindow(1)); 
    else
        fh = str2func(activityFunctionName); 
        fh(); 
    end
end

function mainApp_CloseRequestFcn(figHandle, ~)
    selection = questdlg('¿Está seguro de que desea salir del Laboratorio?', ...
                         'Confirmar Salida', 'Sí', 'No', 'Sí');
    if strcmp(selection, 'Sí')
        disp('Cerrando el Laboratorio de Procesamiento de Imágenes Digitales...');
        delete(figHandle); 
    else
        disp('Salida cancelada.');
    end
end

function subActivity_CloseRequestFcn(figHandle, ~)
    windowName = get(figHandle, 'Name'); 
    disp(['Cerrando ventana de actividad: ' windowName]);
    if contains(get(figHandle, 'Tag'), 'Crecimiento de Regiones')
        appData = guidata(figHandle);
        if isfield(appData, 'seedMarker') && ishandle(appData.seedMarker)
            delete(appData.seedMarker);
        end
    end
    delete(figHandle);
end

% --- SUBMENÚ PARA CRECIMIENTO DE REGIONES ---
function gestionarSubMenuCrecimientoRegiones(~,~)
    opcion = questdlg('Seleccione el tipo de Crecimiento de Regiones:', ...
        'Submenú: Crecimiento de Regiones', ...
        'Simple (Escala de Grises)', ... 
        'Comparación con Otsu (Grises)', ...
        'Color y Cambio de Base (RGB)', ...
        'Simple (Escala de Grises)'); 

    switch opcion
        case 'Simple (Escala de Grises)'
            launchActivityUI('crecimientoRegionesSimpleGrisesUI', 'Crecimiento de Regiones - Simple Grises'); 
        case 'Comparación con Otsu (Grises)'
            launchActivityUI('crecimientoRegionesComparacionUI', 'Crecimiento de Regiones - Comparación Grises');
        case 'Color y Cambio de Base (RGB)'
            launchActivityUI('crecimientoRegionesColorCambioUI', 'Crecimiento de Regiones - Color');
        case '' 
            disp('Selección de tipo de crecimiento de regiones cancelada.');
    end
end


% --- ====================================================== ---
% --- LÓGICA DE ALGORITMOS (Independientes de UI)          ---
% --- ====================================================== ---
function result = regionGrowing(I, seed, threshold) % Para Escala de Grises
    [h, w] = size(I);
    result = false(h, w);
    visited = false(h, w);
    if isempty(seed) || numel(seed) ~= 2, warning('Semilla inválida.'); return; end
    seed = round(seed); 
    if seed(1)<1||seed(1)>h||seed(2)<1||seed(2)>w, warning('Semilla fuera de límites.'); return; end
    
    stack = seed; 
    I_double = double(I);
    ref_val = I_double(stack(1), stack(2));

    while ~isempty(stack)
        p = stack(end,:); stack(end,:)=[]; 
        if p(1)<1||p(1)>h||p(2)<1||p(2)>w, continue; end
        if visited(p(1),p(2)), continue; end
        visited(p(1),p(2)) = true;
        if abs(I_double(p(1),p(2))-ref_val) <= threshold
            result(p(1),p(2))=true;
            for dx=-1:1, for dy=-1:1
                if dx==0&&dy==0, continue; end
                nx=p(1)+dx; ny=p(2)+dy;
                if nx>=1&&nx<=h && ny>=1&&ny<=w && ~visited(nx,ny)
                    stack=[stack;nx,ny]; %#ok<AGROW>
                end
            end, end
        end
    end
end

function result_mask = regionGrowingColor(I_color, seed_coords, threshold_dist_color) % Para Color
    [h,w,num_channels] = size(I_color);
    if num_channels ~= 3, error('Imagen debe ser RGB.'); end
    result_mask = false(h,w); visited = false(h,w);
    if isempty(seed_coords) || numel(seed_coords)~=2, warning('Semilla inválida.'); return; end
    seed_coords = round(seed_coords);
    if seed_coords(1)<1||seed_coords(1)>h||seed_coords(2)<1||seed_coords(2)>w, warning('Semilla fuera de límites.'); return; end

    I_color_double = double(I_color);
    stack = seed_coords;
    ref_color_vector = squeeze(I_color_double(seed_coords(1),seed_coords(2),:))'; 

    while ~isempty(stack)
        p = stack(end,:); stack(end,:)=[];
        if p(1)<1||p(1)>h||p(2)<1||p(2)>w, continue; end
        if visited(p(1),p(2)), continue; end
        visited(p(1),p(2)) = true;
        current_pixel_color_vector = squeeze(I_color_double(p(1),p(2),:))';
        dist_color = norm(current_pixel_color_vector - ref_color_vector); 
        if dist_color <= threshold_dist_color
            result_mask(p(1),p(2))=true;
            for dx=-1:1, for dy=-1:1
                if dx==0&&dy==0, continue; end
                nx=p(1)+dx; ny=p(2)+dy;
                if nx>=1&&nx<=h && ny>=1&&ny<=w && ~visited(nx,ny)
                    stack=[stack;nx,ny]; %#ok<AGROW>
                end
            end,end
        end
    end
end


% --- ====================================================== ---
% --- UI PARA ACTIVIDAD 1.A: CRECIMIENTO REGIONES SIMPLE GRISES ---
% --- ====================================================== ---
function crecimientoRegionesSimpleGrisesUI() 
    windowTag = 'Crecimiento de Regiones - Simple Grises'; 
    appData.imagenOriginal = []; appData.imagenGris = [];
    appData.seedPoint = []; appData.threshold = 10; 

    figureHeight = 560;  figureWidth = 850;
    hFig = figure('Name', windowTag, 'Tag', windowTag, ... 
                  'Position', [350, 120, figureWidth, figureHeight], ... 
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, ...
                  'Units', 'pixels'); 
    guidata(hFig, appData); 

    panelControles_x = 0.02*figureWidth; panelControles_y = 0.05*figureHeight;
    panelControles_w = 0.25*figureWidth; panelControles_h = 0.9*figureHeight;
    panelControles = uipanel(hFig,'Title','Controles','FontSize',10,'Units','pixels', ... 
                             'Position',[panelControles_x,panelControles_y,panelControles_w,panelControles_h]);

    margin=15; controlSpacing=8; buttonHeight=28; textHeight=20;
    largeButtonHeight=38; editHeight=26; controlWidth=panelControles_w-2*margin; 

    current_y = panelControles_h-margin-buttonHeight; 
    uicontrol(panelControles,'Style','pushbutton','String','Cargar Imagen','Units','pixels',...
              'Position',[margin,current_y,controlWidth,buttonHeight],'FontSize',9,'Callback',@crSimple_cargarImagenCallback); % CORREGIDO

    current_y = current_y-controlSpacing-textHeight;
    uicontrol(panelControles,'Style','text','String','Punto Semilla:','Units','pixels',...
              'Position',[margin,current_y,controlWidth*0.4,textHeight],'HorizontalAlignment','left','FontSize',9);
    hTextSeed = uicontrol(panelControles,'Style','text','String','No seleccionado','Units','pixels',...
                          'Position',[margin+controlWidth*0.4+5,current_y,controlWidth*0.6-5,textHeight],'HorizontalAlignment','left','FontSize',9);

    current_y = current_y-controlSpacing/2-buttonHeight;
    uicontrol(panelControles,'Style','pushbutton','String','Seleccionar Semilla','Units','pixels',...
              'Position',[margin,current_y,controlWidth,buttonHeight],'FontSize',9,'Callback',@crSimple_seleccionarSemillaCallback); % CORREGIDO

    current_y = current_y-controlSpacing-textHeight;
    uicontrol(panelControles,'Style','text','String','Umbral (0-255):','Units','pixels',...
              'Position',[margin,current_y,controlWidth*0.6,textHeight],'HorizontalAlignment','left','FontSize',9);
    hEditThreshold = uicontrol(panelControles,'Style','edit','String',num2str(appData.threshold),'Units','pixels',...
                               'Position',[margin+controlWidth*0.6+5,current_y-(editHeight-textHeight)/2,controlWidth*0.4-5,editHeight],'FontSize',9,'Callback',@crSimple_thresholdEditCallback); % CORREGIDO

    current_y = current_y-controlSpacing-largeButtonHeight;
    uicontrol(panelControles,'Style','pushbutton','String','Procesar Región','Units','pixels',...
              'Position',[margin,current_y,controlWidth,largeButtonHeight],'FontSize',10,'FontWeight','bold','Callback',@crSimple_procesarRegionCallback); % CORREGIDO
              
    statusTextHeight = 35; 
    current_y = current_y-controlSpacing-statusTextHeight;
    hStatusText = uicontrol(panelControles,'Style','text','String','Listo.','Units','pixels',...
                            'Position',[margin,current_y,controlWidth,statusTextHeight],'FontSize',9,'ForegroundColor','blue');

    panelImagenes_x = panelControles_x+panelControles_w+0.01*figureWidth; 
    panelImagenes_y = panelControles_y;
    panelImagenes_w = figureWidth-panelImagenes_x-panelControles_x; 
    panelImagenes_h = panelControles_h;
    panelImagenes = uipanel(hFig,'Title','Visualización','FontSize',10,'Units','pixels', ...
                            'Position',[panelImagenes_x,panelImagenes_y,panelImagenes_w,panelImagenes_h]);

    axOriginal = axes(panelImagenes,'Units','normalized','Position',[0.05,0.52,0.9,0.45]);
    title(axOriginal,'Imagen Original (Clic para semilla)'); axis(axOriginal,'image','off');
    axSegmentada = axes(panelImagenes,'Units','normalized','Position',[0.05,0.05,0.9,0.45]);
    title(axSegmentada,'Región Segmentada'); axis(axSegmentada,'image','off');
    
    % Callbacks para Crecimiento Regiones Simple Grises (prefijo crSimple_)
    function crSimple_cargarImagenCallback(~,~) 
        appData_local = guidata(hFig);
        [filename,pathname]=uigetfile({'*.jpg;*.png;*.bmp','Imágenes'},'Selecciona una imagen');
        if isequal(filename,0), set(hStatusText,'String','Carga cancelada.'); return; end
        try
            img=imread(fullfile(pathname,filename)); appData_local.imagenOriginal=img;
            if size(img,3)==3, appData_local.imagenGris=rgb2gray(img); else, appData_local.imagenGris=img; end
            if isfield(appData_local,'seedMarker')&&ishandle(appData_local.seedMarker)
                delete(appData_local.seedMarker); appData_local=rmfield(appData_local,'seedMarker');
            end
            imshow(appData_local.imagenGris,'Parent',axOriginal); axis(axOriginal,'image'); title(axOriginal,'Imagen Original (Clic para semilla)');
            cla(axSegmentada); title(axSegmentada,'Región Segmentada'); 
            if isempty(get(axSegmentada,'Children')), axis(axSegmentada,'off'); else, axis(axSegmentada,'image'); end
            appData_local.seedPoint=[]; set(hTextSeed,'String','No seleccionado');
            set(hStatusText,'String',['Imagen: ' filename]); guidata(hFig,appData_local);
        catch ME, errordlg(['Error al cargar: ' ME.message],'Error'); set(hStatusText,'String','Error al cargar.'); end
    end
    function crSimple_seleccionarSemillaCallback(~,~) 
        appData_local=guidata(hFig); if isempty(appData_local.imagenGris), set(hStatusText,'String','Cargue imagen.'); warndlg('Cargue imagen.','Aviso'); return; end
        set(hStatusText,'String','Clic en imagen para semilla...'); figure(hFig); axes(axOriginal);
        try
            [x_coord,y_coord]=ginput(1); if isempty(x_coord), set(hStatusText,'String','Selección cancelada.'); disp('Selección de semilla cancelada por usuario.'); return; end
            disp(['ginput devolvió crudas x=' num2str(x_coord) ', y=' num2str(y_coord)]);
            appData_local.seedPoint=[round(y_coord),round(x_coord)];
            set(hTextSeed,'String',['F:' num2str(appData_local.seedPoint(1)) ', C:' num2str(appData_local.seedPoint(2))]);
            set(hStatusText,'String','Semilla OK.');
            disp(['Semilla almacenada F:' num2str(appData_local.seedPoint(1)) ', C:' num2str(appData_local.seedPoint(2))]);
            hold(axOriginal,'on'); if isfield(appData_local,'seedMarker')&&ishandle(appData_local.seedMarker), delete(appData_local.seedMarker); end
            appData_local.seedMarker=plot(axOriginal,x_coord,y_coord,'r+','MarkerSize',12,'LineWidth',2); hold(axOriginal,'off'); 
            guidata(hFig,appData_local);
        catch ME, set(hStatusText,'String',['Error semilla: ' ME.message]); fprintf(2,'Error en crSimple_seleccionarSemilla: %s\n',ME.message); disp(ME.getReport()); end
    end
    function crSimple_thresholdEditCallback(src,~) 
        appData_local=guidata(hFig); val=str2double(get(src,'String'));
        if isnan(val)||val<0||val>255, set(src,'String',num2str(appData_local.threshold)); warndlg('Umbral 0-255.','Error'); else, appData_local.threshold=val; end
        set(hStatusText,'String',['Umbral: ' num2str(appData_local.threshold)]); guidata(hFig,appData_local);
    end
    function crSimple_procesarRegionCallback(~,~) 
        appData_local=guidata(hFig); if isempty(appData_local.imagenGris)||isempty(appData_local.seedPoint), set(hStatusText,'String','Cargue imagen y semilla.'); warndlg('Cargue imagen y semilla.','Error'); return; end
        set(hStatusText,'String','Procesando...'); drawnow;
        try
            segmentedImage=regionGrowing(appData_local.imagenGris,appData_local.seedPoint,appData_local.threshold);
            imshow(segmentedImage,'Parent',axSegmentada); axis(axSegmentada,'image'); title(axSegmentada,['Segmentada (Umbral: ' num2str(appData_local.threshold) ')']);
            set(hStatusText,'String','Proceso completado.');
        catch ME, errordlg(['Error: ' ME.message],'Error'); set(hStatusText,'String',['Error: ' ME.message]); end
    end
end


% --- ======================================================================= ---
% --- UI PARA ACTIVIDAD 1.B: CRECIMIENTO REGIONES COMPARACIÓN (GRISES Y OTSU) ---
% --- ======================================================================= ---
function crecimientoRegionesComparacionUI()
    windowTag = 'Crecimiento de Regiones - Comparación Grises';
    appData.imgOriginal = []; appData.imgGris = []; appData.seedRg = []; appData.thresholdRg = 20;

    hFig = figure('Name', windowTag, 'Tag', windowTag, ...
                  'Position', [300, 80, 1000, 700], ...
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, 'Units', 'pixels');
    guidata(hFig, appData);

    panelCtl = uipanel(hFig,'Title','Controles','Position',[0.02 0.02 0.20 0.96]);
    panelDisp = uipanel(hFig,'Title','Visualización','Position',[0.24 0.02 0.74 0.96]);

    margin=15; ctlW=round(0.20*1000-2*margin); btnH=28; txtH=20; editH=26; spacing=10;
    y = round(0.96*700 - margin - btnH);
    uicontrol(panelCtl,'Style','pushbutton','String','Cargar Imagen','Position',[margin y ctlW btnH],'Callback',@crc_cargarImagen);
    y = y-spacing-txtH;
    uicontrol(panelCtl,'Style','text','String','Semilla RG:','Position',[margin y ctlW*0.5 txtH]);
    hSeedRgTxt = uicontrol(panelCtl,'Style','text','String','N/A','Position',[margin+ctlW*0.5 y ctlW*0.5 txtH]);
    y = y-spacing-btnH;
    uicontrol(panelCtl,'Style','pushbutton','String','Seleccionar Semilla RG','Position',[margin y ctlW btnH],'Callback',@crc_selSemillaRg);
    y = y-spacing-txtH;
    uicontrol(panelCtl,'Style','text','String','Umbral RG:','Position',[margin y ctlW*0.5 txtH]);
    hThrRgEdit = uicontrol(panelCtl,'Style','edit','String',num2str(appData.thresholdRg),'Position',[margin+ctlW*0.5 y ctlW*0.5 editH],'Callback',@crc_editThrRg);
    y = y-spacing*2-btnH*1.5;
    uicontrol(panelCtl,'Style','pushbutton','String','Procesar y Comparar','Position',[margin y ctlW btnH*1.5],'FontWeight','bold','Callback',@crc_procesar);
    hStatusCrc = uicontrol(panelCtl,'Style','text','String','Listo.','Position',[margin y-spacing-txtH*2 ctlW txtH*2]);

    axOrig = axes(panelDisp,'Units','normalized','Position',[0.05 0.53 0.43 0.43]); title(axOrig,'Original'); axis(axOrig,'image','off');
    axGris = axes(panelDisp,'Units','normalized','Position',[0.52 0.53 0.43 0.43]); title(axGris,'Escala de Grises'); axis(axGris,'image','off');
    axRg = axes(panelDisp,'Units','normalized','Position',[0.05 0.05 0.43 0.43]); title(axRg,'Crecimiento Regiones'); axis(axRg,'image','off');
    axOtsu = axes(panelDisp,'Units','normalized','Position',[0.52 0.05 0.43 0.43]); title(axOtsu,'Umbral Otsu'); axis(axOtsu,'image','off');

    function crc_cargarImagen(~,~)
        appData_local = guidata(hFig);
        [fn,pn]=uigetfile({'*.jpg;*.png;*.bmp','Imágenes'},'Cargar Imagen'); if isequal(fn,0),return; end
        img = imread(fullfile(pn,fn)); appData_local.imgOriginal = img;
        if size(img,3)==3, appData_local.imgGris = rgb2gray(img); else, appData_local.imgGris = img; end
        imshow(appData_local.imgOriginal,'Parent',axOrig); title(axOrig,'Original'); axis(axOrig,'image');
        imshow(appData_local.imgGris,'Parent',axGris); title(axGris,'Escala de Grises (Clic para semilla RG)'); axis(axGris,'image');
        cla(axRg); title(axRg,'Crecimiento Regiones'); axis(axRg,'off'); 
        cla(axOtsu); title(axOtsu,'Umbral Otsu'); axis(axOtsu,'off');
        appData_local.seedRg=[]; set(hSeedRgTxt,'String','N/A');
        if isfield(appData_local,'seedMarker') && ishandle(appData_local.seedMarker)
             delete(appData_local.seedMarker); appData_local=rmfield(appData_local,'seedMarker'); 
        end
        set(hStatusCrc,'String',['Imagen: ' fn]); guidata(hFig,appData_local);
    end
    function crc_selSemillaRg(~,~)
        appData_local=guidata(hFig); if isempty(appData_local.imgGris),warndlg('Cargue imagen.','Aviso');return;end
        set(hStatusCrc,'String','Clic en "Escala de Grises" para semilla...');figure(hFig);axes(axGris);
        try
            [x,y]=ginput(1); if isempty(x),set(hStatusCrc,'String','Selección cancelada.');return;end; 
            appData_local.seedRg=[round(y),round(x)];
            set(hSeedRgTxt,'String',['F:' num2str(round(y)) ',C:' num2str(round(x))]);
            hold(axGris,'on'); 
            if isfield(appData_local,'seedMarker')&&ishandle(appData_local.seedMarker),delete(appData_local.seedMarker);end
            appData_local.seedMarker = plot(axGris,x,y,'m+','MarkerSize',10,'LineWidth',1.5); hold(axGris,'off'); % Usar magenta para diferenciar
            guidata(hFig,appData_local); set(hStatusCrc,'String','Semilla RG seleccionada.');
        catch ME, set(hStatusCrc,'String',['Error semilla: ' ME.message]);  fprintf(2,'Error en crc_selSemillaRg: %s\n',ME.message); disp(ME.getReport()); end
    end
    function crc_editThrRg(src,~)
        appData_local=guidata(hFig); val=str2double(get(src,'String'));
        if isnan(val)||val<0||val>255, set(src,'String',num2str(appData_local.thresholdRg)); else,appData_local.thresholdRg=val; end
        guidata(hFig,appData_local);
    end
    function crc_procesar(~,~)
        appData_local=guidata(hFig);
        if isempty(appData_local.imgGris)||isempty(appData_local.seedRg),warndlg('Cargue imagen y seleccione semilla RG.','Aviso');return;end
        set(hStatusCrc,'String','Procesando...');drawnow;
        try
            img_rg_res = regionGrowing(appData_local.imgGris, appData_local.seedRg, appData_local.thresholdRg);
            imshow(img_rg_res,'Parent',axRg); title(axRg,['Crec. Reg. (Umbral=' num2str(appData_local.thresholdRg) ')']); axis(axRg,'image');
            
            otsu_level = graythresh(appData_local.imgGris);
            img_otsu_res = imbinarize(appData_local.imgGris, otsu_level);
            imshow(img_otsu_res,'Parent',axOtsu); title(axOtsu,['Otsu (Umbral=' num2str(otsu_level*255,'%.0f') ')']); axis(axOtsu,'image');
            set(hStatusCrc,'String','Procesamiento completado.');
        catch ME
            set(hStatusCrc,'String',['Error: ' ME.message]); fprintf(2,'Error en crc_procesar: %s\n',ME.message); disp(ME.getReport());
        end
    end
end


% --- ======================================================================= ---
% --- UI PARA ACTIVIDAD 1.C: CRECIMIENTO REGIONES COLOR Y CAMBIO DE BASE      ---
% --- ======================================================================= ---
function crecimientoRegionesColorCambioUI()
    windowTag = 'Crecimiento de Regiones - Color';
    appData.imgColor = []; appData.seedColor = []; appData.thresholdColorDist = 50;
    appData.newR=255; appData.newG=0; appData.newB=0; 

    hFig = figure('Name', windowTag, 'Tag', windowTag, ...
                  'Position', [250, 60, 1100, 650], ...
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, 'Units', 'pixels');
    guidata(hFig, appData);

    panelCtl = uipanel(hFig,'Title','Controles','Position',[0.02 0.02 0.22 0.96]);
    panelDisp = uipanel(hFig,'Title','Visualización','Position',[0.26 0.02 0.72 0.96]);
    
    margin=15; ctlW=round(0.22*1100-2*margin); btnH=28; txtH=20; editH=26; spacing=10;
    y = round(0.96*650 - margin - btnH);
    uicontrol(panelCtl,'Style','pushbutton','String','Cargar Imagen Color','Position',[margin y ctlW btnH],'Callback',@crgb_cargarImagen);
    y = y-spacing-txtH;
    uicontrol(panelCtl,'Style','text','String','Semilla Color:','Position',[margin y ctlW*0.5 txtH]);
    hSeedCRGBTxt = uicontrol(panelCtl,'Style','text','String','N/A','Position',[margin+ctlW*0.5 y ctlW*0.5 txtH]);
    y = y-spacing-btnH;
    uicontrol(panelCtl,'Style','pushbutton','String','Seleccionar Semilla Color','Position',[margin y ctlW btnH],'Callback',@crgb_selSemilla);
    y = y-spacing-txtH;
    uicontrol(panelCtl,'Style','text','String','Umbral Dist. Color:','Position',[margin y ctlW*0.6 txtH]);
    hThrCRGBEdit = uicontrol(panelCtl,'Style','edit','String',num2str(appData.thresholdColorDist),'Position',[margin+ctlW*0.6+2 y ctlW*0.4-2 editH],'Callback',@crgb_editThr);
    
    y = y-spacing*1.5-txtH;
    uicontrol(panelCtl,'Style','text','String','Nuevo Color Base:','Position',[margin y ctlW txtH],'FontWeight','bold');
    y = y-spacing-txtH;
    uicontrol(panelCtl,'Style','text','String','R (0-255):','Position',[margin y ctlW*0.3 txtH]);
    hNewR = uicontrol(panelCtl,'Style','edit','String',num2str(appData.newR),'Position',[margin+ctlW*0.3+2 y ctlW*0.2-2 editH],'Callback',@crgb_editColor);
    uicontrol(panelCtl,'Style','text','String','G:','Position',[margin+ctlW*0.5+4 y ctlW*0.08 txtH]);
    hNewG = uicontrol(panelCtl,'Style','edit','String',num2str(appData.newG),'Position',[margin+ctlW*0.58+6 y ctlW*0.2-6 editH],'Callback',@crgb_editColor);
    uicontrol(panelCtl,'Style','text','String','B:','Position',[margin+ctlW*0.78+8 y ctlW*0.08 txtH]);
    hNewB = uicontrol(panelCtl,'Style','edit','String',num2str(appData.newB),'Position',[margin+ctlW*0.86+10 y ctlW*0.14-10 editH],'Callback',@crgb_editColor);
    
    y = y-spacing*2-btnH*1.5;
    uicontrol(panelCtl,'Style','pushbutton','String','Procesar y Cambiar Color','Position',[margin y ctlW btnH*1.5],'FontWeight','bold','Callback',@crgb_procesar);
    hStatusCRGB = uicontrol(panelCtl,'Style','text','String','Listo.','Position',[margin y-spacing-txtH*2 ctlW txtH*2]);

    axOrigC = axes(panelDisp,'Units','normalized','Position',[0.04 0.1 0.30 0.8]); title(axOrigC,'Original Color'); axis(axOrigC,'image','off');
    axMaskC = axes(panelDisp,'Units','normalized','Position',[0.36 0.1 0.30 0.8]); title(axMaskC,'Máscara Segmentada'); axis(axMaskC,'image','off');
    axModC = axes(panelDisp,'Units','normalized','Position',[0.68 0.1 0.30 0.8]); title(axModC,'Color Modificado'); axis(axModC,'image','off');

    function crgb_cargarImagen(~,~)
        appData_local=guidata(hFig);
        [fn,pn]=uigetfile({'*.jpg;*.png;*.bmp','Imágenes'},'Cargar Imagen Color'); if isequal(fn,0),return; end
        img = imread(fullfile(pn,fn));
        if size(img,3)~=3, warndlg('Seleccione una imagen a color (RGB).','Error de Imagen'); return; end
        appData_local.imgColor = img;
        imshow(appData_local.imgColor,'Parent',axOrigC); title(axOrigC,'Original Color (Clic para semilla)'); axis(axOrigC,'image');
        cla(axMaskC); title(axMaskC,'Máscara Segmentada'); axis(axMaskC,'off'); 
        cla(axModC); title(axModC,'Color Modificado'); axis(axModC,'off');
        appData_local.seedColor=[]; set(hSeedCRGBTxt,'String','N/A');
        if isfield(appData_local,'seedMarker')&&ishandle(appData_local.seedMarker)
            delete(appData_local.seedMarker); appData_local=rmfield(appData_local,'seedMarker');
        end
        set(hStatusCRGB,'String',['Imagen: ' fn]); guidata(hFig,appData_local);
    end
    function crgb_selSemilla(~,~)
        appData_local=guidata(hFig); if isempty(appData_local.imgColor),warndlg('Cargue imagen.','Aviso');return;end
        set(hStatusCRGB,'String','Clic en "Original Color" para semilla...');figure(hFig);axes(axOrigC);
        try
            [x,y]=ginput(1); if isempty(x),set(hStatusCRGB,'String','Selección cancelada.');return;end; 
            appData_local.seedColor=[round(y),round(x)];
            set(hSeedCRGBTxt,'String',['F:' num2str(round(y)) ',C:' num2str(round(x))]);
            hold(axOrigC,'on'); 
            if isfield(appData_local,'seedMarker')&&ishandle(appData_local.seedMarker),delete(appData_local.seedMarker);end
            appData_local.seedMarker = plot(axOrigC,x,y,'g+','MarkerSize',10,'LineWidth',1.5); hold(axOrigC,'off'); % Verde para diferenciar
            guidata(hFig,appData_local); set(hStatusCRGB,'String','Semilla Color seleccionada.');
        catch ME, set(hStatusCRGB,'String',['Error semilla: ' ME.message]); fprintf(2,'Error en crgb_selSemilla: %s\n',ME.message); disp(ME.getReport());end
    end
    function crgb_editThr(src,~)
        appData_local=guidata(hFig); val=str2double(get(src,'String'));
        if isnan(val)||val<0, set(src,'String',num2str(appData_local.thresholdColorDist)); else,appData_local.thresholdColorDist=val; end
        guidata(hFig,appData_local);
    end
    function crgb_editColor(~,~) 
        appData_local=guidata(hFig);
        r=round(str2double(get(hNewR,'String'))); g=round(str2double(get(hNewG,'String'))); b=round(str2double(get(hNewB,'String')));
        valid_r = ~isnan(r)&&r>=0&&r<=255; valid_g = ~isnan(g)&&g>=0&&g<=255; valid_b = ~isnan(b)&&b>=0&&b<=255;
        if valid_r, appData_local.newR=r; else, set(hNewR,num2str(appData_local.newR)); end
        if valid_g, appData_local.newG=g; else, set(hNewG,num2str(appData_local.newG)); end
        if valid_b, appData_local.newB=b; else, set(hNewB,num2str(appData_local.newB)); end
        guidata(hFig,appData_local);
    end
    function crgb_procesar(~,~)
        appData_local=guidata(hFig);
        if isempty(appData_local.imgColor)||isempty(appData_local.seedColor),warndlg('Cargue imagen y seleccione semilla.','Aviso');return;end
        set(hStatusCRGB,'String','Procesando...');drawnow;
        try
            mask = regionGrowingColor(appData_local.imgColor, appData_local.seedColor, appData_local.thresholdColorDist);
            imshow(mask,'Parent',axMaskC); title(axMaskC,'Máscara Segmentada'); axis(axMaskC,'image');
            
            img_mod = appData_local.imgColor;
            new_color_vector = uint8([appData_local.newR, appData_local.newG, appData_local.newB]);
            
            R = img_mod(:,:,1); G = img_mod(:,:,2); B = img_mod(:,:,3);
            R(mask) = new_color_vector(1); G(mask) = new_color_vector(2); B(mask) = new_color_vector(3);
            img_mod(:,:,1) = R; img_mod(:,:,2) = G; img_mod(:,:,3) = B;
            
            imshow(img_mod,'Parent',axModC); axis(axModC,'image');
            title(axModC,['Color Modificado (' num2str(new_color_vector(1)) ',' num2str(new_color_vector(2)) ',' num2str(new_color_vector(3)) ')']);
            set(hStatusCRGB,'String','Procesamiento completado.');
        catch ME
             set(hStatusCRGB,'String',['Error: ' ME.message]); fprintf(2,'Error en crgb_procesar: %s\n',ME.message); disp(ME.getReport());
        end
    end
end



% --- ====================================================== ---
% --- UI PARA ACTIVIDAD 2: FILTRADO FRECUENCIAL  ---
% --- ====================================================== ---
function filtradoFrecuencialUI()
    windowTag = 'Filtrado Frecuencial';
    hFig = figure('Name', windowTag, 'Tag', windowTag, ...
                  'Position', [200, 50, 1100, 750], ... % Aumentar tamaño
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, ...
                  'Units', 'pixels');
    
    appData.I = [];             % Imagen original (double)
    appData.Fshift = [];      % FFT centrada de la imagen original
    appData.M = 0;            % Dimensiones de la imagen
    appData.N = 0;
    appData.D_uv = [];        % Matriz de distancias D(u,v)

    % --- Paneles ---
    panelCtl = uipanel(hFig, 'Title','Configuración del Filtro','FontSize',10,'Position',[0.02 0.02 0.28 0.96]);
    panelImg = uipanel(hFig, 'Title','Visualización','FontSize',10,'Position',[0.32 0.02 0.66 0.96]);

    % --- Controles en panelCtl ---
    margin=15; ctlW=round(0.28*1100-2*margin); btnH=28; txtH=20; editH=26; spacing=8;
    current_y = round(0.96*750 - margin - btnH);

    uicontrol(panelCtl,'Style','pushbutton','String','Cargar Imagen (Grises)',...
              'Units','pixels','Position',[margin current_y ctlW btnH],'Callback',@ff_cargarImagen);
    
    current_y = current_y - spacing - round(btnH*5.5); % Espacio para el espectro original
    axEspectroOriginal = axes(panelCtl, 'Units','pixels','Position',[margin current_y ctlW round(btnH*5)]); 
    title(axEspectroOriginal,'Espectro Original (Log)'); axis(axEspectroOriginal,'image','off');

    current_y = current_y - spacing - txtH;
    uicontrol(panelCtl,'Style','text','String','Tipo de Filtro:','Units','pixels',...
              'Position',[margin current_y ctlW txtH], 'HorizontalAlignment','left');
    current_y = current_y - btnH;
    hPopupTipoFiltro = uicontrol(panelCtl,'Style','popupmenu',...
                                 'String',{'Ideal','Butterworth','Gaussiano'},...
                                 'Units','pixels','Position',[margin current_y ctlW btnH],...
                                 'Callback',@ff_actualizarVisibilidadParams);
    
    current_y = current_y - spacing - txtH;
    uicontrol(panelCtl,'Style','text','String','Clase de Filtro:','Units','pixels',...
              'Position',[margin current_y ctlW txtH], 'HorizontalAlignment','left');
    current_y = current_y - btnH;
    hPopupClaseFiltro = uicontrol(panelCtl,'Style','popupmenu',...
                                  'String',{'Pasa Bajos (LP)','Pasa Altos (HP)'},... % 'Pasa Banda (BP)' se añadirá después
                                  'Units','pixels','Position',[margin current_y ctlW btnH]);

    current_y = current_y - spacing - txtH;
    uicontrol(panelCtl,'Style','text','String','Frecuencia de Corte (D0):','Units','pixels',...
              'Position',[margin current_y ctlW*0.7 txtH], 'HorizontalAlignment','left');
    hEditD0 = uicontrol(panelCtl,'Style','edit','String','30','Units','pixels',...
                        'Position',[margin+ctlW*0.7 current_y ctlW*0.3 editH]);

    % Parámetro N para Butterworth (inicialmente invisible)
    current_y = current_y - spacing - txtH;
    hTextN = uicontrol(panelCtl,'Style','text','String','Orden n (Butterworth):','Units','pixels',...
                       'Position',[margin current_y ctlW*0.7 txtH], 'HorizontalAlignment','left','Visible','off');
    hEditN = uicontrol(panelCtl,'Style','edit','String','2','Units','pixels',...
                       'Position',[margin+ctlW*0.7 current_y ctlW*0.3 editH],'Visible','off');

    % (Aquí irían D0_centro y Ancho_W para Pasa Banda, se añadirán después)

    current_y = current_y - spacing*2 - round(btnH*1.5);
    uicontrol(panelCtl,'Style','pushbutton','String','Generar y Aplicar Filtro',...
              'Units','pixels','Position',[margin current_y ctlW round(btnH*1.5)],'FontWeight','bold',...
              'Callback',@ff_generarYAplicarFiltro);

    hStatusFF = uicontrol(panelCtl,'Style','text','String','Listo. Cargue una imagen.',...
                           'Units','pixels','Position',[margin 15 ctlW txtH*2], 'HorizontalAlignment','left');
    
    % --- Axes en panelImg (2x2) ---
    axOriginalEspacial = axes(panelImg,'Units','normalized','Position',[0.05 0.53 0.43 0.43]); 
    title(axOriginalEspacial,'Imagen Original'); axis(axOriginalEspacial,'image','off');

    axFiltroEnFrecuencia = axes(panelImg,'Units','normalized','Position',[0.52 0.53 0.43 0.43]); 
    title(axFiltroEnFrecuencia,'Filtro H(u,v)'); axis(axFiltroEnFrecuencia,'image','off');

    axFiltradaEspacial = axes(panelImg,'Units','normalized','Position',[0.05 0.05 0.43 0.43]); 
    title(axFiltradaEspacial,'Imagen Filtrada (Espacial)'); axis(axFiltradaEspacial,'image','off');

    axFiltradaEspectro = axes(panelImg,'Units','normalized','Position',[0.52 0.05 0.43 0.43]); 
    title(axFiltradaEspectro,'Espectro Filtrado (Log)'); axis(axFiltradaEspectro,'image','off');

    guidata(hFig, appData); % Guardar appData inicial
    ff_actualizarVisibilidadParams(); % Llamar para establecer visibilidad correcta de N

    % --- Callbacks para Filtrado Frecuencial (ff_) ---
    function ff_cargarImagen(~,~)
        appData_local = guidata(hFig); % Siempre obtener la última appData
        [fn,pn]=uigetfile({'*.jpg;*.png;*.bmp','Imágenes'},'Seleccionar Imagen en Escala de Grises');
        if isequal(fn,0), set(hStatusFF,'String','Carga cancelada.'); return; end
        try
            img = imread(fullfile(pn,fn));
            if size(img,3)==3, img=rgb2gray(img); end
            appData_local.I = im2double(img);
            [appData_local.M, appData_local.N] = size(appData_local.I);
            
            % Calcular D(u,v) una vez por imagen
            [U,V]=meshgrid((0:appData_local.N-1)-floor(appData_local.N/2), ...
                           (0:appData_local.M-1)-floor(appData_local.M/2));
            appData_local.D_uv = sqrt(U.^2+V.^2);
            
            F_img = fft2(appData_local.I);
            appData_local.Fshift = fftshift(F_img);
            
            imshow(log(1+abs(appData_local.Fshift)), [], 'Parent', axEspectroOriginal); 
            axis(axEspectroOriginal,'image'); title(axEspectroOriginal,'Espectro Original (Log)');
            
            imshow(appData_local.I, 'Parent', axOriginalEspacial); 
            axis(axOriginalEspacial,'image'); title(axOriginalEspacial,'Imagen Original');
            
            % Limpiar otros axes
            cla(axFiltroEnFrecuencia); title(axFiltroEnFrecuencia,'Filtro H(u,v)'); axis(axFiltroEnFrecuencia,'off');
            cla(axFiltradaEspacial); title(axFiltradaEspacial,'Imagen Filtrada (Espacial)'); axis(axFiltradaEspacial,'off');
            cla(axFiltradaEspectro); title(axFiltradaEspectro,'Espectro Filtrado (Log)'); axis(axFiltradaEspectro,'off');

            set(hStatusFF,'String',['Imagen cargada: ' fn]);
            guidata(hFig, appData_local); % Guardar cambios en appData
        catch ME
            set(hStatusFF,'String',['Error al cargar: ' ME.message]);
            errordlg(['Error al cargar imagen: ' ME.message],'Error de Carga');
        end
    end

    function ff_actualizarVisibilidadParams(~,~)
        tipoFiltroVal = get(hPopupTipoFiltro,'Value');
        tiposFiltroStr = get(hPopupTipoFiltro,'String');
        tipoSeleccionado = tiposFiltroStr{tipoFiltroVal};

        if strcmp(tipoSeleccionado, 'Butterworth')
            set(hTextN,'Visible','on');
            set(hEditN,'Visible','on');
        else
            set(hTextN,'Visible','off');
            set(hEditN,'Visible','off');
        end
        % Aquí se gestionaría la visibilidad de D0_centro y Ancho_W para Pasa Banda
    end

    function ff_generarYAplicarFiltro(~,~)
        appData_local = guidata(hFig);
        if isempty(appData_local.I)
            warndlg('Cargue una imagen primero.','Aviso'); 
            set(hStatusFF,'String','Error: No hay imagen cargada.');
            return;
        end

        try
            set(hStatusFF,'String','Generando y aplicando filtro...'); drawnow;
            
            D0 = str2double(get(hEditD0,'String'));
            if isnan(D0) || D0 <= 0
                warndlg('D0 debe ser un número positivo.','Error de Parámetro');
                set(hStatusFF,'String','Error: D0 inválido.');
                return;
            end

            tipoFiltroVal = get(hPopupTipoFiltro,'Value');
            tiposFiltroStr = get(hPopupTipoFiltro,'String');
            tipoFiltro = tiposFiltroStr{tipoFiltroVal};

            claseFiltroVal = get(hPopupClaseFiltro,'Value');
            clasesFiltroStr = get(hPopupClaseFiltro,'String');
            claseFiltro = clasesFiltroStr{claseFiltroVal};
            
            H_uv = zeros(appData_local.M, appData_local.N); % Filtro
            D = appData_local.D_uv; % Matriz de distancias

            switch tipoFiltro
                case 'Ideal'
                    switch claseFiltro
                        case 'Pasa Bajos (LP)'
                            H_uv = double(D <= D0);
                        case 'Pasa Altos (HP)'
                            H_uv = double(D > D0);
                        
                    end
                case 'Butterworth'
                    n_order = str2double(get(hEditN,'String'));
                    if isnan(n_order) || n_order <= 0
                        warndlg('Orden n para Butterworth debe ser positivo.','Error');
                        set(hStatusFF,'String','Error: Orden n inválido.');
                        return;
                    end
                    % Evitar división por cero si D(u,v) es cero para HP
                    D_no_cero = D; 
                    D_no_cero(D_no_cero == 0) = eps; % eps es un número muy pequeño

                    switch claseFiltro
                        case 'Pasa Bajos (LP)'
                            H_uv = 1./(1 + (D./D0).^(2*n_order));
                        case 'Pasa Altos (HP)'
                            H_uv = 1./(1 + (D0./D_no_cero).^(2*n_order));
                        % case 'Pasa Banda (BP)'
                    end
                case 'Gaussiano'
                    switch claseFiltro
                        case 'Pasa Bajos (LP)'
                            H_uv = exp(-(D.^2)./(2*(D0^2)));
                        case 'Pasa Altos (HP)'
                            H_uv = 1 - exp(-(D.^2)./(2*(D0^2)));
                        % case 'Pasa Banda (BP)'
                    end
            end

            % Visualizar el filtro H(u,v)
            imshow(fftshift(H_uv), [], 'Parent', axFiltroEnFrecuencia); % Centrar para visualización
            axis(axFiltroEnFrecuencia,'image'); title(axFiltroEnFrecuencia,['Filtro H(u,v): ' tipoFiltro ' ' claseFiltro]);

            % Aplicar el filtro
            G_shift = appData_local.Fshift .* H_uv; % Multiplicación en frecuencia (sin fftshift en H_uv aquí porque D_uv ya está centrado)
                                                 % OJO: Si D_uv no estuviera pre-centrado, H_uv necesitaría fftshift antes de multiplicar
                                                 % Como D_uv se generó con meshgrid centrado, H_uv también está centrado.
                                                 % Por lo tanto, Fshift (ya centrado) se multiplica con H_uv (ya centrado).

            % Imagen filtrada en dominio espacial
            g_spatial = real(ifft2(ifftshift(G_shift))); % Des-centrar antes de IFFT
            imshow(g_spatial, [], 'Parent', axFiltradaEspacial);
            axis(axFiltradaEspacial,'image'); title(axFiltradaEspacial,'Imagen Filtrada (Espacial)');

            % Espectro de la imagen filtrada
            imshow(log(1+abs(G_shift)), [], 'Parent', axFiltradaEspectro); % G_shift ya está centrado
            axis(axFiltradaEspectro,'image'); title(axFiltradaEspectro,'Espectro Filtrado (Log)');
            
            set(hStatusFF,'String','Filtro aplicado exitosamente.');

        catch ME
            set(hStatusFF,'String',['Error al aplicar filtro: ' ME.message]);
            errordlg(['Error al aplicar filtro: ' ME.message],'Error de Filtrado');
            fprintf(2,'Error en ff_generarYAplicarFiltro: %s\n',ME.message); disp(ME.getReport());
        end
    end
end


% --- ====================================================== ---
% --- UI PARA ACTIVIDAD 3: DETECCIÓN DE ROSTROS            ---
% --- ====================================================== ---
function deteccionRostrosUI()
    windowTag = 'Detección de Rostros';
    hFig = figure('Name', windowTag, 'Tag', windowTag, ...
                  'Position', [450, 80, 700, 550], ...
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, ...
                  'Units', 'pixels');
    appData.img = [];
    panelCtl = uipanel(hFig,'Title','Controles','Position',[0.02 0.05 0.96 0.20]);
    panelImg = uipanel(hFig,'Title','Imagen con Detecciones','Position',[0.02 0.28 0.96 0.70]);
    axImg = axes(panelImg,'Units','normalized','Position',[0.05 0.05 0.9 0.9]); axis(axImg,'image','off');
    uicontrol(panelCtl,'Style','pushbutton','String','Cargar Imagen','Position',[20 50 150 30],'Callback',@dr_cargarImagen);
    uicontrol(panelCtl,'Style','pushbutton','String','Detectar Rostros (Viola-Jones)','Position',[190 50 200 30],'FontWeight','bold','Callback',@dr_detectarRostros);
    hStatusDR = uicontrol(panelCtl,'Style','text','String','Listo.','Position',[20 15 370 25], 'HorizontalAlignment','left');
    guidata(hFig,appData);
    function dr_cargarImagen(~,~)
        appData_local = guidata(hFig); [fn,pn]=uigetfile({'*.jpg;*.png;*.bmp;*.jpeg;*.jfif','Imágenes'},'Seleccionar Imagen'); if isequal(fn,0), return; end
        appData_local.img = imread(fullfile(pn,fn)); imshow(appData_local.img, 'Parent', axImg); axis(axImg,'image'); title(axImg,'Imagen Cargada');
        set(hStatusDR, 'String', ['Imagen: ' fn]); guidata(hFig,appData_local);
    end
    function dr_detectarRostros(~,~)
        appData_local = guidata(hFig); if isempty(appData_local.img), warndlg('Cargue imagen.','Aviso'); return; end
        set(hStatusDR, 'String', 'Detectando...'); drawnow;
        try
            faceDetector = vision.CascadeObjectDetector(); bboxes = step(faceDetector, appData_local.img);
            if isempty(bboxes), set(hStatusDR, 'String', 'No se detectaron rostros.'); imshow(appData_local.img,'Parent',axImg); title(axImg,'No detectados'); else
                labels = arrayfun(@(x) ['Rostro ' num2str(x)],1:size(bboxes,1),'Uni',false);
                imgDetected = insertObjectAnnotation(appData_local.img,'rectangle',bboxes,labels,'TextBoxOpacity',0.7,'FontSize',10,'TextColor','yellow');
                imshow(imgDetected,'Parent',axImg); title(axImg,[num2str(size(bboxes,1)) ' rostro(s) detectado(s)']);
                set(hStatusDR, 'String', [num2str(size(bboxes,1)) ' rostro(s) detectado(s).']);
            end; axis(axImg,'image');
        catch ME, set(hStatusDR, 'String', ['Error: ' ME.message]); end
    end
end


% --- ====================================================== ---
% --- UI PARA ACTIVIDAD 4: FILTRO DE BELLEZA (MEJORADA)    ---
% --- ====================================================== ---
function filtroBellezaUI()
    windowTag = 'Filtro de Belleza Avanzado';
    hFig = figure('Name', windowTag, 'Tag', windowTag, ...
                  'Position', [150, 50, 1200, 700], ... % Ventana más grande
                  'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                  'CloseRequestFcn', @subActivity_CloseRequestFcn, ...
                  'Units', 'pixels');
    
    appData.imgOriginal = [];
    appData.imgGray = []; % Para detección de rostro si es necesario
    appData.faceBBox = []; % [x, y, width, height]
    appData.skinSeedPoint = []; % [fila, columna] en coords de imgOriginal
    appData.skinMask = [];    % Máscara binaria de la piel
    appData.imgConFiltro = [];

    % --- Paneles ---
    panelCtl = uipanel(hFig,'Title','Pasos y Controles','FontSize',10,'Position',[0.02 0.02 0.28 0.96]);
    panelDisp = uipanel(hFig,'Title','Visualización','FontSize',10,'Position',[0.32 0.02 0.66 0.96]);

    % --- Controles en panelCtl ---
    margin=15; ctlW=round(0.28*1200-2*margin); btnH=28; txtH=20; editH=26; spacing=8;
    current_y = round(0.96*700 - margin - btnH);

    uicontrol(panelCtl,'Style','pushbutton','String','1. Cargar Imagen y Detectar Rostro',...
              'Units','pixels','Position',[margin current_y ctlW btnH],'FontWeight','bold','Callback',@fb_paso1_cargarDetectar);
    
    current_y = current_y - btnH - spacing;
    hStatusPaso1 = uicontrol(panelCtl,'Style','text','String','Estado: Esperando imagen.',...
                           'Units','pixels','Position',[margin current_y ctlW txtH],'HorizontalAlignment','left');

    current_y = current_y - btnH - spacing*2;
    uicontrol(panelCtl,'Style','pushbutton','String','2. Seleccionar Semilla en Piel',...
              'Units','pixels','Position',[margin current_y ctlW btnH],'FontWeight','bold','Callback',@fb_paso2_seleccionarSemilla, 'Enable','off','Tag','btnSelSemilla');
    hSeedStatusTxt = uicontrol(panelCtl,'Style','text','String','Semilla no seleccionada','Units','pixels','Position',[margin current_y-txtH-spacing/2 ctlW txtH]);


    current_y = current_y - btnH - spacing*2 - txtH;
    uicontrol(panelCtl,'Style','text','String','Umbral Dist. Color (Piel):','Units','pixels',...
              'Position',[margin current_y ctlW*0.7 txtH], 'HorizontalAlignment','left');
    hEditUmbralPiel = uicontrol(panelCtl,'Style','edit','String','35','Units','pixels',...
                                'Position',[margin+ctlW*0.7 current_y ctlW*0.3 editH]);

    current_y = current_y - editH - spacing;
    uicontrol(panelCtl,'Style','pushbutton','String','3. Segmentar Piel',...
              'Units','pixels','Position',[margin current_y ctlW btnH],'FontWeight','bold','Callback',@fb_paso3_segmentarPiel, 'Enable','off','Tag','btnSegPiel');
    hStatusPaso3 = uicontrol(panelCtl,'Style','text','String','Estado: Esperando semilla.',...
                           'Units','pixels','Position',[margin current_y-txtH-spacing/2 ctlW txtH],'HorizontalAlignment','left');

    current_y = current_y - btnH - spacing*2 - txtH;
    uicontrol(panelCtl,'Style','text','String','4. Método de Suavizado:','Units','pixels',...
              'Position',[margin current_y ctlW txtH], 'HorizontalAlignment','left');
    current_y = current_y - btnH;
    hPopupMetodoSuavizado = uicontrol(panelCtl,'Style','popupmenu',...
                                      'String',{'Espacial (Gaussiano)', 'Frecuencial LP (Gaussiano FFT)'},... % ,'Frecuencial LP (Butterworth FFT)'
                                      'Units','pixels','Position',[margin current_y ctlW btnH],...
                                      'Callback',@fb_actualizarParamsSuavizado);
    
    % Parámetros para Espacial Gaussiano
    current_y = current_y - spacing - txtH;
    hTxtSigmaEspacial = uicontrol(panelCtl,'Style','text','String','Sigma (Gaussiano Espacial):','Units','pixels',...
                                  'Position',[margin current_y ctlW*0.7 txtH], 'HorizontalAlignment','left','Visible','on');
    hEditSigmaEspacial = uicontrol(panelCtl,'Style','edit','String','2','Units','pixels',...
                                   'Position',[margin+ctlW*0.7 current_y ctlW*0.3 editH],'Visible','on');
    
    % Parámetros para Frecuencial LP
    hTxtD0Frec = uicontrol(panelCtl,'Style','text','String','D0 (Corte FFT LP):','Units','pixels',...
                           'Position',[margin current_y ctlW*0.7 txtH], 'HorizontalAlignment','left','Visible','off');
    hEditD0Frec = uicontrol(panelCtl,'Style','edit','String','50','Units','pixels',...
                            'Position',[margin+ctlW*0.7 current_y ctlW*0.3 editH],'Visible','off');
    % (Aquí iría 'Orden n' para Butterworth si se añade)

    current_y = current_y - editH - spacing*2;
    uicontrol(panelCtl,'Style','pushbutton','String','5. Aplicar Filtro de Belleza',...
              'Units','pixels','Position',[margin current_y ctlW btnH*1.2],'FontWeight','bold','Callback',@fb_paso4_aplicarBelleza, 'Enable','off','Tag','btnAplicarFiltro');
    
    hStatusFinal = uicontrol(panelCtl,'Style','text','String','Estado General.',...
                           'Units','pixels','Position',[margin 15 ctlW txtH*2.5],'HorizontalAlignment','left');

    % --- Axes en panelDisp (1x3) ---
    axOriginal = axes(panelDisp,'Units','normalized','Position',[0.03 0.1 0.30 0.85]); 
    title(axOriginal,'Original y Detección'); axis(axOriginal,'image','off');

    axSkinMask = axes(panelDisp,'Units','normalized','Position',[0.35 0.1 0.30 0.85]); 
    title(axSkinMask,'Máscara de Piel'); axis(axSkinMask,'image','off');

    axResultadoFinal = axes(panelDisp,'Units','normalized','Position',[0.67 0.1 0.30 0.85]); 
    title(axResultadoFinal,'Resultado Filtro Belleza'); axis(axResultadoFinal,'image','off');
    
    guidata(hFig, appData);
    fb_actualizarParamsSuavizado(); % Estado inicial de visibilidad de parámetros

    % --- Callbacks para Filtro de Belleza (fb_) ---
    function fb_paso1_cargarDetectar(~,~)
        appData_local = guidata(hFig);
        [fn,pn]=uigetfile({'*.jpg;*.png;*.bmp;*.jpeg','Imágenes'},'Cargar Imagen');
        if isequal(fn,0), set(hStatusPaso1,'String','Carga cancelada.'); return; end
        try
            appData_local.imgOriginal = imread(fullfile(pn,fn));
            appData_local.imgFiltrada = appData_local.imgOriginal; % Inicializar
            
            if size(appData_local.imgOriginal,3) == 3
                appData_local.imgGray = rgb2gray(appData_local.imgOriginal);
            else
                appData_local.imgGray = appData_local.imgOriginal; % Ya es gris
            end

            faceDetector = vision.CascadeObjectDetector();
            appData_local.faceBBox = step(faceDetector, appData_local.imgGray); % Detectar en gris

            imshow(appData_local.imgOriginal, 'Parent', axOriginal); axis(axOriginal,'image');
            title(axOriginal,'Original y Detección');
            
            cla(axSkinMask); title(axSkinMask,'Máscara de Piel'); axis(axSkinMask,'off');
            cla(axResultadoFinal); title(axResultadoFinal,'Resultado Filtro Belleza'); axis(axResultadoFinal,'off');
            appData_local.skinSeedPoint = []; appData_local.skinMask = []; % Resetear
            set(hSeedStatusTxt,'String','Semilla no seleccionada');

            if isempty(appData_local.faceBBox)
                set(hStatusPaso1,'String','No se detectaron rostros.');
                set(hStatusFinal,'String','Proceso detenido: No hay rostro.');
                set(findobj(hFig,'Tag','btnSelSemilla'),'Enable','off');
                set(findobj(hFig,'Tag','btnSegPiel'),'Enable','off');
                set(findobj(hFig,'Tag','btnAplicarFiltro'),'Enable','off');
            else
                % Mostrar el primer rostro detectado
                hold(axOriginal, 'on');
                rectangle('Parent',axOriginal,'Position',appData_local.faceBBox(1,:),'EdgeColor','g','LineWidth',2);
                hold(axOriginal, 'off');
                set(hStatusPaso1,'String',['Rostro detectado. Pasos 2-3 habilitados.']);
                set(hStatusFinal,'String','Listo para seleccionar semilla de piel.');
                set(findobj(hFig,'Tag','btnSelSemilla'),'Enable','on');
                set(findobj(hFig,'Tag','btnSegPiel'),'Enable','off'); % Se habilita tras seleccionar semilla
                set(findobj(hFig,'Tag','btnAplicarFiltro'),'Enable','off');
            end
            guidata(hFig,appData_local);
        catch ME
            set(hStatusPaso1,'String',['Error: ' ME.message]);
            errordlg(['Error cargando/detectando: ' ME.message],'Error Paso 1');
        end
    end

    function fb_paso2_seleccionarSemilla(~,~)
        appData_local = guidata(hFig);
        if isempty(appData_local.imgOriginal) || isempty(appData_local.faceBBox)
            warndlg('Primero cargue imagen y detecte un rostro.','Aviso'); return;
        end
        set(hStatusFinal,'String','Clic en la piel (dentro del rostro) en la imagen original...');
        figure(hFig); axes(axOriginal); % Asegurar foco
        try
            [x,y] = ginput(1);
            if isempty(x), set(hStatusFinal,'String','Selección de semilla cancelada.'); return; end
            
            appData_local.skinSeedPoint = [round(y),round(x)];
            
            % Limpiar marcador anterior si existe
            if isfield(appData_local,'skinSeedMarker') && ishandle(appData_local.skinSeedMarker)
                delete(appData_local.skinSeedMarker);
            end
            
            hold(axOriginal,'on');
            appData_local.skinSeedMarker = plot(axOriginal,x,y,'b+','MarkerSize',12,'LineWidth',2);
            hold(axOriginal,'off');
            
            set(hSeedStatusTxt,'String',['Semilla: F=' num2str(round(y)) ', C=' num2str(round(x))]);
            set(hStatusFinal,'String','Semilla seleccionada. Listo para Paso 3.');
            set(findobj(hFig,'Tag','btnSegPiel'),'Enable','on');
            guidata(hFig,appData_local);
        catch ME
            set(hStatusFinal,'String',['Error al seleccionar semilla: ' ME.message]);
            errordlg(['Error seleccionando semilla: ' ME.message],'Error Paso 2');
        end
    end

    function fb_paso3_segmentarPiel(~,~)
        appData_local = guidata(hFig);
        if isempty(appData_local.imgOriginal) || isempty(appData_local.skinSeedPoint)
            warndlg('Cargue imagen y seleccione semilla de piel primero.','Aviso'); return;
        end
        
        umbralDistColor = str2double(get(hEditUmbralPiel,'String'));
        if isnan(umbralDistColor) || umbralDistColor <=0
            warndlg('Umbral de distancia de color debe ser positivo.','Error'); return;
        end
        set(hStatusFinal,'String','Segmentando piel...'); drawnow;
        
        try
            % Usar regionGrowingColor en la imagen original a color
            mask_piel_completa = regionGrowingColor(appData_local.imgOriginal, appData_local.skinSeedPoint, umbralDistColor);
            
            % Refinar la máscara para que solo esté dentro del bounding box del rostro
            % Crear una máscara a partir del bounding box
            bbox_mask = false(size(appData_local.imgOriginal,1), size(appData_local.imgOriginal,2));
            if ~isempty(appData_local.faceBBox)
                bb = round(appData_local.faceBBox(1,:)); % Usar el primer rostro
                % Asegurar que las coordenadas del bbox estén dentro de los límites
                y_start = max(1, bb(2));
                y_end = min(size(bbox_mask,1), bb(2)+bb(4)-1);
                x_start = max(1, bb(1));
                x_end = min(size(bbox_mask,2), bb(1)+bb(3)-1);
                if y_start <= y_end && x_start <= x_end % Solo si el bbox es válido
                    bbox_mask(y_start:y_end, x_start:x_end) = true;
                end
                appData_local.skinMask = mask_piel_completa & bbox_mask; % Intersección
            else
                appData_local.skinMask = mask_piel_completa; % Usar máscara completa si no hay bbox (poco probable aquí)
            end

            imshow(appData_local.skinMask, 'Parent', axSkinMask); axis(axSkinMask,'image');
            title(axSkinMask,'Máscara de Piel Segmentada');
            set(hStatusPaso3,'String','Piel segmentada.');
            set(hStatusFinal,'String','Piel segmentada. Listo para Paso 5 (Aplicar Filtro).');
            set(findobj(hFig,'Tag','btnAplicarFiltro'),'Enable','on');
            guidata(hFig,appData_local);
        catch ME
            set(hStatusPaso3,'String',['Error segmentando: ' ME.message]);
            set(hStatusFinal,'String','Error en segmentación de piel.');
            errordlg(['Error segmentando piel: ' ME.message],'Error Paso 3');
        end
    end
    
    function fb_actualizarParamsSuavizado(~,~)
        metodoVal = get(hPopupMetodoSuavizado,'Value');
        metodosStr = get(hPopupMetodoSuavizado,'String');
        metodoSel = metodosStr{metodoVal};

        if strcmp(metodoSel, 'Espacial (Gaussiano)')
            set(hTxtSigmaEspacial,'Visible','on'); set(hEditSigmaEspacial,'Visible','on');
            set(hTxtD0Frec,'Visible','off'); set(hEditD0Frec,'Visible','off');
            % Ocultar 'Orden n' si se añade para Butterworth FFT
        elseif contains(metodoSel, 'Frecuencial') % Para cualquier frecuencial
            set(hTxtSigmaEspacial,'Visible','off'); set(hEditSigmaEspacial,'Visible','off');
            set(hTxtD0Frec,'Visible','on'); set(hEditD0Frec,'Visible','on');
            % Gestionar visibilidad de 'Orden n' si Butterworth FFT está presente y seleccionado
        end
    end

    function fb_paso4_aplicarBelleza(~,~)
        appData_local = guidata(hFig);
        if isempty(appData_local.imgOriginal) || isempty(appData_local.skinMask)
            warndlg('Cargue imagen y segmente la piel primero.','Aviso'); return;
        end
        
        metodoVal = get(hPopupMetodoSuavizado,'Value');
        metodosStr = get(hPopupMetodoSuavizado,'String');
        metodoSel = metodosStr{metodoVal};
        
        set(hStatusFinal,'String',['Aplicando filtro: ' metodoSel '...']); drawnow;
        
        I_original_double = im2double(appData_local.imgOriginal);
        I_suavizada_double = I_original_double; % Inicializar
        
        try
            if strcmp(metodoSel, 'Espacial (Gaussiano)')
                sigma_espacial = str2double(get(hEditSigmaEspacial,'String'));
                if isnan(sigma_espacial) || sigma_espacial <=0, warndlg('Sigma espacial inválido.','Error');return;end
                
                kernel_size = 2*ceil(3*sigma_espacial)+1;
                h_gauss = fspecial('gaussian', [kernel_size kernel_size], sigma_espacial);
                
                % Aplicar filtro gaussiano a toda la imagen (color si es color)
                I_completamente_suavizada_espacial = imfilter(I_original_double, h_gauss, 'replicate');
                I_suavizada_double = I_completamente_suavizada_espacial;

            elseif strcmp(metodoSel, 'Frecuencial LP (Gaussiano FFT)')
                D0_frec = str2double(get(hEditD0Frec,'String'));
                if isnan(D0_frec) || D0_frec <=0, warndlg('D0 frecuencial inválido.','Error');return;end

                [M,N,~] = size(I_original_double);
                [U,V] = meshgrid((0:N-1)-floor(N/2), (0:M-1)-floor(M/2));
                D_uv = sqrt(U.^2 + V.^2);
                
                H_glp = exp(-(D_uv.^2)./(2*(D0_frec^2))); % Filtro Gaussiano LP
                
                I_suavizada_fft_double = zeros(size(I_original_double));
                for canal = 1:size(I_original_double,3) % Iterar por canales R,G,B (o 1 si es gris)
                    canal_actual = I_original_double(:,:,canal);
                    F_canal = fftshift(fft2(canal_actual));
                    G_canal_shift = F_canal .* H_glp; % H_glp ya está centrado por D_uv
                    canal_suavizado = real(ifft2(ifftshift(G_canal_shift)));
                    I_suavizada_fft_double(:,:,canal) = canal_suavizado;
                end
                I_suavizada_double = I_suavizada_fft_double;
            
          
            end

            % --- Blending: Aplicar el suavizado solo a la piel ---
            % Asegurar que skinMask sea compatible para multiplicación (expandir a 3D si img es color)
            skinMask_expanded = appData_local.skinMask;
            if size(I_original_double,3) > 1 && size(skinMask_expanded,3) == 1
                skinMask_expanded = repmat(skinMask_expanded, [1,1,size(I_original_double,3)]);
            end
            
            % Convertir a double para blending si no lo son ya
            skinMask_double = double(skinMask_expanded); 
            
            appData_local.imgConFiltro = I_original_double .* (1-skinMask_double) + I_suavizada_double .* skinMask_double;
            appData_local.imgConFiltro = im2uint8(appData_local.imgConFiltro); % Convertir de vuelta a uint8 para display

            imshow(appData_local.imgConFiltro, 'Parent', axResultadoFinal); axis(axResultadoFinal,'image');
            title(axResultadoFinal,['Resultado: ' metodoSel]);
            set(hStatusFinal,'String','Filtro de belleza aplicado.');
            guidata(hFig,appData_local);

        catch ME
            set(hStatusFinal,'String',['Error aplicando filtro: ' ME.message]);
            errordlg(['Error aplicando filtro: ' ME.message],'Error Paso 5');
            disp(ME.getReport());
        end
    end
end
% --- FIN DE filtroBellezaUI ---