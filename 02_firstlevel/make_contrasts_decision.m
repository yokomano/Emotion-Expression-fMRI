function make_contrasts_decision()
% Figure 4 decision contrasts identified from SPM.xX.name.

%% USER SETTINGS
spmMat = 'D:\path\to\MRI_project\firstlevel_decision_public\sub-001\SPM.mat';
spmDir = 'C:\path\to\spm';

addpath(spmDir);
spm('Defaults','fMRI');
spm_jobman('initcfg');

load(spmMat,'SPM');
names=SPM.xX.name;
n=numel(names);

defs={
'Decision_emo_N_gt_Y','Decision_emo_N*bf(1)',1,'Decision_emo_Y*bf(1)',-1
'Decision_emo_Y_gt_N','Decision_emo_Y*bf(1)',1,'Decision_emo_N*bf(1)',-1
'Decision_ctrl_N_gt_Y','Decision_ctrl_N*bf(1)',1,'Decision_ctrl_Y*bf(1)',-1
'Decision_ctrl_Y_gt_N','Decision_ctrl_Y*bf(1)',1,'Decision_ctrl_N*bf(1)',-1
};

clear matlabbatch
matlabbatch{1}.spm.stats.con.spmmat={spmMat};
matlabbatch{1}.spm.stats.con.delete=1;

for i=1:size(defs,1)
    a=find(contains(names,defs{i,2}));
    b=find(contains(names,defs{i,4}));
    if isempty(a)||isempty(b), error('Regressor not found for %s.',defs{i,1}); end

    c=zeros(1,n);
    c(a)=defs{i,3}/numel(a);
    c(b)=defs{i,5}/numel(b);

    matlabbatch{1}.spm.stats.con.consess{i}.tcon.name=defs{i,1};
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.weights=c;
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep='none';
end

spm_jobman('run',matlabbatch);
end
