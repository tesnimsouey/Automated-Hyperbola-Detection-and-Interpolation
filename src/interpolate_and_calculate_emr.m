function [emr_vals, interpolated_curves] = interpolate_and_calculate_emr(curve_points)
    % INTERPOLATE_AND_CALCULATE_EMR - Interpole et calcule l'EMR
    % Input: curve_points - Points de la courbe originale [x, y]
    % Outputs:
    %   emr_vals - Vecteur d'EMR pour chaque méthode
    %   interpolated_curves - Courbes interpolées
    
    % Extraire les coordonnées
    x_orig = curve_points(:, 2);
    y_orig = curve_points(:, 1);
    
    % Paramètre d'interpolation
    t_orig = linspace(0, 1, length(x_orig))';
    
    % Méthodes d'interpolation
    methods = {'spline', 'lineaire', 'polynomiale'};
    emr_vals = zeros(length(methods), 1);
    interpolated_curves = struct();
    
    for m_idx = 1:length(methods)
        method = methods{m_idx};
        
        try
            switch method
                case 'spline'
                    % Interpolation spline cubique
                    pp_x = spline(t_orig, x_orig);
                    pp_y = spline(t_orig, y_orig);
                    
                    t_interp = linspace(0, 1, 100)';
                    x_interp = ppval(pp_x, t_interp);
                    y_interp = ppval(pp_y, t_interp);
                    
                case 'lineaire'
                    % Interpolation linéaire
                    t_interp = linspace(0, 1, 100)';
                    x_interp = interp1(t_orig, x_orig, t_interp, 'linear');
                    y_interp = interp1(t_orig, y_orig, t_interp, 'linear');
                    
                case 'polynomiale'
                    % Interpolation polynomiale (degré 3)
                    p_x = polyfit(t_orig, x_orig, min(3, length(t_orig)-1));
                    p_y = polyfit(t_orig, y_orig, min(3, length(t_orig)-1));
                    
                    t_interp = linspace(0, 1, 100)';
                    x_interp = polyval(p_x, t_interp);
                    y_interp = polyval(p_y, t_interp);
                    
                otherwise
                    continue;
            end
            
            % Stocker la courbe interpolée
            interpolated_curves.(method).x = x_interp;
            interpolated_curves.(method).y = y_interp;
            
            % Calcul de l'EMR
            emr_vals(m_idx) = calculate_emr(x_orig, y_orig, x_interp, y_interp);
            
        catch
            % En cas d'erreur d'interpolation
            interpolated_curves.(method).x = [];
            interpolated_curves.(method).y = [];
            emr_vals(m_idx) = NaN;
        end
    end
end