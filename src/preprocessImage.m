function [Ibin, Igray, textMask] = preprocessImage(Iorig, settings)
% preprocessImage - Preprocesses an image for text extraction
%   Input:
%       Iorig    - Original RGB or grayscale image
%       settings - Configuration structure from config_settings()
%   Output:
%       Ibin     - Binary version of the image (text=1)
%       Igray    - Enhanced grayscale image
%       textMask - Binary mask highlighting probable text areas

    % --- Convert to grayscale ---
    if size(Iorig, 3) == 3
        Igray = rgb2gray(Iorig);
    else
        Igray = Iorig;
    end

    % --- Resize for OCR stability ---
    [h, w] = size(Igray);
    maxDim = max(h, w);
    if settings.resizeForOCR
        if maxDim > settings.maxImageDim
            scale = settings.maxImageDim / maxDim;
            Igray = imresize(Igray, scale);
        elseif maxDim < settings.minImageDim
            scale = settings.minImageDim / maxDim;
            Igray = imresize(Igray, scale);
        end
    end

    % --- Enhance contrast and normalize lighting ---
    Igray = adapthisteq(Igray);   % adaptive histogram equalization
    Igray = medfilt2(Igray, [3 3]);  % light smoothing to remove scan noise

    % --- Strong adaptive binarization ---
    try
        T = adaptthresh(Igray, 0.5, 'NeighborhoodSize', 51, 'Statistic', 'gaussian');
        Ibin = imbinarize(Igray, T);
    catch
        % Fallback for older MATLAB builds
        T = adaptthresh(Igray, 0.5);
        Ibin = imbinarize(Igray, T);
    end

    % Invert so that text pixels = 1
    Ibin = ~Ibin;

    % --- Remove small noise blobs ---
    Ibin = bwareaopen(Ibin, 30);

    % --- Remove large non-text regions (like watermarks/images) ---
    cc = bwconncomp(Ibin);
    stats = regionprops(cc, 'Area', 'BoundingBox');
    imgArea = numel(Ibin);
    mask = true(size(Ibin));

    for k = 1:cc.NumObjects
        area = stats(k).Area;
        bb = stats(k).BoundingBox;
        if area > settings.largeComponentAreaFactor * imgArea
            mask(cc.PixelIdxList{k}) = false;
        elseif (bb(3) > settings.largeComponentDimFactor * size(Ibin, 2)) || ...
               (bb(4) > settings.largeComponentDimFactor * size(Ibin, 1))
            mask(cc.PixelIdxList{k}) = false;
        end
    end

    % --- Create refined text mask ---
    textMask = Ibin & mask;

    % --- Morphologically connect words/lines ---
    se = strel('rectangle', [5 25]);  % wider connection for scanned documents
    textMask = imclose(textMask, se);
    textMask = imfill(textMask, 'holes');
    textMask = imclearborder(textMask);

    % Optional: show debug visualization
    if settings.showDebug
        figure, imshowpair(Igray, textMask, 'montage');
        title('Enhanced Grayscale | Connected Text Mask');
    end
end