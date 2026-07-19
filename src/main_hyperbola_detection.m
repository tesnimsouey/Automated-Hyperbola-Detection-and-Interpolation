%% MAIN HYPERBOLA DETECTION AND INTERPOLATION
% Programme principal pour la détection et l'interpolation des hyperboles

clear all; close all; clc;

%% Configuration des dossiers
input_folders = {'with_aug/', 'without_aug/'};
output_folders = {'results/with_aug/', 'results/without_aug/'};
interp_folder = 'results/interpolation/';

% Création des dossiers de sortie
if ~exist('results', 'dir')
    mkdir('results');
end
for i = 1:length(output_folders)
    if ~exist(output_folders{i}, 'dir')
        mkdir(output_folders{i});
    end
end
if ~exist(interp_folder, 'dir')
    mkdir(interp_folder);
end

%% Initialisation des structures de données
detection_summary = table('Size', [0, 2], ...
    'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'image_name', 'nb_hyperboles'});

hyperbola_data = struct();
emr_results = [];

%% Traitement des images
for folder_idx = 1:length(input_folders)
    input_folder = input_folders{folder_idx};
    output_folder = output_folders{folder_idx};
    
    % Liste des images
    image_files = dir(fullfile(input_folder, '*.png'));
    image_files = [image_files; dir(fullfile(input_folder, '*.jpg'))];
    image_files = [image_files; dir(fullfile(input_folder, '*.jpeg'))];
    
    for img_idx = 1:length(image_files)
        fprintf('Traitement de %s...\n', image_files(img_idx).name);
        
        % Charger l'image
        img_path = fullfile(input_folder, image_files(img_idx).name);
        img = imread(img_path);
        
        % Détection des hyperboles
        [contours, detected_img] = detect_hyperbolas_matlab(img);
        
        % Enregistrer l'image annotée
        output_path = fullfile(output_folder, image_files(img_idx).name);
        imwrite(detected_img, output_path);
        
        % Sauvegarder les données
        nb_hyperboles = length(contours);
        new_row = {image_files(img_idx).name, nb_hyperboles};
        detection_summary = [detection_summary; new_row];
        
        % Stocker les coordonnées
        for h_idx = 1:nb_hyperboles
            hyperbola_id = sprintf('%s_hyperbole_%d', ...
                image_files(img_idx).name(1:end-4), h_idx);
            
            % Extraire les points de la courbe
            if ~isempty(contours{h_idx})
                curve_points = contours{h_idx};
                
                % Interpolation et calcul EMR
                [emr_vals, interpolated_curves] = ...
                    interpolate_and_calculate_emr(curve_points);
                
                % Sauvegarder les résultats
                hyperbola_data.(hyperbola_id).original = curve_points;
                hyperbola_data.(hyperbola_id).interpolated = interpolated_curves;
                hyperbola_data.(hyperbola_id).emr = emr_vals;
                
                % Ajouter aux résultats EMR
                method_names = {'spline', 'lineaire', 'polynomiale'};
                for m_idx = 1:length(method_names)
                    emr_row = struct();
                    emr_row.image_name = image_files(img_idx).name;
                    emr_row.hyperbole_id = hyperbola_id;
                    emr_row.method = method_names{m_idx};
                    emr_row.EMR = emr_vals(m_idx);
                    
                    if isempty(emr_results)
                        emr_results = emr_row;
                    else
                        emr_results(end+1) = emr_row;
                    end
                end
                
                % Visualisation de l'interpolation
                plot_interpolation_results(curve_points, interpolated_curves, ...
                    hyperbola_id, interp_folder);
            end
        end
    end
end

%% Sauvegarde des résultats
% Sauvegarde du récapitulatif CSV
writetable(detection_summary, 'results/detection_summary.csv');

% Sauvegarde des données JSON
json_str = jsonencode(hyperbola_data);
fid = fopen('results/hyperbola_data.json', 'w');
fprintf(fid, '%s', json_str);
fclose(fid);

% Sauvegarde des résultats EMR
emr_table = struct2table(emr_results);
writetable(emr_table, 'results/emr_results.csv');

% Calcul des EMR moyennes par méthode
methods = unique({emr_results.method});
emr_means = zeros(length(methods), 1);

for m_idx = 1:length(methods)
    method_mask = strcmp({emr_results.method}, methods{m_idx});
    emr_vals = [emr_results(method_mask).EMR];
    emr_means(m_idx) = mean(emr_vals(~isnan(emr_vals)));
end

% Tableau final des EMR moyennes
emr_summary = table(methods', emr_means, ...
    'VariableNames', {'method', 'EMR_moyenne'});
writetable(emr_summary, 'results/emr_summary.csv');

disp('Traitement terminé avec succès!');
fprintf('Nombre total d''images traitées: %d\n', height(detection_summary));
fprintf('Nombre total d''hyperboles détectées: %d\n', sum(detection_summary.nb_hyperboles));