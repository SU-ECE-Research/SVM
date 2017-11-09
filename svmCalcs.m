function [totalSpots, templateSpots, spotDensity, templateCoverage, avgSize]...
                       = svmCalcs(template, BBOX)
%{
Inputs: 
    - template: the black and white motion template after morphology
    - BBOX: the detected spots
                                                
Outputs:
    - totalSpots: total number of spots detected in the image
    - templateSpots: number of spots which overlap with the template
    - spotDensity: number of template spots divided by the number of white
        pixels in the template
    - templateCoverage: ratio of the white pixels in the image to total
        image size
    - avgSize: average size of spots on template (area, normalized based on
        total image siz)
                                               

Author: Taz Bales-Heisterkamp
C: 1/30/17
E: 1/30/17
%}

%% Work

% Count total spots
[totalSpots, ~] = size(BBOX);

% Find the spots in the template and count them
BBOX_prime = spotsInTemplate(BBOX, template, 3);
[templateSpots, ~] = size(BBOX_prime);

% Find number of white pixels in the template (motion)
whitePixels = sum(sum(template));
% Don't divide by zero (in case of no motion in the image)
whitePixels = max(whitePixels, 1);

% Find total number of pixels in the image
totalPixels = numel(template);
% Don't divide by zero
totalPixels = max(totalPixels, 1);

% Calculate spot density
spotDensity = templateSpots/whitePixels;

% Calculate amount of the image that is motion
templateCoverage = whitePixels/totalPixels;

% Calculate the average size of the spots on the template compared to
% total image size
if ~isempty(BBOX_prime)
    widths = BBOX_prime(:,3);
    heights = BBOX_prime(:,4);
    areas = widths.*heights;
    temp_size = sum(areas)/templateSpots;

    % Normalize it to image size
    avgSize = temp_size/totalPixels;
else
    avgSize = 0;
end

