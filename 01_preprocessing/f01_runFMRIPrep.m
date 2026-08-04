function f01_runFMRIPrep(subjectLabel, projectRoot)
% f01_runFMRIPrep
%
% Run fMRIPrep 23.2.1 for one BIDS participant using Docker.
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
%           bids/
%           derivatives/
%           license.txt
%
% EXAMPLE
%   f01_runFMRIPrep("001", "D:\MRI_data_new");
%
% REQUIREMENTS
%   - MATLAB R2024b or a compatible version
%   - Docker Desktop
%   - fMRIPrep Docker image 23.2.1
%   - Valid FreeSurfer license file
%
% IMPORTANT
%   The FreeSurfer license file is not included in the public repository.
%
% OUTPUT SETTINGS
%   Spatial template:
%       MNI152NLin2009cAsym:res-native
%
%   Anatomical output:
%       anat
%
%   Resources:
%       nprocs       = 4
%       omp-nthreads = 2
%       memory       = 14000 MB
%
% NOTES
%   This function processes one participant at a time.
%   Existing output directories are not automatically deleted.

    arguments
        subjectLabel (1,1) string
        projectRoot  (1,1) string
    end

    %% Validate participant label

    if isempty(regexp(char(subjectLabel), ...
            '^[A-Za-z0-9]+$', 'once'))
        error("Invalid BIDS subject label: %s", subjectLabel);
    end

    %% Settings

    fmriprepVersion = "23.2.1";
    dockerImage = ...
        "nipreps/fmriprep:" + fmriprepVersion;

    nProcs = 4;
    ompThreads = 2;
    memoryMB = 14000;

    bidsRoot = fullfile(projectRoot, "bids");
    derivativesRoot = fullfile(projectRoot, "derivatives");
    freesurferLicense = fullfile(projectRoot, "license.txt");

    subjectRoot = fullfile( ...
        bidsRoot, ...
        "sub-" + subjectLabel, ...
        "ses-01");

    % Subject-specific Docker volumes prevent output from different
    % participants from being mixed.
    outputVolume = "fmriprep_out_" + subjectLabel;
    workVolume = "fmriprep_work_" + subjectLabel;

    %% Check inputs

    assert(isfolder(bidsRoot), ...
        "BIDS directory was not found:%s%s", ...
        newline, bidsRoot);

    assert(isfolder(subjectRoot), ...
        "Participant directory was not found:%s%s", ...
        newline, subjectRoot);

    assert(isfile(freesurferLicense), ...
        "FreeSurfer license file was not found:%s%s", ...
        newline, freesurferLicense);

    if ~isfolder(derivativesRoot)
        mkdir(derivativesRoot);
    end

    checkDocker();

    %% Display settings

    fprintf("\n============================================================\n");
    fprintf("fMRIPrep preprocessing\n");
    fprintf("============================================================\n");
    fprintf("Participant:        sub-%s\n", subjectLabel);
    fprintf("BIDS directory:     %s\n", bidsRoot);
    fprintf("Derivatives:        %s\n", derivativesRoot);
    fprintf("fMRIPrep version:   %s\n", fmriprepVersion);
    fprintf("Output volume:      %s\n", outputVolume);
    fprintf("Work volume:        %s\n", workVolume);
    fprintf("============================================================\n");

    %% Create or update .bidsignore

    bidsIgnoreFile = fullfile(bidsRoot, ".bidsignore");
    ensureBidsIgnoreEntry(bidsIgnoreFile, "OLD/");

    %% Remove dcm2bids temporary directories

    temporaryDcm2Bids = ...
        fullfile(bidsRoot, "tmp_dcm2bids");

    dcm2bidsLog = ...
        fullfile(bidsRoot, "code", "log");

    removeDirectoryIfPresent(temporaryDcm2Bids);
    removeDirectoryIfPresent(dcm2bidsLog);

    %% Create Docker volumes

    fprintf("\nCreating or confirming Docker volumes...\n");

    runSystemCommand( ...
        "docker volume create " + outputVolume);

    runSystemCommand( ...
        "docker volume create " + workVolume);

    %% Pull and verify image

    fprintf("\nPulling fMRIPrep Docker image...\n");

    runSystemCommand( ...
        "docker pull " + dockerImage);

    fprintf("\nChecking fMRIPrep version...\n");

    runSystemCommand( ...
        "docker run --rm " + dockerImage + " --version");

    %% Run fMRIPrep

    fprintf("\nStarting fMRIPrep...\n");

    fmriprepCommand = strjoin([
        "docker run --rm"
        "--platform linux/amd64"
        "-v " + quoteDockerMount(bidsRoot + ":/data:ro")
        "-v " + quoteDockerMount( ...
            freesurferLicense + ...
            ":/opt/freesurfer/license.txt:ro")
        "-v " + outputVolume + ":/out"
        "-v " + workVolume + ":/work"
        dockerImage
        "/data /out participant"
        "--participant-label " + subjectLabel
        "--fs-license-file /opt/freesurfer/license.txt"
        "--work-dir /work"
        "--output-spaces MNI152NLin2009cAsym:res-native anat"
        "--nprocs " + string(nProcs)
        "--omp-nthreads " + string(ompThreads)
        "--mem-mb " + string(memoryMB)
        "--low-mem"
    ], " ");

    startTime = tic;
    runSystemCommand(fmriprepCommand);
    elapsedSeconds = toc(startTime);

    %% Copy output from Docker volume

    fprintf("\nCopying fMRIPrep output to:%s%s\n", ...
        newline, derivativesRoot);

    copyCommand = strjoin([
        "docker run --rm"
        "-v " + outputVolume + ":/out:ro"
        "-v " + quoteDockerMount(derivativesRoot + ":/dest")
        "alpine"
        "sh -c " + quoteShellCommand("cp -a /out/. /dest/")
    ], " ");

    runSystemCommand(copyCommand);

    %% Confirm output

    possibleOutputDirectories = [
        fullfile( ...
            derivativesRoot, ...
            "sub-" + subjectLabel)
        fullfile( ...
            derivativesRoot, ...
            "fmriprep", ...
            "sub-" + subjectLabel)
    ];

    detectedOutput = "";

    for i = 1:numel(possibleOutputDirectories)
        if isfolder(possibleOutputDirectories(i))
            detectedOutput = possibleOutputDirectories(i);
            break;
        end
    end

    if detectedOutput == ""
        warning( ...
            ["fMRIPrep completed, but the expected participant " ...
             "output directory could not be identified automatically.%s" ...
             "Inspect:%s%s"], ...
            newline, newline, derivativesRoot);
    end

    fprintf("\nSUCCESS\n");
    fprintf("Participant:  sub-%s\n", subjectLabel);
    fprintf("Elapsed time: %.2f hours\n", elapsedSeconds / 3600);

    if detectedOutput ~= ""
        fprintf("Output:       %s\n", detectedOutput);
    end
end


%% ========================================================================
% Local helper functions
% ========================================================================

function ensureBidsIgnoreEntry(filePath, requiredEntry)
% Add an entry to .bidsignore without removing existing entries.

    requiredEntry = string(requiredEntry);

    if isfile(filePath)
        currentEntries = string(readlines(filePath));
        currentEntries = strtrim(currentEntries);
        currentEntries(ismissing(currentEntries)) = "";
        currentEntries(currentEntries == "") = [];

        if ~any(currentEntries == requiredEntry)
            currentEntries(end+1,1) = requiredEntry;
            writelines(currentEntries, filePath);
        end
    else
        writelines(requiredEntry, filePath);
    end
end


function removeDirectoryIfPresent(directoryPath)
% Remove an unnecessary temporary directory when present.

    if isfolder(directoryPath)
        fprintf("\nRemoving temporary directory:%s%s\n", ...
            newline, directoryPath);

        [success, message] = rmdir(directoryPath, "s");

        if ~success
            error( ...
                "Could not remove directory:%s%s%s%s", ...
                newline, directoryPath, newline, message);
        end
    end
end


function checkDocker()
% Confirm that Docker Desktop is available.

    [status, output] = system("docker version");

    if status ~= 0
        error( ...
            ["Docker Desktop is unavailable.%s" ...
             "Start Docker Desktop before running this function.%s%s"], ...
            newline, newline, output);
    end
end


function runSystemCommand(command)
% Run an external command and stop if it fails.

    command = string(command);

    fprintf("\n> %s\n", command);

    [status, output] = system(char(command), "-echo");

    if status ~= 0
        error( ...
            "External command failed with exit code %d:%s%s", ...
            status, newline, output);
    end
end


function output = quoteDockerMount(input)
% Convert a Windows path to a quoted Docker mount argument.

    output = replace(string(input), "\", "/");
    output = '"' + output + '"';
end


function output = quoteShellCommand(input)
% Quote a command passed to sh -c.

    output = '"' + string(input) + '"';
end
