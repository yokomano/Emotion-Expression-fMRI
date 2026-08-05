function figure3()
% Create public-facing Figure 3 brain-map panels.
%
% Panels:
%   A. Emotion > Control
%   B. Arousal positive
%   C. Valence negative
%
% This script expects thresholded statistical images that were exported
% from the corresponding second-level SPM analyses using:
%   voxel-level p < .001 (uncorrected)
%   cluster-level FWE p < .05
%
% The script displays each thresholded map on the SPM canonical T1 image
% and saves one PNG per panel.
%
% Edit USER SETTINGS, then run:
%   figure3

%% USER SETTINGS
spmDir = 'C:\path\to\spm';

figure3aMap = [ ...
    'D:\path\to\secondlevel_public\' ...
    'Figure3a_Emo_gt_Ctrl\thresholded_clusterFWE05.nii'];

figure3bMap = [ ...
    'D:\path\to\secondlevel_public\' ...
    'Figure3b_Arousal_pos\thresholded_clusterFWE05.nii'];

figure3cMap = [ ...
    'D:\path\to\secondlevel_public\' ...
    'Figure3c_Valence_neg\thresholded_clusterFWE05.nii'];

outputDir = 'D:\path\to\figure_output\Figure3';

% Representative display coordinates from manuscript results
coordinates.figure3a = [
    -43  28 -13
      7 -53  23
     41  33 -18
    -50 -70  23
     50 -63  25
     45 -34   4
     29 -89  -1
];

coordinates.figure3b = [
     38 -34 -16
    -36 -34 -13
];

coordinates.figure3c = [
     50  28  -4
    -50  24   8
     62 -15 -11
];

%% INITIALIZE
addpath(spmDir);

if isempty(which('spm'))
    error('SPM was not found. Check spmDir.');
end

spm('Defaults', 'fMRI');

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

canonicalT1 = fullfile(spmDir, 'canonical', 'avg152T1.nii');

if ~exist(canonicalT1, 'file')
    error('SPM canonical T1 image was not found: %s', canonicalT1);
end

%% CREATE PANELS
create_panel( ...
    canonicalT1, ...
    figure3aMap, ...
    coordinates.figure3a, ...
    'Figure 3A: Emotion > Control', ...
    fullfile(outputDir, 'Figure3A_Emotion_gt_Control.png'));

create_panel( ...
    canonicalT1, ...
    figure3bMap, ...
    coordinates.figure3b, ...
    'Figure 3B: Arousal positive', ...
    fullfile(outputDir, 'Figure3B_Arousal_positive.png'));

create_panel( ...
    canonicalT1, ...
    figure3cMap, ...
    coordinates.figure3c, ...
    'Figure 3C: Valence negative', ...
    fullfile(outputDir, 'Figure3C_Valence_negative.png'));

fprintf('Figure 3 panels saved in: %s\n', outputDir);

end


function create_panel( ...
    backgroundImage, ...
    statisticalMap, ...
    coordinates, ...
    panelTitle, ...
    outputFile)

if ~exist(statisticalMap, 'file')
    error('Thresholded statistical map was not found: %s', ...
        statisticalMap);
end

fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 1400 900], ...
    'Visible', 'off');

spm_orthviews('Reset');

spm_orthviews('Image', backgroundImage, [0.05 0.08 0.90 0.84]);
spm_orthviews('AddColouredImage', 1, statisticalMap, [1 0 0]);
spm_orthviews('Redraw');

annotation( ...
    fig, ...
    'textbox', ...
    [0.05 0.93 0.90 0.05], ...
    'String', panelTitle, ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'EdgeColor', 'none');

coordinateText = format_coordinates(coordinates);

annotation( ...
    fig, ...
    'textbox', ...
    [0.05 0.01 0.90 0.07], ...
    'String', coordinateText, ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 10, ...
    'EdgeColor', 'none');

exportgraphics(fig, outputFile, 'Resolution', 300);

close(fig);

fprintf('Saved: %s\n', outputFile);

end


function textOut = format_coordinates(coordinates)

parts = strings(size(coordinates, 1), 1);

for idx = 1:size(coordinates, 1)

    parts(idx) = sprintf( ...
        '[%d %d %d]', ...
        coordinates(idx, 1), ...
        coordinates(idx, 2), ...
        coordinates(idx, 3));
end

textOut = "Representative peak coordinates: " + ...
    strjoin(parts, ', ');

end
