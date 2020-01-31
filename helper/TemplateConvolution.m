function [success, confidenceLevel, xoffSet, yoffSet, sizeY, sizeX] = TemplateConvolution(image, template, formeString, trustLevel, minAreaValue)

% Init Value
success = false;
xoffSet = 0;
yoffSet = 0;
sizeY = 0;
sizeX = 0;
confidenceLevel = 0;

templateArea = bwarea(template);
ImageArea = bwarea(image);
ratio = ImageArea/templateArea;

template = imresize(template, sqrt(ratio));
[templateSizeX, templateSize] = size(template);
[imageSizeX, imageSizeY] = size(image);

if ImageArea > minAreaValue 

    GPUTemplate = gpuArray(template);
    GPUImage = gpuArray(image);
    
    %GPUTemplate = template;
    %GPUImage = image;
    
    if imageSizeX * imageSizeY > templateSizeX * templateSize 
        c = normxcorr2(GPUTemplate, GPUImage);
    else
        c = normxcorr2(GPUImage, GPUTemplate);
    end

    if max(c(:)) > trustLevel
        %fprintf("Find %s at trustLevel %d.\n",formeString, max(c(:)) * 100);

        [ypeak, xpeak] = find(c==max(c(:)));
        yoffSet = ypeak-size(template,1) - size(template,1)*0.1;
        xoffSet = xpeak-size(template,2) - size(template,2)*0.1;

        success = true;
        xoffSet = xoffSet + 1;
        yoffSet = yoffSet + 1;
        sizeY =  size(template,2) * 1.2;
        sizeX = size(template,1)* 1.2;
        confidenceLevel = max(c(:));
    else
        %fprintf("This is not a %s at trustLevel %d.\n", formeString, max(c(:)) * 100);
    end
end

end

