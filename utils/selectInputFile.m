function [file, path] = selectInputFile()
% Open file chooser for images and pdf's
[filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif;*.tiff;*.bmp;*.pdf', ...
    'Image or PDF Files (*.jpg, *.png, *.tif, *.pdf)'; '*.*','All Files (*.*)'}, ...
    'Select an image or PDF file');
if isequal(filename, 0)
    file = 0; path = 0;
else
    file = filename; path = pathname;
end
end