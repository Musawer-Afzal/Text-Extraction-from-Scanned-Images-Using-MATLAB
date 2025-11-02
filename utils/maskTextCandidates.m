function [mask, cc] = maskTextCandidates(I)
% maskTextCandidates - Detects probable text regions in an image
%   Input:  I - RGB or grayscale image
%   Outputs:
%       mask - binary mask (1 = text regions)
%       cc   - connected components structure for detected regions

    % Convert to grayscale if needed
    if size(I,3) == 3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    % Enhance contrast to make text more distinct
    Igray = imadjust(Igray);

    % Remove noise
    Igray = medfilt2(Igray, [3 3]);

    % Detect edges (text areas have many edges)
    edges = edge(Igray, 'Canny');

    % Morphological closing to connect text edges
    se = strel('rectangle', [3 3]);
    mask = imclose(edges, se);

    % Fill small holes inside text regions
    mask = imfill(mask, 'holes');

    % Remove tiny specks (noise)
    mask = bwareaopen(mask, 30);

    % Remove overly large components (likely watermarks/logos)
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area');
    areas = [stats.Area];

    for i = 1:cc.NumObjects
        if areas(i) > 5000   % Adjust threshold if needed
            mask(cc.PixelIdxList{i}) = 0;
        end
    end

    % Recompute connected components after cleanup
    cc = bwconncomp(mask);
end