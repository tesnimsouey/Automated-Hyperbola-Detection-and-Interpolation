function emr = calculate_emr(x_orig, y_orig, x_interp, y_interp)
    % CALCULATE_EMR - Calcule l'Erreur Moyenne Relative
    % Formule: EMR = (1/N) * Σ ||P_interp - P_orig|| / ||P_orig||
    
    % Échantillonner des points correspondants
    N = min(length(x_orig), 20);
    idx_orig = round(linspace(1, length(x_orig), N));
    idx_interp = round(linspace(1, length(x_interp), N));
    
    P_orig = [x_orig(idx_orig), y_orig(idx_orig)];
    P_interp = [x_interp(idx_interp), y_interp(idx_interp)];
    
    % Calcul des distances
    distances = sqrt(sum((P_interp - P_orig).^2, 2));
    norms_orig = sqrt(sum(P_orig.^2, 2));
    
    % Éviter la division par zéro
    norms_orig(norms_orig == 0) = 1;
    
    % Calcul de l'EMR
    relative_errors = distances ./ norms_orig;
    emr = mean(relative_errors);
end