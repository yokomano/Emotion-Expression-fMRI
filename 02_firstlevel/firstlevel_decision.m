function firstlevel_decision()
% Representative integrated decision model for Figure 4.
% Loads archived multi-condition files and removes Miss/empty conditions.

%% USER SETTINGS
rootDir = 'D:\path\to\MRI_project';
condDir = 'D:\path\to\conditions_mat';
spmDir  = 'C:\path\to\spm';

subName='sub-001';
emID='em0001';
nRuns=4;

derivRoot=fullfile(rootDir,'derivatives');
outDir=fullfile(rootDir,'firstlevel_decision_public',subName);
if ~exist(outDir,'dir'), mkdir(outDir); end

addpath(spmDir);
spm('Defaults','fMRI');
spm_jobman('initcfg');

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir={outDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units='secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT=0.8;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t=16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0=8;

for r=1:nRuns
    funcDir=fullfile(derivRoot,subName,'ses-01','func');
    patt=sprintf('^s6tmp_%s_ses-01_task-em_run-%02d_.*desc-preproc_bold\.nii$',subName,r);
    scans=spm_select('ExtFPList',funcDir,patt,Inf);
    if isempty(scans), error('Images not found for run %d.',r); end
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans=cellstr(scans);

    mot=fullfile(funcDir,sprintf('%s_ses-01_task-em_run-%02d_desc-confounds_timeseries_motion6.txt',subName,r));
    if ~exist(mot,'file'), error('Motion file not found: %s',mot); end
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg={mot};

    C=load(fullfile(condDir,sprintf('%s_S%d_conditions.mat',emID,r)));
    names=C.names; onsets=C.onsets; durations=C.durations;
    if ischar(names), names=cellstr(names); end
    hasPmod=isfield(C,'pmod'); if hasPmod, pmod=C.pmod; end

    remove=false(size(names));
    for k=1:numel(names)
        remove(k)=strcmpi(strtrim(names{k}),'Miss')||isempty(onsets{k});
    end
    keep=find(~remove);
    names=names(keep); onsets=onsets(keep); durations=durations(keep);
    if hasPmod, pmod=pmod(keep); end

    tmp=fullfile(outDir,sprintf('%s_run-%02d_multicond_public.mat',subName,r));
    if hasPmod, save(tmp,'names','onsets','durations','pmod');
    else, save(tmp,'names','onsets','durations'); end

    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi={tmp};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond=struct([]);
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress=struct([]);
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf=128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact=struct('name',{},'levels',{});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs=[0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt=1;
matlabbatch{1}.spm.stats.fmri_spec.global='None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh=0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask={''};
matlabbatch{1}.spm.stats.fmri_spec.cvi='AR(1)';
spm_jobman('run',matlabbatch);

clear est
est{1}.spm.stats.fmri_est.spmmat={fullfile(outDir,'SPM.mat')};
est{1}.spm.stats.fmri_est.method.Classical=1;
spm_jobman('run',est);
end
