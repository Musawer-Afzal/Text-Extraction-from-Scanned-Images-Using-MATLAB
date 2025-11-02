function settings = config_settings()
% Settings used by the pipeline
settings.ocrLanguage = 'English';   % Is the default
settings.showDebug = true;          % shoe bounding boxes and visual debug
settings.resizeForOCR = true;       % resize very large/small images
settings.targetDPI = 300;           % if resizing, approximate value
settings.maxImageDim = 1500;        % max dimension to keep for processing
settings.minImageDim = 600;         % minimum dim

% thresholds for grouping lines/paragraphs (I can adjust it)
settings.lineGapFactor = 0.6;       % fraction of median line height to treat as same line
settings.paragraphGapFactor = 1.5;  % factor to separate paragraphs

% watermark/non-text filtering
settings.largeComponentAreaFactor = 0.12;   % components bigger than * image area are ignored
settings.largeComponentDimFactor = 0.8;     % components spanning > this fraction of width/height ignored
end