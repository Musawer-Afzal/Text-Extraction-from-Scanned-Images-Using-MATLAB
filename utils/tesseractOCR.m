function [text, confidence] = tesseractOCR(I, language)
% Tesseract OCR wrapper for MATLAB - FIXED VERSION

    % Ensure Tesseract is in PATH
    checkTesseractPath();
    
    % Convert to uint8 if needed
    if ~isa(I, 'uint8')
        I = im2uint8(I);
    end
    
    % Convert to RGB if grayscale (Tesseract works better with RGB)
    if size(I, 3) == 1
        I = repmat(I, [1 1 3]);
    end
    
    % Save temporary image
    tempDir = tempdir;
    tempFile = fullfile(tempDir, 'tesseract_temp.png');
    imwrite(I, tempFile);
    
    % Output file (without extension)
    outputFile = fullfile(tempDir, 'tesseract_output');
    
    % Build command
    if nargin < 2
        language = 'eng';
    end
    
    % Use full path to avoid PATH issues
    tesseractExe = '"C:\Program Files\Tesseract-OCR\tesseract.exe"';
    
    % FIXED: Remove character whitelist to preserve spaces and formatting
    % PSM 6: Uniform block of text (good for documents)
    cmd = sprintf('%s "%s" "%s" -l %s --psm 6', ...
                  tesseractExe, tempFile, outputFile, language);
    
    fprintf('Running Tesseract with command: %s\n', cmd);
    
    % Execute Tesseract
    [status, result] = system(cmd);
    
    if status == 0
        % Read result file
        textFile = [outputFile '.txt'];
        if exist(textFile, 'file')
            fid = fopen(textFile, 'r', 'n', 'UTF-8');
            if fid == -1
                fid = fopen(textFile, 'r');
            end
            text = fread(fid, '*char')';
            fclose(fid);
            
            % Clean up temp files
            try
                delete(textFile);
                delete(tempFile);
            catch
                % Ignore cleanup errors
            end
            
            % Estimate confidence
            confidence = estimateTextConfidence(text);
        else
            text = '';
            confidence = 0;
        end
    else
        text = '';
        confidence = 0;
        fprintf('Tesseract error (status %d): %s\n', status, result);
        
        % Clean up on error
        try
            delete(tempFile);
        catch
        end
    end
end

function checkTesseractPath()
% Check if Tesseract is accessible
    [status, ~] = system('tesseract --version');
    if status ~= 0
        fprintf('Tesseract not in PATH. Adding program folder...\n');
        addpath('C:\Program Files\Tesseract-OCR');
    end
end

function confidence = estimateTextConfidence(text)
% Estimate confidence based on text quality
    if isempty(text)
        confidence = 0;
        return;
    end
    
    % Simple heuristic: ratio of readable lines
    lines = strsplit(text, '\n');
    readableLines = 0;
    
    for i = 1:length(lines)
        line = strtrim(lines{i});
        if length(line) > 10 % Reasonable length for a text line
            words = strsplit(line, ' ');
            if length(words) >= 2 % Has multiple words
                readableLines = readableLines + 1;
            end
        end
    end
    
    confidence = readableLines / max(length(lines), 1);
end