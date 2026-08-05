function roi_statistics()
% Correlate ROI values with self-construal and TAS-20 scores.

%% USER SETTINGS
roiValuesFile = 'D:\path\to\roi_values.csv';
selfConstrualFile = 'D:\path\to\SC_Collectivism_forMRI.csv';
tasFile = 'D:\path\to\TAS20_with_demographics_N40_z.csv';
outputDir = 'D:\path\to\roi_statistics';
expectedN = 40;

if ~exist(outputDir,'dir'), mkdir(outputDir); end

ROI = readtable(roiValuesFile,'VariableNamingRule','preserve');
SC = readtable(selfConstrualFile,'VariableNamingRule','preserve');
TAS = readtable(tasFile,'VariableNamingRule','preserve');

ROI.subject_id = normalize_id(ROI.subject_id);
if ismember('subject_id',SC.Properties.VariableNames)
    SC.subject_id = normalize_id(SC.subject_id);
else
    SC.subject_id = normalize_id(SC.ParticipantID);
end
if ismember('subject_id',TAS.Properties.VariableNames)
    TAS.subject_id = normalize_id(TAS.subject_id);
else
    TAS.subject_id = normalize_id(TAS.ParticipantID);
end

SC = SC(:,{'subject_id','SC_Collectivism_z'});
TAS = TAS(:,{'subject_id','TAS20_total_z'});
T = innerjoin(ROI,SC,'Keys','subject_id');
T = innerjoin(T,TAS,'Keys','subject_id');
if height(T) ~= expectedN
    error('Expected N=%d after joining, but found N=%d.',expectedN,height(T));
end
writetable(T,fullfile(outputDir,'roi_questionnaire_joined.csv'));

tests = {
'Right_TPJ_SC','SC_Collectivism_z','Right_TPJ_mean','Self-construal score (z)','Right TPJ mean contrast value'
'Right_TPJ_TAS20','TAS20_total_z','Right_TPJ_mean','TAS-20 total score (z)','Right TPJ mean contrast value'
'Right_dlPFC_SC','SC_Collectivism_z','Right_dlPFC_mean','Self-construal score (z)','Right dlPFC mean contrast value'
'Right_dlPFC_TAS20','TAS20_total_z','Right_dlPFC_mean','TAS-20 total score (z)','Right dlPFC mean contrast value'
};

analysis = strings(4,1);
N = nan(4,1); r = nan(4,1); p_raw = nan(4,1); p_bonferroni = nan(4,1);

for i = 1:4
    analysis(i) = tests{i,1};
    x = double(T.(tests{i,2}));
    y = double(T.(tests{i,3}));
    valid = isfinite(x) & isfinite(y);
    N(i) = sum(valid);
    [r(i),p_raw(i)] = corr(x(valid),y(valid),'Type','Pearson');
    p_bonferroni(i) = min(p_raw(i)*4,1);

    f = figure('Visible','off');
    scatter(x(valid),y(valid),60,'filled'); hold on;
    b = polyfit(x(valid),y(valid),1);
    xl = linspace(min(x(valid)),max(x(valid)),100);
    plot(xl,polyval(b,xl),'LineWidth',1.5);
    grid on;
    xlabel(tests{i,4}); ylabel(tests{i,5});
    title(sprintf('r = %.3f, p = %.4f, p_{Bonf} = %.4f, N = %d',r(i),p_raw(i),p_bonferroni(i),N(i)));
    exportgraphics(f,fullfile(outputDir,analysis(i)+".png"),'Resolution',300);
    close(f);
end

Results = table(analysis,N,r,p_raw,p_bonferroni);
writetable(Results,fullfile(outputDir,'roi_correlations.csv'));
disp(Results);
end

function out = normalize_id(raw)
out = lower(strtrim(string(raw)));
for i = 1:numel(out)
    tok = regexp(out(i),'(?:sub-|em)?0*(\d+)$','tokens','once');
    if isempty(tok), error('Unrecognized subject ID: %s',out(i)); end
    out(i) = sprintf('sub-%03d',str2double(tok{1}));
end
end
