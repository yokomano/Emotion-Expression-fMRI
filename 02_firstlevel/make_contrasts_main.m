function make_contrasts_main()
% Figure 3 contrasts identified from SPM.xX.name.

%% USER SETTINGS
spmMat = 'D:\path\to\MRI_project\firstlevel_model1_public\sub-001\SPM.mat';
spmDir = 'C:\path\to\spm';

addpath(spmDir);
spm('Defaults','fMRI');
spm_jobman('initcfg');

load(spmMat,'SPM');
names=SPM.xX.name;
n=numel(names);

defs={
'Emo_all_gt_Ctrl','Emo_Sentence_all*bf(1)',1,'Ctrl_Sentence_all*bf(1)',-1
'Ctrl_gt_Emo_all','Ctrl_Sentence_all*bf(1)',1,'Emo_Sentence_all*bf(1)',-1
'Valence_z_pos','Valence_z^1*bf(1)',1,'',0
'Valence_z_neg','Valence_z^1*bf(1)',-1,'',0
'Arousal_z_pos','Arousal_z^1*bf(1)',1,'',0
'Arousal_z_neg','Arousal_z^1*bf(1)',-1,'',0
};

clear matlabbatch
matlabbatch{1}.spm.stats.con.spmmat={spmMat};
matlabbatch{1}.spm.stats.con.delete=1;

for i=1:size(defs,1)
    c=zeros(1,n);
    a=find(contains(names,defs{i,2}));
    if isempty(a), error('Regressor not found: %s',defs{i,2}); end
    c(a)=defs{i,3}/numel(a);

    if ~isempty(defs{i,4})
        b=find(contains(names,defs{i,4}));
        if isempty(b), error('Regressor not found: %s',defs{i,4}); end
        c(b)=defs{i,5}/numel(b);
    end

    matlabbatch{1}.spm.stats.con.consess{i}.tcon.name=defs{i,1};
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.weights=c;
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep='none';
end

spm_jobman('run',matlabbatch);
end
