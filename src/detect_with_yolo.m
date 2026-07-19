function [detections, scores] = detect_with_yolo(img_path, model_path)
    % DETECT_WITH_YOLO - Détection d'hyperboles avec YOLO
    % Nécessite Computer Vision Toolbox et Deep Learning Toolbox
    
    % Charger le modèle YOLO pré-entraîné
    try
        net = yolov4ObjectDetector(model_path);
    catch
        % Télécharger un modèle par défaut
        fprintf('Téléchargement du modèle YOLO...\n');
        % À adapter selon vos besoins
        net = yolov4ObjectDetector('csp-darknet53-coco');
    end
    
    % Détection
    [bboxes, scores, labels] = detect(net, img_path);
    
    % Filtrer pour les hyperboles
    hyperbola_mask = contains(lower(labels), 'hyperbola') | ...
                     contains(lower(labels), 'curve') | ...
                     (scores > 0.5);
    
    detections = bboxes(hyperbola_mask, :);
    scores = scores(hyperbola_mask);
    
    % Calcul des métriques si ground truth disponible
    % [precision, recall, f1, iou] = calculate_metrics(detections, ground_truth);
end