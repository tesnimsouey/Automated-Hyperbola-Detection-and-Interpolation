function [contours, detected_img] = detect_hyperbolas_matlab(img)
    % DETECT_HYPERBOLAS_MATLAB - Détecte les hyperboles dans une image
    % Input: img - Image couleur ou niveaux de gris
    % Outputs:
    %   contours - Cell array des contours détectés
    %   detected_img - Image annotée avec les détections
    
    % Convertir en niveaux de gris si nécessaire
    if size(img, 3) == 3
        gray_img = rgb2gray(img);
    else
        gray_img = img;
    end
    
    % Amélioration du contraste (CLAHE)
    gray_img = adapthisteq(gray_img, 'ClipLimit', 0.02);
    
    % Seuillage adaptatif
    binary_img = imbinarize(gray_img, 'adaptive', ...
        'Sensitivity', 0.4, 'ForegroundPolarity', 'dark');
    
    % Nettoyage morphologique
    se = strel('disk', 2);
    binary_img = imclose(binary_img, se);
    binary_img = imopen(binary_img, se);
    
    % Suppression des petits objets
    binary_img = bwareaopen(binary_img, 50);
    
    % Détection des contours
    binary_img = imfill(binary_img, 'holes');
    [B, L] = bwboundaries(binary_img, 'noholes');
    
    % Filtrer les contours pour détecter les hyperboles
    contours = {};
    detected_img = img;
    
    if size(detected_img, 3) == 1
        detected_img = cat(3, detected_img, detected_img, detected_img);
    end
    
    for k = 1:length(B)
        boundary = B{k};
        
        % Calcul des caractéristiques
        area = polyarea(boundary(:,2), boundary(:,1));
        perimeter = sum(sqrt(sum(diff(boundary).^2, 2)));
        
        % Critères pour une hyperbole
        if area > 100 && perimeter > 50
            % Approximation de la courbe
            [~, idx] = unique(round(boundary), 'rows', 'stable');
            simplified_boundary = boundary(idx, :);
            
            if size(simplified_boundary, 1) > 10
                contours{end+1} = simplified_boundary;
                
                % Annoter l'image
                detected_img = insertShape(detected_img, 'Polygon', ...
                    [simplified_boundary(:,2), simplified_boundary(:,1)], ...
                    'Color', 'red', 'LineWidth', 2);
                
                % Ajouter un identifiant
                center = mean(simplified_boundary);
                detected_img = insertText(detected_img, ...
                    [center(2), center(1)], ...
                    sprintf('H%d', length(contours)), ...
                    'FontSize', 12, 'TextColor', 'yellow', ...
                    'BoxColor', 'black');
            end
        end
    end
    
    % Si aucun contour détecté
    if isempty(contours) 
        contours = {};
    end
end