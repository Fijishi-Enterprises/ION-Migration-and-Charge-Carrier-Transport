function plot_bands(sol,plotindex)
% Plots the energy levels as functions of space at the times specified
% by plotindex, which must be a vector of integers corresponding to the
% desired points in sol.time (for example, plotindex = [1,101,201,301]).

% Check sol structure
if size(sol,2)>1 % received structure array from IS simulation
    error(['plot_bands was given a solution structure array from an ' ...
        'impedance spectroscopy simulation. To use plot_bands for the '...
        'n-th sample frequency solution, use `plot_bands(sol(n),...)`'])
elseif isfield(sol,'X') % received reduced solution structure
    error(['plot_bands was given a reduced solution structure from an ' ...
        'impedance spectroscopy simulation. To use plot_bands with an ' ...
        'IS solution, ensure reduced_output=false'])
end

% Unpack the parameters, spatial vectors and dimensional solution variables
[EcE, Ec, Ev, EvH] = struct2array(sol.params,{'EcE','Ec','Ev','EvH'});
[x, xE, xH] = struct2array(sol.vectors,{'x','xE','xH'});
[phi, phiE, phiH, Efn, Efp, EfnE, EfpH] = ...
    struct2array(sol.dstrbns,{'phi','phiE','phiH','Efn','Efp','EfnE','EfpH'});

if ~any(Efn)
    % Compute and then load the quasi-Fermi levels
    sol = compute_QFLs(sol);
    [Efn, Efp, EfnE, EfpH] = ...
        struct2array(sol.dstrbns,{'Efn','Efp','EfnE','EfpH'});
end

% Set default figure options
set(0,'defaultAxesFontSize',10); % Make axes labels smaller
set(0,'defaultTextInterpreter','latex'); % For latex axis labels
set(0,'defaultAxesTickLabelInterpreter','latex'); % For latex tick labels
set(0,'defaultLegendInterpreter','latex'); % For latex legends

% Shading
if length(plotindex)>1
    shade = @(tt) double((tt-plotindex(1))/(plotindex(end)-plotindex(1)));
else
    shade = @(tt) 1;
end
P_colour = [1 0 1];
phi_colour = [119 172 48]/255; % green
n_colour = [0 0 1];
p_colour = [1 0 0];

% Plot the energy levels in space at the chosen times
figure;
hold on;
for tt = plotindex
    % Choose the reference energy level
    shift = phiE(tt,1); % sets the metal/ETL contact vacuum level as zero
    % Compute the vacuum level
    Evac  = shift-phi(tt,:);
    EvacE = shift-phiE(tt,:);
    EvacH = shift-phiH(tt,:);
    % Plot the vacuum level
    plot(x, Evac, '--','color',shade(tt)*phi_colour,'HandleVisibility','off');
    plot(xE,EvacE,'--','color',shade(tt)*phi_colour,'HandleVisibility','off');
    plot(xH,EvacH,'--','color',shade(tt)*phi_colour,'HandleVisibility','off');
    % Plot the band energy levels
    plot(x, Evac+Ec,  'color',shade(tt)*phi_colour,'HandleVisibility','off');
    plot(x, Evac+Ev,  'color',shade(tt)*phi_colour,'HandleVisibility','off');
    plot(xE,EvacE+EcE,'color',shade(tt)*phi_colour,'HandleVisibility','off');
    plot(xH,EvacH+EvH,'color',shade(tt)*phi_colour,'HandleVisibility','off');
    % Plot the quasi-Fermi levels
    plot(x, shift+Efn(tt,:), 'color',shade(tt)*n_colour,'HandleVisibility','off');
    plot(x, shift+Efp(tt,:), 'color',shade(tt)*p_colour,'HandleVisibility','off');
    plot(xE,shift+EfnE(tt,:),'color',shade(tt)*n_colour,'HandleVisibility','off');
    plot(xH,shift+EfpH(tt,:),'color',shade(tt)*p_colour,'HandleVisibility','off');
end

% Legend
plot(nan, nan, '--','color',phi_colour,'DisplayName','Vacuum level');
plot(nan, nan, '-','color', phi_colour,'DisplayName','Band energy level');
plot(nan, nan, '-','color', n_colour,'DisplayName','Electron QFL');
plot(nan, nan, '-','color', p_colour,'DisplayName','Hole QFL');
legend('Location','best')

xlabel('Distance (nm)'); ylabel('Energy (eV)');

% Reset default figure options
set(0,'defaultAxesFontSize',18); % Make axes labels larger

end
