function pages = processPDF(pdfPath)
% Attempt to read PDF pages as images using imread(requires
% Ghostscript/system
% Returns cell array of images. If fails, returns empty

pages = {};
try
    info = imfinfo(pdfPath);
    numPages = numel(info);
    for k = 1:numPages
        try
            I = imread(pdfPath, k);
            % Convert indexed images to RGB
            if ismatrix(I)
                I = repmat(I, [1 1 3]);
            end
            pages{end+1} = I; 
        catch readErr
            wraning('Failed to read page %d: %s', k, readErr.message);
        end
    end
catch ME
    warning('imfinfo/imread falied for PDF. Error: %s', ME.message);
    fprintf('PDF -> image conversion falied. To process, install Ghostscript or convert PDF pages to images. \n');
    pages = {};
end
end