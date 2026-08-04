function f02_applySmoothing(subjectLabel, projectRoot)
% f02_applySmoothing
%
% Apply 6-mm FWHM spatial smoothing to four preprocessed BOLD runs
% for one participant using SPM.
%
% Associated article:
% Mano, Y. et al. (2026).
% Neural mechanisms underlying decisions to express or suppress emotions.
% Social Cognitive and Affective Neuroscience.
% https://doi.org/10.1093/scan/nsag068
%
% INPUTS
%   subjectLabel
%       BIDS participant label without the "sub-" prefix.
%       Example: "001"
%
%   projectRoot
%       Project root containing:
%           derivatives/
%
% EXAMPLE
%   f02_applySmoothing("001", "D:\MRI_data_new");
%
% REQUIREMENTS
%   - MATLAB R2024b or a compatible version
%   - SPM25 or a compatible SPM version
%
% INPUT
%   Four fMRIPrep-preprocessed BOLD images:
%       run-01
%       run-02
%       run-03
%       run-04
%
% OUTPUT
%   Spatially smoothed 4D BOLD files with the prefix:
%       s6tmp_
%
% SMOOTHING KERNEL
%       FWHM = [6 6 6] mm

    arguments
        subjectLabel (1,1) string
        projectRoot  (1,1) string
    end

    %% Validate participant label

    if isempty(regexp(char(subjectLabel), ...
            '^[A-Za-z0-9]+$', 'once'))
        error("Invalid BIDS subject label: %s", subjectLabel);
    end

    %% Confirm SPM availability

    if exist("spm", "file") ~= 2
        error( ...
            ["SPM was not found on the MATLAB path.%s" ...
             "Add the SPM directory before running this function."], ...
            newline);
    end

    spm("defaults", "FMRI");
    spm_jobman("initcfg");

    %% Settings

    subjectID = "sub-" + subjectLabel;
    sessionID = "ses-01";
    taskName = "em";

    numberOfRuns = 4;
    fwhm = [6 6 6];
    outputPrefix = "s6tmp_";

    derivativesRoot = ...
        fullfile(projectRoot, "derivatives");

    possibleFuncDirectories = [
        fullfile( ...
            derivativesRoot, ...
            subjectID, ...
            sessionID, ...
            "func")
        fullfile( ...
            derivativesRoot, ...
            "fmriprep", ...
            subjectID, ...
            sessionID, ...
            "func")
    ];

    %% Locate functional derivatives directory

    funcDirectory = "";

    for i = 1:numel(possibleFuncDirectories)
        if isfolder(possibleFuncDirectories(i))
            funcDirectory = possibleFuncDirectories(i);
            break;
        end
    end

    if funcDirectory == ""
        error( ...
            "Functional derivatives directory was not found for %s.", ...
            subjectID);
    end

    %% Locate four preprocessed BOLD images

    runs4d = cell(numberOfRuns, 1);

    for runNumber = 1:numberOfRuns

        baseName = sprintf( ...
            "%s_%s_task-%s_run-%02d_" + ...
            "space-MNI152NLin2009cAsym_" + ...
            "desc-preproc_bold", ...
            subjectID, ...
            sessionID, ...
            taskName, ...
            runNumber);

        uncompressedFile = ...
            fullfile(funcDirectory, baseName + ".nii");

        compressedFile = ...
            fullfile(funcDirectory, baseName + ".nii.gz");

        if isfile(uncompressedFile)

            runs4d{runNumber} = char(uncompressedFile);

        elseif isfile(compressedFile)

            fprintf("\nDecompressing run %02d:%s%s\n", ...
                runNumber, newline, compressedFile);

            decompressedFiles = gunzip( ...
                compressedFile, ...
                funcDirectory);

            runs4d{runNumber} = decompressedFiles{1};

        else
            error( ...
                ["Preprocessed BOLD image was not found.%s" ...
                 "Participant: %s%sRun: %02d%sDirectory: %s"], ...
                newline, subjectID, newline, runNumber, ...
                newline, funcDirectory);
        end
    end

    %% Define expected outputs

    expectedOutputs = strings(numberOfRuns, 1);

    for runNumber = 1:numberOfRuns

        [inputDirectory, inputName, inputExtension] = ...
            fileparts(runs4d{runNumber});

        expectedOutputs(runNumber) = fullfile( ...
            inputDirectory, ...
            outputPrefix + inputName + inputExtension);

        if isfile(expectedOutputs(runNumber))
            warning( ...
                "Smoothed output already exists and may be overwritten:%s%s", ...
                newline, expectedOutputs(runNumber));
        end
    end

    %% Display settings

    fprintf("\n============================================================\n");
    fprintf("SPM spatial smoothing\n");
    fprintf("============================================================\n");
    fprintf("Participant:   %s\n", subjectID);
    fprintf("Input folder:  %s\n", funcDirectory);
    fprintf("Runs:          %d\n", numberOfRuns);
    fprintf("FWHM:          [%g %g %g] mm\n", fwhm);
    fprintf("Output prefix: %s\n", outputPrefix);
    fprintf("============================================================\n");

    %% Construct SPM batch

    matlabbatch = [];

    matlabbatch{1}.spm.spatial.smooth.data = runs4d;
    matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm;
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = ...
        char(outputPrefix);

    %% Run smoothing

    startTime = tic;

    spm_jobman("run", matlabbatch);

    elapsedSeconds = toc(startTime);

    %% Confirm outputs

    missingOutputs = strings(0,1);

    for runNumber = 1:numberOfRuns
        if ~isfile(expectedOutputs(runNumber))
            missingOutputs(end+1,1) = ...
                expectedOutputs(runNumber); %#ok<AGROW>
        end
    end

    if ~isempty(missingOutputs)
        error( ...
            "Some smoothed output files were not created:%s%s", ...
            newline, strjoin(missingOutputs, newline));
    end

    fprintf("\nSUCCESS\n");
    fprintf("Participant:   %s\n", subjectID);
    fprintf("Elapsed time:  %.2f minutes\n", elapsedSeconds / 60);
    fprintf("Output prefix: %s\n", outputPrefix);
end
