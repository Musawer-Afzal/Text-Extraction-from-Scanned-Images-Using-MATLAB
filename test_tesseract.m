% Test Tesseract OCR
clear; clc; close all;

% Add paths
addpath(genpath(pwd));

% Test if Tesseract works
fprintf('=== Testing Tesseract Installation ===\n');
[status, version] = system('tesseract --version');
if status == 0
    fprintf('Tesseract found: %s\n', version);
else
    fprintf('Tesseract not found. Trying with full path...\n');
    [status, version] = system('"C:\Program Files\Tesseract-OCR\tesseract.exe" --version');
    if status == 0
        fprintf('Tesseract found via full path: %s\n', version);
    else
        error('Tesseract not accessible. Please check installation.');
    end
end

% Test with your document
[file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp', 'Image Files'});
if isequal(file, 0)
    return;
end

filename = fullfile(path, file);
fprintf('\n=== Testing with file: %s ===\n', filename);

I = imread(filename);
if size(I, 3) == 3
    I = rgb2gray(I);
end

% Test Tesseract
fprintf('\n--- Tesseract OCR ---\n');
tic;
[text, confidence] = tesseractOCR(I, 'eng');
toc;
fprintf('Confidence: %.3f\n', confidence);
fprintf('Text:\n%s\n', text);

% Compare with MATLAB OCR
fprintf('\n--- MATLAB OCR ---\n');
tic;
matlabResult = ocr(I, 'TextLayout', 'Block');
toc;
fprintf('Confidence: %.3f\n', nanmean(matlabResult.WordConfidences));
fprintf('Text:\n%s\n', matlabResult.Text);

fprintf('\n=== Comparison Complete ===\n');