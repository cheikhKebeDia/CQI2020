function [succes, cutImage, mask] = SimpleColorDetectionByHue(rgbImage, filter, minBlopSize, maxBlopSize)
succes = false;
cutImage = [];
mask = [];

try
	% Check that user has the Image Processing Toolbox installed.
	hasIPT = license('test', 'image_toolbox');
	if ~hasIPT
		% User does not have the toolbox installed.
		message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
		reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
		if strcmpi(reply, 'No')
			% User said No, so exit.
			return;
		end
    end
    
	% Convert RGB image to HSV
	hsvImage = rgb2hsv(rgbImage);
	% Extract out the H, S, and V images individually
	hImage = hsvImage(:,:,1);
	sImage = hsvImage(:,:,2);
	vImage = hsvImage(:,:,3);

	% Assign the low and high thresholds for each color band.
	% Take a guess at the values that might work for the user's image. 
    hueThresholdLow = filter(1);
    hueThresholdHigh = filter(2);
    saturationThresholdLow = filter(3);
    saturationThresholdHigh = filter(4);
    valueThresholdLow = filter(5);
    valueThresholdHigh = filter(6);
   
	% Interactively and visually set/adjust thresholds using custom thresholding application.
	% Available on the File Exchange: http://www.mathworks.com/matlabcentral/fileexchange/29372-thresholding-an-image
 	%[hueThresholdLow, hueThresholdHigh] = threshold(hueThresholdLow, hueThresholdHigh, hImage);
 	%[saturationThresholdLow, saturationThresholdHigh] = threshold(saturationThresholdLow, saturationThresholdHigh, sImage);
 	%[valueThresholdLow, valueThresholdHigh] = threshold(valueThresholdLow, valueThresholdHigh, vImage);

	% Now apply each color band's particular thresholds to the color band
	hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
	saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
	valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    
	% Combine the masks to find where all 3 are "true."
	% Then we will have the mask of only the red parts of the image.
	coloredObjects = single(hueMask & valueMask & saturationMask);
    
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 2);
	coloredObjects = imclose(coloredObjects, structuringElement);
    borderMask = single(coloredObjects);
    
	% Tell user that we're going to filter out small objects.
	smallestAcceptableArea = minBlopSize; % Keep areas only if they're bigger than this. 
    
	% Get rid of small objects.  Note: bwareaopen returns a logical.
	coloredObjects = uint8(bwareaopen(coloredObjects, smallestAcceptableArea, 8));

	% Take the big regions
    coloredObjects = ~coloredObjects;    
    coloredObjects = uint8(bwareafilt(logical(coloredObjects), [minBlopSize maxBlopSize]));
    
	% You can only multiply integers if they are of the same type.
	% (coloredObjectsMask is a logical array.)
	% We need to convert the type of coloredObjectsMask to the same data type as hImage.
	coloredObjects = cast(coloredObjects, 'like', rgbImage); 
% 	coloredObjectsMask = cast(coloredObjectsMask, class(rgbImage));

	% Use the colored object mask to mask out the colored-only portions of the rgb image.
	maskedImageR = coloredObjects .* rgbImage(:,:,1);
	maskedImageG = coloredObjects .* rgbImage(:,:,2);
	maskedImageB2 = coloredObjects .* rgbImage(:,:,3);
	maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB2);
    	
	% Measure the mean HSV and area of all the detected blobs.
	[meanHSV, areas, numberOfBlobs] = MeasureBlobs(coloredObjects, hImage, sImage, vImage);
	if numberOfBlobs > 0
		fprintf(1, '\n----------------------------------------------\n');
		fprintf(1, 'Blob #, Area in Pixels, Mean H, Mean S, Mean V\n');
		fprintf(1, '----------------------------------------------\n');
		for blobNumber = 1 : numberOfBlobs
			fprintf(1, '#%5d, %14d, %6.2f, %6.2f, %6.2f\n', blobNumber, areas(blobNumber), ...
				meanHSV(blobNumber, 1), meanHSV(blobNumber, 2), meanHSV(blobNumber, 3));
        end
        
        if numberOfBlobs < 35
            succes = true;
        end
	else
		% Noting find for this filter
        
        return;
    end
    borderMask = coloredObjects;
   
    maskedImageR = borderMask .* maskedImageR;
    maskedImageG = borderMask .* maskedImageG;
    maskedImageB2 = borderMask .* maskedImageB2;
    
    mask = single(borderMask);
    cutImage = cat(3, maskedImageR, maskedImageG, maskedImageB2);
    
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; % from SimpleColorDetection()
% ---------- End of main function --------------------------------