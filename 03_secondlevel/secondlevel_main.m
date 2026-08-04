function secondlevel_main()
% Group-level one-sample t-tests for the principal manuscript results.
% Contrast files are identified by contrast name in each first-level SPM.mat.
%
% Edit USER SETTINGS, then run:
%   secondlevel_main

%% USER SETTINGS
spmDir = 'C:\path\to\spm';

model1Root = 'D:\path\to\firstlevel_main_all_subjects';
decisionRoot = 'D:\path\to\firstlevel_decision_all_subjects';
secondRoot = 'D:\path\to\secondlevel_public';

expectedN = 40;

analyses = {
    'Figure3a_Emo_gt_Ctrl', model1Root,    'Emo_all_gt_Ctrl'
    'Figure3b_Arousal_pos', model1Root,    'Arousal_z_pos'
    'Figure3c_Valence_neg', model1Root,    'Valence_z_neg'
    'Figure4_No_gt_Yes',    decisionRoot,  'Decision_emo_N_gt_Y'
};

addpath(spmDir);

if isempty(which('spm'))
    error('SPM was not found. Check spmDir.');
end

spm('Defaults', 'fMRI');
spm_jobman('initcfg');

if ~exist(secondRoot, 'dir')
    mkdir(secondRoot);
end

for analysisIdx = 1:size(analyses, 1)

    outputName = analyses{analysisIdx, 1};
    firstRoot = analyses{analysisIdx, 2};
    contrastName = analyses{analysisIdx, 3};

    subjectDirs = dir(fullfile(firstRoot, 'sub-*'));
    subjectDirs = subjectDirs([subjectDirs.isdir]);
    subjectNames = sort({subjectDirs.name});

    scans = {};
    includedSubjects = {};

    for subjectIdx = 1:numel(subjectNames)

        subjectDir = fullfile(firstRoot, subjectNames{subjectIdx});

        [contrastFile, found] = find_contrast_file( ...
            subjectDir, contrastName);

        if found
            scans{end + 1, 1} = [contrastFile ',1']; %#ok<AGROW>
            includedSubjects{end + 1, 1} = ...
                subjectNames{subjectIdx}; %#ok<AGROW>
        end
    end

    if numel(scans) ~= expectedN
        error('%s: expected N=%d, but found N=%d.', ...
            outputName, expectedN, numel(scans));
    end

    outDir = fullfile(secondRoot, outputName);

    if exist(outDir, 'dir')
        error('Output directory already exists: %s', outDir);
    end

    mkdir(outDir);

    writelines( ...
        string(includedSubjects), ...
        fullfile(outDir, 'included_subjects.txt'));

    clear matlabbatch

    % One-sample t-test
    matlabbatch{1}.spm.stats.factorial_design.dir = {outDir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;

    matlabbatch{1}.spm.stats.factorial_design.cov = ...
        struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});

    matlabbatch{1}.spm.stats.factorial_design.multi_cov = ...
        struct('files', {}, 'iCFI', {}, 'iCC', {});

    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};

    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    % Estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
        {fullfile(outDir, 'SPM.mat')};

    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Positive group-mean contrast
    matlabbatch{3}.spm.stats.con.spmmat = ...
        {fullfile(outDir, 'SPM.mat')};

    matlabbatch{3}.spm.stats.con.delete = 1;

    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
        [contrastName '_group_positive'];

    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    spm_jobman('run', matlabbatch);

    fprintf('Completed: %s\n', outputName);
end

fprintf('All second-level analyses completed.\n');

end


function [contrastFile, found] = find_contrast_file( ...
    subjectDir, contrastName)

contrastFile = '';
found = false;

spmFiles = dir(fullfile(subjectDir, '**', 'SPM.mat'));

for idx = 1:numel(spmFiles)

    spmMat = fullfile( ...
        spmFiles(idx).folder, ...
        spmFiles(idx).name);

    S = load(spmMat, 'SPM');

    if ~isfield(S.SPM, 'xCon') || isempty(S.SPM.xCon)
        continue;
    end

    contrastNames = string({S.SPM.xCon.name});
    contrastIdx = find(contrastNames == contrastName, 1);

    if isempty(contrastIdx)
        continue;
    end

    candidate = fullfile( ...
        spmFiles(idx).folder, ...
        sprintf('con_%04d.nii', contrastIdx));

    if exist(candidate, 'file')
        contrastFile = candidate;
        found = true;
        return;
    end
end

end
