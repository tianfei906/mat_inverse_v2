function show_plots(handles, lang)
% SHOW PLOTS
% Show final plots.
%
% Author: Pablo Pizarro @ppizarror.com, 2017.
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

% Get solution status
solution_status = getappdata(handles.root, 'solution_ok');

% Check if solution is ok
if ~solution_status
    disp_error(handles, lang, 65);
    return
end

% Get solution from app
niter = getappdata(handles.root, 'n_iter');
vr_iter = getappdata(handles.root, 'vr_iter');
vp_iter = getappdata(handles.root, 'vp_iter');
vs_iter = getappdata(handles.root, 'vs_iter');
dns_iter = getappdata(handles.root, 'dns_iter');

% Get data from GUI
freq = getappdata(handles.root, 'disp_freq');
vr_exp = getappdata(handles.root, 'disp_vrexp');
sigma = get(handles.param_inv_sigma, 'string');
mu = get(handles.param_inv_mu, 'string');
maxiter = get(handles.param_maxiter, 'string');
tol_vs = get(handles.param_tolvs, 'string');
table_data = get(handles.initial_solution, 'Data');

% Create thk, vp, vs and dns vectors
nrow = getappdata(handles.root, 'initial_table_validsize');
thk = [table_data{1:nrow-1, 1}]';
vs = [table_data{1:nrow, 2}]';
vp = [table_data{1:nrow, 3}]';
dns = [table_data{1:nrow, 4}]';

% Calculated vs Experimental dispertion curve
h1 = figure('Name', lang{66}, 'NumberTitle', 'off'); %#ok<*NASGU>
errorbar(freq, vr_exp, sigma, 'ro');
hold on;
final_iteration = niter;
plot(freq, vr_iter(:, final_iteration));
xlabel('Frequency $(Hz)$', 'Interpreter', 'latex');
ylabel('Velocidad de Fase $(m/s)$', 'Interpreter', 'latex');
hold off;

% Shear velocity on depth plot
vsfinal = vs_iter(:, niter)';
vsinitial = vs';
thk = thk';
if ~ isempty(vsfinal)
    cumthk = [0 cumsum(thk)]; depth = 0; velocity = vsfinal(1); mdl_vel = vsinitial(1);
    for j = 1:length(thk)
        depth = [depth cumthk(j + 1) cumthk(j + 1)]; %#ok<*AGROW>
        velocity = [velocity vsfinal(j) vsfinal(j + 1)];
        mdl_vel = [mdl_vel vsinitial(j) vsinitial(j + 1)];
    end
    depth = [depth sum(thk) + thk(length(thk))];
    velocity = [velocity vsfinal(length(vsfinal))];
    mdl_vel = [mdl_vel vsinitial(length(vsinitial))];
 
    h3 = figure('Name', 'Perfil de Velocidad de Corte', 'NumberTitle', 'off'); % #ok<*NASGU>
    plot(velocity, depth, 'b', mdl_vel, depth, 'k--');
    set(gca, 'YDir', 'reverse', 'XAxisLocation', 'top');
    set(gca, 'Position', [0.13 0.05 0.775 0.815], 'PlotBoxAspectRatio', [0.75 1 1]);
    xlabel('Velocidad de onda de corte $V_s$ $(m/sec)$', 'Interpreter', 'latex');
    ylabel('Profundidad $(m)$', 'Interpreter', 'latex');
    legend('Modelo inverso', 'Valor real');
end

end