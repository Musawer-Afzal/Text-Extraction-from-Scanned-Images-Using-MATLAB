function outText = extractTextFromImage(Igray, Ibin, maskTextCandidate, settings)
% extractTextFromImage - Run OCR on preprocessed image and text mask.
% Returns plain text with line and paragraph separation.

        % Combine binary mask and candidate mask
    finalMask = Ibin & maskTextCandidate;

    % Find connected components in the mask
    cc = bwconncomp(finalMask);
    stats = regionprops(cc, 'BoundingBox');
    if isempty(stats)
        outText = '';
        return;
    end

    % Prepare to collect OCR text
    allWords = {};
    allBoxes = [];
    allConf  = [];

    % Run OCR on each detected text region
    for k = 1:numel(stats)
        bb = round(stats(k).BoundingBox); % [x, y, w, h]
        try
            ocrResults = ocr(Igray, bb, 'TextLayout', 'Block');
        catch ME
            warning('OCR failed on region %d: %s', k, ME.message);
            continue;
        end
        allWords = [allWords; ocrResults.Words(:)];
        allBoxes = [allBoxes; ocrResults.WordBoundingBoxes];
        allConf  = [allConf; ocrResults.WordConfidences];
    end

    % Reconstruct ocrResults-like structure
    words = allWords;
    boxes = allBoxes;
    conf  = allConf;

    % If no words found
    if isempty(words)
        outText = '';
        return;
    end

    % Remove empty or low-confidence words
    keep = ~cellfun(@isempty, strtrim(words)) & (conf > 0.3);
    words = words(keep);
    boxes = boxes(keep, :);

    if isempty(words)
        outText = '';
        return;
    end

    % Sort by vertical position, then horizontal
    [~, order] = sortrows([boxes(:,2), boxes(:,1)]);
    boxes = boxes(order, :);
    words = words(order);

    % Estimate line height
    heights = boxes(:,4);
    medianH = median(heights);

    % --- Group words into lines ---
    lines = {};
    currentLine = words{1};
    currentBB = boxes(1, :);

    for i = 2:size(boxes,1)
        prevBB = currentBB;
        thisBB = boxes(i,:);
        vertGap = thisBB(2) - (prevBB(2) + prevBB(4));

        if vertGap < settings.lineGapFactor * medianH
            % Same line
            currentLine = [currentLine ' ' words{i}];
            % Expand bounding box horizontally
            x1 = min(prevBB(1), thisBB(1));
            y1 = min(prevBB(2), thisBB(2));
            x2 = max(prevBB(1) + prevBB(3), thisBB(1) + thisBB(3));
            y2 = max(prevBB(2) + prevBB(4), thisBB(2) + thisBB(4));
            currentBB = [x1, y1, x2 - x1, y2 - y1];
        else
            % New line
            lines{end+1} = currentLine; %#ok<AGROW>
            currentLine = words{i};
            currentBB = thisBB;
        end
    end
    lines{end+1} = currentLine;

    % --- Group lines into paragraphs ---
    paragraphs = {};
    if isempty(lines)
        outText = '';
        return;
    end

    currentPara = lines{1};
    for i = 2:numel(lines)
        prevBB = boxes(i-1,:);
        thisBB = boxes(i,:);
        vertGap = thisBB(2) - (prevBB(2) + prevBB(4));

        if vertGap > settings.paragraphGapFactor * medianH
            % New paragraph
            paragraphs{end+1} = currentPara; %#ok<AGROW>
            currentPara = lines{i};
        else
            currentPara = [currentPara sprintf('\n') lines{i}];
        end
    end
    paragraphs{end+1} = currentPara;

    % --- Build output text string ---
    outText = '';
    for p = 1:numel(paragraphs)
        outText = [outText paragraphs{p}]; %#ok<AGROW>
        if p < numel(paragraphs)
            outText = [outText sprintf('\n\n')]; %#ok<AGROW>
        end
    end

    % Clean up extraneous characters
    outText = regexprep(outText, '[^\w\s.,:;!?%-]', '');
    outText = regexprep(outText, '\n{3,}', '\n\n');

end