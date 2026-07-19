function plot_interpolation_results(original_points, interpolated_curves, ...
                                    hyperbola_id, output_folder)
    % PLOT_INTERPOLATION_RESULTS - Visualise les résultats d'interpolation
    
    figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    
    % Tracer la courbe originale
    plot(original_points(:,2), original_points(:,1), ...
        'k-', 'LineWidth', 3, 'DisplayName', 'Original');
    hold on;
    
    % Tracer les courbes interpolées
    colors = {'r--', 'g-.', 'b:'};
    methods = fieldnames(interpolated_curves);
    
    for m_idx = 1:length(methods)
        method = methods{m_idx};
        if ~isempty(interpolated_curves.(method).x)
            plot(interpolated_curves.(method).x, ...
                 interpolated_curves.(method).y, ...
                 colors{m_idx}, 'LineWidth', 2, ...
                 'DisplayName', upper(method));
        end
    end
    
    % Configuration du graphique
    axis equal;
    grid on;
    title(sprintf('Interpolation - %s', hyperbola_id), 'FontSize', 14);
    xlabel('X');
    ylabel('Y');
    legend('Location', 'best');
    
    % Sauvegarder l'image
    output_path = fullfile(output_folder, [hyperbola_id, '.png']);
    saveas(gcf, output_path);
    close(gcf);
end