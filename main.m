% main.m - Enhanced with Tesseract OCR
clear; clc; close all;

% Add paths
addpath(genpath(pwd));
addpath(genpath(fullfile(pwd, 'src')));
addpath(genpath(fullfile(pwd, 'utils')));
addpath(genpath(fullfile(pwd, 'config')));

% Load settings
settings = config_settings();

% Let user pick file (image or pdf)
[file, path] = selectInputFile();
if isequal(file, 0)
    disp('No file selected');
    return;
end
fullpath = fullfile(path, file);

[~, ~, ext] = fileparts(fullpath);
ext = lower(ext);

% Prepare output filename
timestamp = datestr(now, 'yyyy_mm_dd_HH_MM_SS');
outputDir = fullfile(pwd, 'output');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
outputFile = fullfile(outputDir, ['ExtractText_' timestamp '.txt']);

% Process based on filetype
if ismember(ext, {'.jpg','.jpeg','.png','.tif','.tiff','bmp'})
    I = imread(fullpath);
    pages = {I};
elseif strcmp(ext, '.pdf')
    pages = processPDF(fullpath);
    if isempty(pages)
        fprintf('PDF conversion failed. Please convert PDF pages to images and try again. \n');
        return;
    end
else
    fprintf('Unsupported file type: %s\n', ext);
    return;
end

fprintf('Processing %d page(s) with Tesseract OCR...\n', numel(pages));

allText = '';
for p = 1:numel(pages)
    I = pages{p};
    fprintf('\n=== Processing page %d / %d ===\n', p, numel(pages));
    
    % Preprocess (minimal for Tesseract)
    [Ibin, Igray, maskTextCandidate] = preprocessImage(I, settings);
    
    % Extract text using Tesseract
    pageText = extractTextFromImage(Igray, Ibin, maskTextCandidate, settings);
    
    % Add page separators for multi-page documents
    if numel(pages) > 1
        allText = [allText sprintf('=== Page %d ===\n', p) pageText sprintf('\n\n')];
    else
        allText = [allText pageText];
    end
    
    % Show visual debug if enabled
    if settings.showDebug
        displayResults(I, Ibin, maskTextCandidate);
    end
end

% Save to file
saveToTextFile(outputFile, allText);
fprintf('\n=== EXTRACTION COMPLETE ===\n');
fprintf('Saved extracted text to: \n%s\n', outputFile);
fprintf('Total text length: %d characters\n', length(allText));

% Display first few lines of extracted text
fprintf('\n=== EXTRACTED TEXT PREVIEW ===\n');
lines = strsplit(allText, '\n');
for i = 1:min(10, length(lines))
    fprintf('%s\n', lines{i});
end
if length(lines) > 10
    fprintf('... (showing first 10 of %d lines)\n', length(lines));
end