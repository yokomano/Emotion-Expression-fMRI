function roi_extract()
% Create spherical ROIs and extract mean No > Yes contrast values.

%% USER SETTINGS
spmDir = 'C:\path\to\spm';
firstLevelRoot = 'D:\path\to\firstlevel_decision_all_subjects';
includedSubjectsFile = 'D:\path\to\included_subjects.txt';
outputDir = 'D:\path\to\roi_output';
contrastName = 'Decision_emo_N_gt_Y';
expectedN = 40;

rois(1).name = 'Right_TPJ';
rois(1).center = [60 -58 35];
rois(1).radius = 6;
rois(2).name = 'Right_dlPFC';
rois(2).center = [48 21 44];
rois(2).radius = 6;

addpath(spmDir);
if isempty(which('spm')), error('SPM was not found.'); end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
maskDir = fullfile(outputDir,'roi_masks');
if ~exist(maskDir,'dir'), mkdir(maskDir); end

subjects = strtrim(readlines(includedSubjectsFile));
subjects(subjects == "") = [];
if numel(subjects) ~= expectedN
    error('Expected %d subjects, but found %d.',expectedN,numel(subjects));
end

[refCon,found] = find_contrast_file(fullfile(firstLevelRoot,subjects(1)),contrastName);
if ~found, error('Reference contrast not found.'); end
Vref = spm_vol(refCon);

maskPaths = strings(numel(rois),1);
for i = 1:numel(rois)
    maskPaths(i) = fullfile(maskDir,sprintf('%s_%dmm.nii',rois(i).name,rois(i).radius));
    create_spherical_mask(Vref,rois(i).center,rois(i).radius,char(maskPaths(i)));
end

subject_id = strings(expectedN,1);
values = nan(expectedN,numel(rois));

for s = 1:numel(subjects)
    subject_id(s) = subjects(s);
    [conFile,found] = find_contrast_file(fullfile(firstLevelRoot,subjects(s)),contrastName);
    if ~found, error('Contrast not found for %s.',subjects(s)); end
    Vcon = spm_vol(conFile);
    Y = spm_read_vols(Vcon);

    for i = 1:numel(rois)
        Vmask = spm_vol(maskPaths(i));
        M = spm_read_vols(Vmask) > 0;
        if ~isequal(Vcon.dim,Vmask.dim) || any(abs(Vcon.mat(:)-Vmask.mat(:)) > 1e-6)
            error('Geometry mismatch for %s.',subjects(s));
        end
        x = Y(M & isfinite(Y));
        if isempty(x), error('No valid ROI voxels for %s.',subjects(s)); end
        values(s,i) = mean(x);
    end
end

T = table(subject_id,values(:,1),values(:,2), ...
    'VariableNames',{'subject_id','Right_TPJ_mean','Right_dlPFC_mean'});
writetable(T,fullfile(outputDir,'roi_values.csv'));
end

function create_spherical_mask(Vref,center,radius,outputPath)
[xx,yy,zz] = ndgrid(1:Vref.dim(1),1:Vref.dim(2),1:Vref.dim(3));
vox = [xx(:)';yy(:)';zz(:)';ones(1,numel(xx))];
mm = Vref.mat * vox;
d = sqrt((mm(1,:)-center(1)).^2 + (mm(2,:)-center(2)).^2 + (mm(3,:)-center(3)).^2);
mask = reshape(d <= radius,Vref.dim);
Vout = Vref;
Vout.fname = outputPath;
Vout.dt = [spm_type('uint8') 0];
spm_write_vol(Vout,uint8(mask));
end

function [contrastFile,found] = find_contrast_file(subjectDir,contrastName)
contrastFile = '';
found = false;
d = dir(fullfile(subjectDir,'**','SPM.mat'));
for i = 1:numel(d)
    folder = d(i).folder;
    S = load(fullfile(folder,'SPM.mat'),'SPM');
    if ~isfield(S.SPM,'xCon') || isempty(S.SPM.xCon), continue; end
    names = string({S.SPM.xCon.name});
    idx = find(names == contrastName,1);
    if ~isempty(idx)
        f = fullfile(folder,sprintf('con_%04d.nii',idx));
        if exist(f,'file')
            contrastFile = f;
            found = true;
            return;
        end
    end
end
end
