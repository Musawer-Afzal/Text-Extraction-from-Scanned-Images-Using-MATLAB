function [Ibin, Igray, textMask] = preprocessImage(Iorig, settings)
% Minimal preprocessing - preserve original quality

    % Convert to grayscale
    if size(Iorig, 3) == 3
        Igray = rgb2gray(Iorig);
    else
        Igray = Iorig;
    end

    % Store original for OCR (we'll use this directly)
    Ioriginal = Igray;

    % Only resize if extremely large (slows down OCR)
    [h, w] = size(Igray);
    maxDim = max(h, w);
    if settings.resizeForOCR && maxDim > 3000
        scale = 2000 / maxDim;
        Igray = imresize(Igray, scale);
        fprintf('Resized from %dx%d to %dx%d\n', h, w, size(Igray));
    end

    % VERY minimal processing for visualization only
    Ibin = imbinarize(Igray);
    textMask = true(size(Ibin));

    if settings.showDebug
        figure('Position', [100, 100, 1200, 300]);
        subplot(1,3,1), imshow(Ioriginal), title('Original (Used for OCR)');
        subplot(1,3,2), imshow(Igray), title('Processed');
        subplot(1,3,3), imshow(Ibin), title('Binary Visual');
    end
    
    % Return original for OCR (most accurate)
    Igray = Ioriginal;
end