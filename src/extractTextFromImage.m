function outText = extractTextFromImage(Igray, Ibin, maskTextCandidate, settings)
% Use Tesseract as primary OCR engine

    outText = '';
    
    % Ensure image is proper type for Tesseract
    if ~isa(Igray, 'uint8')
        Igray = im2uint8(Igray);
    end
    
    fprintf('=== Using Tesseract OCR ===\n');
    try
        [tesseractText, tesseractConfidence] = tesseractOCR(Igray, 'eng');
        fprintf('Tesseract confidence: %.3f\n', tesseractConfidence);
        
        outText = tesseractText;
        
    catch ME
        fprintf('Tesseract failed: %s\n', ME.message);
        % Fallback to MATLAB OCR
        fprintf('=== Fallback to MATLAB OCR ===\n');
        try
            ocrResults = ocr(Igray, 'TextLayout', 'Block', 'Language', settings.ocrLanguage);
            outText = ocrResults.Text;
            fprintf('MATLAB OCR confidence: %.3f\n', nanmean(ocrResults.WordConfidences));
        catch
            outText = '';
        end
    end
    
    % Basic cleaning to fix any minor issues
    outText = basicCleaning(outText);
    fprintf('Final text length: %d characters\n', length(outText));
end

function text = basicCleaning(text)
    % Fix any double spaces but preserve paragraphs
    text = regexprep(text, ' +', ' ');
    text = regexprep(text, '\n\s*\n\s*\n+', '\n\n');
    text = strtrim(text);
end