function [BW1] = OCRProcess(imageCut)
    grayImage = rgb2gray(imageCut);

    % Detect MSER regions.
    [mserRegions, mserConnComp] = detectMSERFeatures(grayImage);

    % Use regionprops to measure MSER properties
    mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
        'Solidity', 'Extent', 'Euler', 'Image');

    % Compute the aspect ratio using bounding box data.
    bbox = vertcat(mserStats.BoundingBox);
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;

    % Threshold the data to determine which regions to remove. These thresholds
    % may need to be tuned for other images.
    filterIdx = aspectRatio' > 3; 
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

    % Remove regions
    mserStats(filterIdx) = [];
    mserRegions(filterIdx) = [];

    % Get bounding boxes for all the regions
    bboxes = vertcat(mserStats.BoundingBox);

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;

    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.02;
    xmin = (1-expansionAmount) * xmin;
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;

    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(grayImage,2));
    ymax = min(ymax, size(grayImage,1));

    % Show the expanded bounding boxes
    expandedBBoxes = [xmin(1) ymin(1) xmax(1)-xmin(1)+1 ymax(1)-ymin(1)+1];
    IExpandedBBoxes = insertShape(imageCut,'Rectangle',expandedBBoxes,'LineWidth',3);

    grayImage = imresize(grayImage,5);
    BW1 = edge(grayImage, 'Canny');
    se90 = strel('line',10,90);
    BW1 = imdilate(BW1,se90);
    BW1 = imfill(BW1,8,'holes');
    BW1 = imclearborder(BW1,4); 
end

