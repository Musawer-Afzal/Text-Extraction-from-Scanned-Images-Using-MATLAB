function cleanedText = postProcessText(rawText)
% Only fix universal issues, preserve OCR's original text

    if isempty(rawText) || ~ischar(rawText)
        cleanedText = '';
        return;
    end

    cleanedText = rawText;
    
    % Only fix spacing and paragraph issues
    cleanedText = regexprep(cleanedText, ' +', ' ');
    cleanedText = regexprep(cleanedText, '\n\s*\n\s*\n+', '\n\n');
    cleanedText = strtrim(cleanedText);
end