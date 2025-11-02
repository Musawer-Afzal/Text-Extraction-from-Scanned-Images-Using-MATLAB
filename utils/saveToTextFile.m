function saveToTextFile(outputFile, textContent)
% Saves the text content to outputFile (UTF-8)
fid = fopen(outputFile, 'w', 'n', 'UTF-8');
if fid == -1
    error('Could not open the output file for writing: %s', outputFile);
end
fprintf(fid, '%s', textContent);
fclose(fid);
end