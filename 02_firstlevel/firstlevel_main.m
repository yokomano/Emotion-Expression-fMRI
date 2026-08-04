function firstlevel_main()
% Representative Figure 3 first-level model for sub-001.
% Edit USER SETTINGS, then run this function.

%% USER SETTINGS
rootDir = 'D:\path\to\MRI_project';
behRoot = 'D:\path\to\behavioral_results';
spmDir  = 'C:\path\to\spm';

subName = 'sub-001';
emID = 'em0001';
nRuns = 4;
TR = 0.8;

derivRoot = fullfile(rootDir,'derivatives');
outDir = fullfile(rootDir,'firstlevel_model1_public',subName);
qualFile = fullfile(behRoot,'results_qualtrics.xlsx');
if ~exist(outDir,'dir'), mkdir(outDir); end

addpath(spmDir);
if isempty(which('spm')), error('SPM not found.'); end
spm('Defaults','fMRI');
spm_jobman('initcfg');

[valZ,aroZ] = get_valence_arousal_z(emID,qualFile);

clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = {outDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for r = 1:nRuns
    funcDir = fullfile(derivRoot,subName,'ses-01','func');
    patt = sprintf(['^s6tmp_%s_ses-01_task-em_run-%02d' ...
        '_space-MNI152NLin2009cAsym_desc-preproc_bold\.nii$'],subName,r);
    scans = spm_select('ExtFPList',funcDir,patt,Inf);
    if isempty(scans), error('Images not found: %s',patt); end
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = cellstr(scans);

    logFile = find_logfile_for_run(behRoot,emID,r);
    R = extract_onsets(logFile,valZ,aroZ);

    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).name = 'Emo_Sentence_all';
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).onset = R.emo_onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).duration = R.emo_durs;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(1).name = 'Valence_z';
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(1).param = R.emo_valZ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(1).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(2).name = 'Arousal_z';
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(2).param = R.emo_aroZ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod(2).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2) = make_cond('Ctrl_Sentence_all',R.ctrl_onsets,R.ctrl_durs);
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(3) = make_cond('Question_Hit',R.hit_onsets,R.hit_durs);
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(4) = make_cond('Question_Miss',R.miss_onsets,R.miss_durs);

    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = struct('name',{},'val',{});
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;

    confTsv = fullfile(funcDir,sprintf('%s_ses-01_task-em_run-%02d_desc-confounds_timeseries.tsv',subName,r));
    matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = {make_motion6(confTsv)};
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
spm_jobman('run',matlabbatch);

clear est
est{1}.spm.stats.fmri_est.spmmat = {fullfile(outDir,'SPM.mat')};
est{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',est);
end

function c=make_cond(name,onset,duration)
c.name=name; c.onset=onset; c.duration=duration; c.tmod=0;
c.pmod=struct('name',{},'param',{},'poly',{}); c.orth=0;
end

function logFile=find_logfile_for_run(behRoot,emID,r)
emDir=fullfile(behRoot,emID);
d=dir(fullfile(emDir,sprintf('fmri_log_*_%s_S%d.csv',emID,r)));
keep=true(numel(d),1);
for i=1:numel(d)
    keep(i)=~contains(d(i).name,'emotion','IgnoreCase',true) && ...
            ~contains(d(i).name,'control','IgnoreCase',true) && ...
            ~contains(d(i).name,'PRAC','IgnoreCase',true);
end
d=d(keep);
if isempty(d), error('Combined log not found.'); end
if numel(d)>1, [~,i]=max([d.datenum]); d=d(i); end
logFile=fullfile(emDir,d.name);
end

function R=extract_onsets(logFile,valZ,aroZ)
o=detectImportOptions(logFile,'VariableNamingRule','preserve');
T=readtable(logFile,o);
cond=lower(strtrim(string(T.condition)));
sentOn=T.t_sentence_on(:); sentOff=T.t_sentence_off(:);
qOn=T.t_question_on(:); rt=T.primary_rt_sec(:);
key=strtrim(string(T.all_key_presses_json));
sentNo=T.sentence_no_1to96(:);
isEmo=cond=="emo"; isCtrl=cond=="ctrl"; isHit=key~="[]"; isMiss=key=="[]";

eo=sentOn(isEmo); ed=sentOff(isEmo)-sentOn(isEmo); es=sentNo(isEmo);
v=isfinite(eo)&isfinite(ed)&isfinite(es); eo=eo(v); ed=ed(v); es=es(v);
ev=valZ(es); ea=aroZ(es);
if any(~isfinite(ev))||any(~isfinite(ea)), error('Missing rating.'); end

co=sentOn(isCtrl); cd=sentOff(isCtrl)-sentOn(isCtrl);
v=isfinite(co)&isfinite(cd); co=co(v); cd=cd(v);

ho=qOn(isHit)+rt(isHit); v=isfinite(ho); ho=ho(v);
mo=qOn(isMiss); mo=mo(isfinite(mo));

R.emo_onsets=eo; R.emo_durs=ed; R.emo_valZ=ev(:); R.emo_aroZ=ea(:);
R.ctrl_onsets=co; R.ctrl_durs=cd;
R.hit_onsets=ho; R.hit_durs=zeros(size(ho));
R.miss_onsets=mo; R.miss_durs=2*ones(size(mo));
end

function [valZ,aroZ]=get_valence_arousal_z(emID,qualFile)
Q=readtable(qualFile,'VariableNamingRule','preserve');
row=find(lower(strtrim(string(Q.Q3)))==lower(emID),1);
if isempty(row), error('Participant not found in ratings file.'); end
val=nan(1,96); aro=nan(1,96);
for k=1:96
    val(k)=todouble(Q.(sprintf('S_Q%d_1',k))(row));
    aro(k)=todouble(Q.(sprintf('S_Q%d_2',k))(row));
end
valZ=(val-mean(val,'omitnan'))/std(val,'omitnan');
aroZ=(aro-mean(aro,'omitnan'))/std(aro,'omitnan');
end

function x=todouble(raw)
if iscell(raw), raw=raw{1}; end
if isstring(raw), raw=char(raw); end
if ischar(raw), x=str2double(strtrim(raw)); else, x=double(raw); end
end

function outTxt=make_motion6(confTsv)
T=readtable(confTsv,'FileType','text','Delimiter','\t','VariableNamingRule','preserve');
cols={'trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'};
M=T{:,cols};
[d,n,~]=fileparts(confTsv); outTxt=fullfile(d,[n '_motion6.txt']);
writematrix(M,outTxt,'Delimiter','tab');
end
