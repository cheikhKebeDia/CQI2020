function [dominantColorString, seconderyColorString] = FindDominantColor(image)

Color = ["WHITE"; "BLACK"; "GRAY"; "RED"; "BLUE"; "GREEN"; "YELLOW"; "PURPLE"; "BROWN"; "ORANGE"];
RBGColor = [[255,255,255]; [0,0,0]; [128,128,128]; [255,0,0]; [0,0,255]; [0,255,0]; [255,255,0]; [128,0,128]; [165,42,42]; [255,165,0]];
NumberOfColor = 10;

dominantColorString = "";
seconderyColorString = "";

dominantRedValue = int32(0);
dominantGreenValue = int32(0);
dominantBlueValue = int32(0);

seconderyRedValue = int32(0);
seconderyGreenValue = int32(0);
seconderyBlueValue = int32(0);

lastRedValue = 0;
lastGreenValue = 0;
lastBlueValue = 0;

count = 0;
countSecondery = 0;
delta = 10;

[rows, columns, numberOfColorChannels] = size(image);

% Do the average without the black
if numberOfColorChannels == 3
  % It's a color image.
  for column = 1 : columns
    for row = 1 : rows
      redValue = image(row, column, 1);
      greenValue = image(row, column, 2);
      blueValue = image(row, column, 3);
      
      if lastRedValue == 0 && lastGreenValue == 0 && lastBlueValue == 0
          lastRedValue = redValue;
          lastGreenValue = greenValue;
          lastBlueValue = blueValue;
      end
      
      if redValue + delta >= lastRedValue && redValue - delta <= lastRedValue && greenValue + delta >= lastGreenValue && greenValue - delta <= lastGreenValue && blueValue + delta >= lastBlueValue && blueValue - delta <= lastBlueValue
          if (redValue + greenValue + blueValue) ~= 0  
              dominantRedValue = int32(dominantRedValue + int32(redValue));
              dominantGreenValue = int32(dominantGreenValue + int32(greenValue));
              dominantBlueValue = int32(dominantBlueValue + int32(blueValue));
              count = count + 1;
          end
      else
          if (redValue + greenValue + blueValue) ~= 0  
              seconderyRedValue = int32(seconderyRedValue + int32(redValue));
              seconderyGreenValue = int32(seconderyGreenValue + int32(greenValue));
              seconderyBlueValue = int32(seconderyBlueValue + int32(blueValue));
              countSecondery = countSecondery + 1;
          end
      end
    end
  end
end

dominantRedValue = dominantRedValue / count;
dominantGreenValue = dominantGreenValue / count;
dominantBlueValue = dominantBlueValue / count;

seconderyRedValue = seconderyRedValue / countSecondery;
seconderyGreenValue = seconderyGreenValue / countSecondery;
seconderyBlueValue = seconderyBlueValue / countSecondery;

dominantColor = [dominantRedValue, dominantGreenValue, dominantBlueValue];
seconderyColor = [seconderyRedValue, seconderyGreenValue, seconderyBlueValue];

%% Find the close color
ColorDelta = 55;

for y = 1:NumberOfColor
     if (RBGColor(y,1) + ColorDelta) >= dominantRedValue && (RBGColor(y,1) - ColorDelta) <= dominantRedValue && (RBGColor(y,2) + ColorDelta) >= dominantGreenValue && (RBGColor(y,2) - ColorDelta) <= dominantGreenValue && (RBGColor(y,3) + ColorDelta) >= dominantBlueValue && (RBGColor(y,3) - ColorDelta) <= dominantBlueValue
        fprintf("Couleur %s \n", Color(y));
        dominantColorString = Color(y);
        return
     end
end

for y = 1:NumberOfColor
     if (RBGColor(y,1) + ColorDelta) >= seconderyRedValue && (RBGColor(y,1) - ColorDelta) <= seconderyRedValue && (RBGColor(y,2) + ColorDelta) >= seconderyGreenValue && (RBGColor(y,2) - ColorDelta) <= seconderyGreenValue && (RBGColor(y,3) + ColorDelta) >= seconderyBlueValue && (RBGColor(y,3) - ColorDelta) <= seconderyBlueValue
        fprintf("Couleur %s \n", Color(y));
        seconderyColorString = Color(y);
        return
     end
end

end

