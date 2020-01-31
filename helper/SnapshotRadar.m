function [foundShips] = SnapshotRadar(decodedImage, threshold)
%SNAPSHOTRADAR Takes a snapshot image and attempts to find possible ship
%locations. 
%   Attempts to find ship locations by calculating the mean of white pixels
%   by areas corresponding to a case size.
grayed = rgb2gray(decodedImage);

image_size = size(grayed, 1);

pixel_threshold = 211;

thresholded_image = zeros(image_size, image_size);

for i = 1:image_size
    for j = 1:image_size
        pixel = grayed(i, j);
        if (pixel >= pixel_threshold)
            thresholded_image(i, j) = 1;
        end
    end
end

lowerLimit = 20;
upperLimit = 130;

foundShips = zeros(10);
k = 1;
l = 1;

for i = lowerLimit:10:upperLimit-10
    for j = lowerLimit:10:upperLimit-10
        foundShips(k, l) = sum(thresholded_image(i:i+9, j:j+9), 'all');
        l = l + 1;
    end
    k = k + 1;
    l = 1;
end

foundShips(foundShips < threshold) = 0;
foundShips(foundShips >= threshold) = 1;

end

