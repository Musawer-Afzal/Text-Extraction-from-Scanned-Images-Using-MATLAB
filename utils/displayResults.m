function displayResults(I, Ibin, mask)
% Show original image with mask overlay and bin
figure;
subplot(1, 3, 1); imshow(I); title('Original');
subplot(1, 3, 2); imshow(Ibin); title('Binary (text = 1)');
subplot(1, 3, 1); imshow(mask); title('Text candidate mask (watermark removed)');
end