function f00_convertDicomToBIDS( ...
    internalSubjectID, bidsSubjectLabel, projectRoot, ...
    dcm2bidsVersion, runHelper, createScaffold)
% f00_convertDicomToBIDS
%
% Convert DICOM data for one participant to BIDS format using
% dcm2bids in Docker.
%
% Associated article:
% Mano, Y. et al. (2026).
% Neural mechanisms underlying decisions to express or suppress emotions.
% Social Cognitive and Affective Neuroscience.
% https://doi.org/10.1093/scan/nsag068
%
% INPUTS
%   internalSubjectID
%       Name of the participant's original DICOM directory.
%       Example: "em0001"
%
%   bidsSubjectLabel
%       BIDS participant label without the "sub-" prefix.
%       Example: "001"
%
%   projectRoot
%       Project root containing:
%           dcm/
%           bids/
%           config/config.json
%
%   dcm2bidsVersion
%       dcm2bids Docker image version.
%       Default: "latest"
%       Use the exact version originally used if known.
%
%   runHelper
%       Run dcm2bids_helper before conversion.
%       Default: false
%
%   createScaffold
%       Create a dcm2bids scaffold directory.
%       Default: false
%
% EXAMPLE
%   f00_convertDicomToBIDS( ...
%       "em0001", ...
%       "001", ...
%       "D:\MRI_data_new", ...
%       "latest", ...
%       false, ...
%       false);
%
% REQUIREMENTS
%   - MATLAB R2024b or a compatible version
%   - Docker Desktop
%   - dcm2bids configuration file:
%       <projectRoot>/config/config.json
%
% NOTES
%   Docker Desktop must already be running.
%   Docker/WSL restart commands are not executed automatically.

    arguments
        internalSubjectID (1,1) string
        bidsSubjectLabel  (1,1) string
        projectRoot       (1,1) string
        dcm2bidsVersion   (1,1) string = "latest"
        runHelper         (1,1) logical = false
        createScaffold    (1,1) logical = false
    end

    %% Validate participant labels

    if isempty(regexp(char(bidsSubjectLabel), ...
            '^[A-Za-z0-9]+$', 'once'))
        error("Invalid BIDS subject label: %s", bidsSubjectLabel);
    end

    %% Define paths

    dicomRoot = fullfile( ...
        projectRoot, ...
        "dcm", ...
        internalSubjectID);

    bidsRoot = fullfile(projectRoot, "bids");
    configRoot = fullfile(projectRoot, "config");
    configFile = fullfile(configRoot, "config.json");
    helperOutputRoot = fullfile(projectRoot, "code");
    scaffoldRoot = fullfile(projectRoot, "new_scaffold");

    dockerImage = ...
        "unfmontreal/dcm2bids:" + dcm2bidsVersion;

    %% Check required files and directories

    assert(isfolder(dicomRoot), ...
        "DICOM directory was not found:%s%s", ...
        newline, dicomRoot);

    assert(isfile(configFile), ...
        "dcm2bids configuration file was not found:%s%s", ...
        newline, configFile);

    if ~isfolder(bidsRoot)
        mkdir(bidsRoot);
    end

    if ~isfolder(helperOutputRoot)
        mkdir(helperOutputRoot);
    end

    checkDocker();

    %% Display settings

    fprintf("\n============================================================\n");
    fprintf("DICOM-to-BIDS conversion\n");
    fprintf("============================================================\n");
    fprintf("Original ID:       %s\n", internalSubjectID);
    fprintf("BIDS ID:           sub-%s\n", bidsSubjectLabel);
    fprintf("DICOM directory:   %s\n", dicomRoot);
    fprintf("BIDS directory:    %s\n", bidsRoot);
    fprintf("Configuration:     %s\n", configFile);
    fprintf("Docker image:      %s\n", dockerImage);
    fprintf("============================================================\n");

    %% Test Docker bind mount

    fprintf("\nTesting Docker bind mount...\n");

    testMountCommand = strjoin([
        "docker run --rm"
        "-v " + quoteDockerMount(projectRoot + ":/project:ro")
        "alpine"
        "ls -la /project"
    ], " ");

    runSystemCommand(testMountCommand);

    %% Pull dcm2bids Docker image

    fprintf("\nPulling dcm2bids Docker image...\n");

    runSystemCommand("docker pull " + dockerImage);

    %% Confirm dcm2bids command

    fprintf("\nChecking dcm2bids command...\n");

    helpCommand = strjoin([
        "docker run --rm"
        "--platform linux/amd64"
        dockerImage
        "--help"
    ], " ");

    runSystemCommand(helpCommand);

    %% Optional scaffold creation

    if createScaffold

        fprintf("\nCreating dcm2bids scaffold...\n");

        scaffoldCommand = strjoin([
            "docker run --rm"
            "--platform linux/amd64"
            "--entrypoint /venv/bin/dcm2bids_scaffold"
            "-v " + quoteDockerMount(projectRoot + ":/project")
            dockerImage
            "-o /project/new_scaffold"
        ], " ");

        runSystemCommand(scaffoldCommand);

        fprintf("Scaffold output:%s%s\n", ...
            newline, scaffoldRoot);
    end

    %% Optional dcm2bids_helper

    if runHelper

        fprintf("\nRunning dcm2bids_helper...\n");

        helperCommand = strjoin([
            "docker run --rm"
            "--platform linux/amd64"
            "--entrypoint /venv/bin/dcm2bids_helper"
            "-v " + quoteDockerMount(dicomRoot + ":/dicoms:ro")
            "-v " + quoteDockerMount(projectRoot + ":/project")
            dockerImage
            "-o /project/code"
            "-d /dicoms"
        ], " ");

        runSystemCommand(helperCommand);

        fprintf("Helper output:%s%s\n", ...
            newline, helperOutputRoot);
    end

    %% Convert DICOM to BIDS

    fprintf("\nStarting DICOM-to-BIDS conversion...\n");

    conversionCommand = strjoin([
        "docker run --rm"
        "--platform linux/amd64"
        "-v " + quoteDockerMount(dicomRoot + ":/dicoms:ro")
        "-v " + quoteDockerMount(bidsRoot + ":/bids")
        "-v " + quoteDockerMount(configRoot + ":/config:ro")
        dockerImage
        "-d /dicoms"
        "-p " + bidsSubjectLabel
        "-s 01"
        "-c /config/config.json"
        "-o /bids"
    ], " ");

    startTime = tic;
    runSystemCommand(conversionCommand);
    elapsedSeconds = toc(startTime);

    %% Confirm output

    expectedOutput = fullfile( ...
        bidsRoot, ...
        "sub-" + bidsSubjectLabel, ...
        "ses-01");

    if ~isfolder(expectedOutput)
        error( ...
            "Expected BIDS output was not found:%s%s", ...
            newline, expectedOutput);
    end

    fprintf("\nSUCCESS\n");
    fprintf("Participant:  sub-%s\n", bidsSubjectLabel);
    fprintf("Output:       %s\n", expectedOutput);
    fprintf("Elapsed time: %.2f minutes\n", elapsedSeconds / 60);
end


%% ========================================================================
% Local helper functions
% ========================================================================

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
