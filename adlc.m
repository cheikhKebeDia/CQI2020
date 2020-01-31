clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
%clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
imtool close all;	% Close all figure windows created by imtool.
format long g;
format compact;
fontSize = 20;
addpath("helper/");
addpath("helper/InteropFunction");
% ---------------- Constant -------------------------------------

% What to take
OCROn = true;
dominantColorOn = true;
findTemplateOn = true;
InteropOn = false;

% Filter for star and circle
hueThresholdLow = 0;
hueThresholdHigh = 1;
saturationThresholdLow = 0;
saturationThresholdHigh = 1;
valueThresholdLow = 0.1;
valueThresholdHigh = 0.65;
filter = [hueThresholdLow, hueThresholdHigh, saturationThresholdLow, saturationThresholdHigh, valueThresholdLow, valueThresholdHigh];

% Filter for Red and pink
hueThresholdLow = 0;
hueThresholdHigh = 0.28;
saturationThresholdLow = 0;
saturationThresholdHigh = 1;
valueThresholdLow = 0.1;
valueThresholdHigh = 0.85;
filter2 = [hueThresholdLow, hueThresholdHigh, saturationThresholdLow, saturationThresholdHigh, valueThresholdLow, valueThresholdHigh];

% CropSize
xmin    = 0;
ymin    = 0;
width   = 800;
height  = 800;
groundAltitude = 5;
minBlopSize = 300;
maxBlopSize = 1000;
camCropFactor = 1.53;
camFocalLength_mm = 16;

% Shape
possibleShape = ["CIRCLE"; "CROSS"; "SEMICIRCLE"; "QUARTER_CIRCLE"; "RECTANGLE"; "SQUARE"; "STAR"; "TRAPEZOID"; "TRIANGLE"];
shapeSize = 9;
bestShapeMatchPosition = [];
bestShapeMatchName = "";
lastConfidenceLevel = 0;

% Letter
% Remove I
possibleLetter = ["A"; "B"; "C"; "D"; "E"; "F"; "G"; "H"; "J"; "K"; "L"; "M"; "N"; "O"; "P"; "Q"; "R"; "S"; "T"; "U"; "V"; "W"; "X"; "Y"; "Z"];
letterSize = 25;
lastConfidenceLevelLetter = 0;

% Interop
uri = "http://localhost:8000";
username = "testadmin";
password = "testpass";
missionId = 1;

% Image folder
path_to_folder = "Image/terrain/";
lastFileName = "";

%% Connection to Interop
if InteropOn
    cookie = InteropLogin(username, password, uri);
    mission = InteropGetMission(cookie, missionId, uri);
end

% ---------------------------------------------------------------
while true
    d = dir(path_to_folder + "*.jpg");
    [~,idx] = max([d.datenum]);
    filename = d(idx).name;
    
    if lastFileName ~= filename
        lastFileName = filename;
        
        filename = "1497566017_HP.jpg";
    
        fprintf("---- Starting reading image with name : %s \n", filename);
        image = imread(path_to_folder +  filename);
      
        imageInfo = imfinfo(path_to_folder +  filename);

        Droneorientation = strsplit(imageInfo.ImageDescription, " ");
        GPSAltitude = imageInfo.GPSInfo.GPSAltitude(1) - groundAltitude;
                        
        % If drone is flat and at the good altitude
        %if Droneorientation{1} == "-0" && Droneorientation{2} == "-0" && GPSAltitude <= 70 && GPSAltitude >= 50
        if true
            image = imresize(image, 0.3);
            [ImagesizeX, ImagesizeY] = size(image);

            for f = 1:2

                if f == 1 % Not the best implementation
                    [success, imageCut, mask] = SimpleColorDetectionByHue(image, filter, minBlopSize, maxBlopSize);
                else
                    [success, imageCut, mask] = SimpleColorDetectionByHue(image, filter2, minBlopSize, maxBlopSize);
                end

                if success
                    [labeledImage, numberOfBlobs] = bwlabel(mask, 8);

                    for e = 1:numberOfBlobs
                        
                        fprintf("Blop number %d \n", e);

                        % Find section
                        [sizeX, sizeY] = size(labeledImage);
                        for x = 1:sizeX
                            for y = 1:sizeY
                                if labeledImage(x, y) == e
                                    mask(x, y) = 1;
                                else
                                    mask(x, y) = 0;
                                end
                            end
                        end
                        mask = single(mask);
                        
                        GPSLat = imageInfo.GPSInfo.GPSLatitude(1) + "" + imageInfo.GPSInfo.GPSLatitude(2) + "" + imageInfo.GPSInfo.GPSLatitude(3);
                        GPSLat = str2double(GPSLat) / 1000;
                        
                        GPSLong = "-" + imageInfo.GPSInfo.GPSLongitude(1) + "" + imageInfo.GPSInfo.GPSLongitude(2) + "" + imageInfo.GPSInfo.GPSLongitude(3);
                        GPSLong = str2double(GPSLong) / 1000;
                        
                        DroneYaw = str2double(Droneorientation{3});
                        DroneRoll = 0;
                        DronePitch = 0;
                      
                        ODLCStructure.Send = false;
                        ODLCStructure.Type = "STANDARD";
                        ODLCStructure.Latitude = GPSLat;
                        ODLCStructure.Longitude = GPSLong;
                        ODLCStructure.Orientation = DroneYaw; % Droneorientation{3}
                        ODLCStructure.Shape = "";
                        ODLCStructure.ShapeColor = "";
                        ODLCStructure.Image = "";
                        ODLCStructure.LetterColor = "";
                        ODLCStructure.Letter = "";

                        B = regionprops(mask, 'BoundingBox');
                        cropImage = imcrop(image, B.BoundingBox);
                        cropMask = imcrop(mask, B.BoundingBox);
                        [rows, columns, numberOfColorBands] = size(cropImage);
                        
                        if rows ~= 0 && columns ~= 0  
                            
                            %% Find if there is a target
                            grayImage = rgb2gray(cropImage);
                            BW1 = edge(grayImage, 'Canny');
                            se90 = strel('line',10,15);
                            BW1 = imdilate(BW1,se90);
                            BW1 = imfill(BW1,8,'holes');
                            BW1 = imclearborder(BW1,4);

                            if bwarea(BW1) > 0

                                %% Template matching with a convolution
                                for n = 1:shapeSize
                                    template = imread("Image/template/"+ possibleShape(n) +".png");
                                    for r = 0:20:360
                                        try
                                            rotateTemplate = imrotate(template, r, 'bilinear');
                                            [success, confidenceLevel, xoffSet, yoffSet, sizeY, sizeX] = TemplateConvolution(cropMask, rotateTemplate, possibleShape(n), 0.85, minBlopSize);
                                            if success && lastConfidenceLevel < confidenceLevel
                                                bestShapeMatch = [xoffSet, yoffSet, sizeY, sizeX];
                                                bestShapeMatchName = possibleShape(n);
                                                lastConfidenceLevel = confidenceLevel;
                                            end
                                        catch
                                            % So that was a fail :(
                                        end
                                    end
                                end

                                if lastConfidenceLevel > 0
                                   fprintf("Find %s at %s \n", bestShapeMatchName, lastConfidenceLevel);
                                   ODLCStructure.Shape = bestShapeMatchName;
                                   ODLCStructure.Send = true;
                                   ODLCStructure.Image = cropImage;

                                   % Remove the possible Shape
                                   possibleShape(strcmp(possibleShape, bestShapeMatchName)) = [];
                                   shapeSize = shapeSize - 1;

                                    %% Find DominantColor
                                   if dominantColorOn
                                        maskedImageR = uint8(cropMask) .* cropImage(:,:,1);
                                        maskedImageG = uint8(cropMask) .* cropImage(:,:,2);
                                        maskedImageB2 = uint8(cropMask) .* cropImage(:,:,3);
                                        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB2);

                                        [dominantColor, seconderyColor] = FindDominantColor(maskedRGBImage);

                                        ODLCStructure.ShapeColor = dominantColor;
                                        ODLCStructure.LetterColor = seconderyColor;
                                   end

                                    %% OCR
                                   if OCROn
                                       BW1 = OCRProcess(cropImage);

                                       for y = 1:letterSize
                                            template = imread("Image/template/Letter/"+ possibleLetter(y) +".png");
                                            for r = 0:20:360
                                                rotateTemplate = imrotate(template, r, 'bilinear');
                                                [success, confidenceLevel, xoffSet, yoffSet, sizeY, sizeX] = TemplateConvolution(BW1, rgb2gray(rotateTemplate), possibleLetter(y), 0.50, minBlopSize);
                                                if success && lastConfidenceLevelLetter < confidenceLevel
                                                    bestShapeMatch = [xoffSet, yoffSet, sizeY, sizeX];
                                                    bestShapeMatchName = possibleLetter(y);
                                                    lastConfidenceLevelLetter = confidenceLevel;
                                                end
                                            end
                                        end
                                        if lastConfidenceLevelLetter > 0
                                            fprintf("Find letter : %s with %d\n", bestShapeMatchName, lastConfidenceLevelLetter);
                                            ODLCStructure.Letter = bestShapeMatchName;
                                        end
                                        lastConfidenceLevel = 0;
                                   end
                                   
                                    %% Get GPS position in image
                                    posX = B.BoundingBox(1);
                                    posY = B.BoundingBox(2);

                                    lens_X = 2 * atan((36/camCropFactor)/(2*camFocalLength_mm));
                                    lens_Y = 2 * atan((24/camCropFactor)/(2*camFocalLength_mm));

                                    prop_x = double(posX)/double(ImagesizeX);
                                    prop_y = double(posY)/double(ImagesizeY);

                                    angle_X = ((0.5 - prop_x) * lens_X + DroneRoll * pi/180);
                                    angle_Y = ((0.5 - prop_y) * lens_Y + DronePitch * pi/180);
                                    nombreTours = single(DroneYaw/360.0);
                                    DroneYaw = DroneYaw - nombreTours * 360.0;
                                    if(DroneYaw > 180)
                                        DroneYaw = DroneYaw - 360;
                                    end
                                    angle_Z = DroneYaw * pi/180;

                                    matRoll = [];
                                    matRoll(1,1) = 1;
                                    matRoll(2,1) = 0;
                                    matRoll(3,1) = 0;

                                    matRoll(1,2) = 0;
                                    matRoll(2,2) = cos(angle_X);
                                    matRoll(3,2) = -sin(angle_X);

                                    matRoll(1,3) = 0;
                                    matRoll(2,3) = sin(angle_X);
                                    matRoll(3,3) = cos(angle_X);

                                    matPitch = [];
                                    matPitch(1, 1) = cos(angle_Y);
                                    matPitch(2, 1) = 0;
                                    matPitch(3, 1) = sin(angle_Y);

                                    matPitch(1,2) = 0;
                                    matPitch(2,2) = 1;
                                    matPitch(3,2) = 0;

                                    matPitch(1,3) = -sin(angle_Y);
                                    matPitch(2,3) = 0;
                                    matPitch(3,3) = cos(angle_Y);

                                    matYaw = [];
                                    matYaw(1,1) = cos(angle_Z);
                                    matYaw(2,1) = -sin(angle_Z);
                                    matYaw(3,1) = 0;

                                    matYaw(1,2) = sin(angle_Z);
                                    matYaw(2,2) = cos(angle_Z);
                                    matYaw(3,2) = 0;

                                    matYaw(1,3) = 0;
                                    matYaw(2,3) = 0;
                                    matYaw(3,3) = 1;

                                    pos = [];
                                    pos(1) = 0;
                                    pos(2) = 0;
                                    pos(3) = GPSAltitude;

                                    % Tourne the matrix
                                    pos(1) = pos(1) * matRoll(1,1) + pos(2) * matRoll(2,1) + pos(3) * matRoll(3,1);
                                    pos(2) = pos(1) * matRoll(1,2) + pos(2) * matRoll(2,2) + pos(3) * matRoll(3,2);
                                    pos(3) = pos(1) * matRoll(1,3) + pos(2) * matRoll(2,3) + pos(3) * matRoll(3,3);

                                    pos(1) = pos(1) * matPitch(1,1) + pos(2) * matPitch(2,1) + pos(3) * matPitch(3,1);
                                    pos(2) = pos(1) * matPitch(1,2) + pos(2) * matPitch(2,2) + pos(3) * matPitch(3,2);
                                    pos(3) = pos(1) * matPitch(1,3) + pos(2) * matPitch(2,3) + pos(3) * matPitch(3,3);

                                    RATIO = GPSAltitude / pos(3);

                                    pos(1) = pos(1) * RATIO;
                                    pos(2) = pos(2) * RATIO;
                                    pos(3) = 0;

                                    pos(1) = pos(1) * matYaw(1,1) + pos(2) * matYaw(2,1) + pos(3) * matYaw(3,1);
                                    pos(2) = pos(1) * matYaw(1,2) + pos(2) * matYaw(2,2) + pos(3) * matYaw(3,2);
                                    pos(3) = pos(1) * matYaw(1,3) + pos(2) * matYaw(2,3) + pos(3) * matYaw(3,3);

                                    target_x_m = pos(2);
                                    target_y_m = pos(1);

                                    ODLCStructure.Latitude = GPSLat + target_y_m/60/1852;
                                    ODLCStructure.Longitude = GPSLong + target_x_m/(60 * 1852 * cos(GPSAltitude * pi/180));

                                    if InteropOn
                                        [success, imageId] = InteropODLCSubmit(cookie, uri, missionId, ODLCStructure);
                                    if success
                                        fprintf("Send element to Interop ! \n" );
                                        success = InteropUploadImage(cookie, imageId, uri, missionId, cropImage);
                                    end
                                   end
                                end
                                lastConfidenceLevel = 0;
                            end
                        end
                    end
                end
            end
        end
        fprintf("---- Done with : %s \n", filename);
    end
end