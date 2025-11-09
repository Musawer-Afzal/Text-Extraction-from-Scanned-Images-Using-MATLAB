function settings = config_settings()
    % OCR settings
    settings.ocrLanguage = 'English';
    settings.showDebug = false;  % Set to true if you want to see image processing
    
    % Processing settings
    settings.resizeForOCR = true;
    settings.maxImageDim = 3000;
    
    % Confidence thresholds
    settings.minConfidence = 0.3;
    
    % OCR engine preference
    settings.useTesseract = true;  % Always use Tesseract now
end