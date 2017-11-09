function BBOX_prime = spotsInTemplate(BBOX, template, corners)
% determines which spots are contained in a template
%{
INPUT: 
    - BBOX 
        Nx4 integer matrix
        BBOX(1,:) == (x1, y1, width1, height1) [RASTER]
        Defined by: step(detector, image)
    - template 
        D_1xD_2 logical matrix
        1/TRUE == motion (identified by rpca/templating
    - corners
        integer in range [1,4]
        specifies how many corners must be in template to be valid
OUTPUT:
    - BBOX_prime
        N_prime x 4 integer matrix
        boxes contained within template

Joshua Beard & Taz Bales-Heisterkamp
C: 1/29/17
E: 1/30/17
%}

% Default corners is 4
if nargin < 3
    corners = 4;
% If corners was defined as some weird number, ignore it and default to 4
elseif corners < 1 || round(corners) ~= corners || corners > 4
    warning('CORNERS must be an integer in range [1,4]. Defaulting to 4');
    corners = 4;
end

[n,~] = size(BBOX);
n_p = 0;
for q = 1:n
    % If all four corners of bounding box are in template
    if( template( BBOX(q,2)          ,BBOX(q,1)          )   +...
        template( BBOX(q,2)+BBOX(q,4),BBOX(q,1)          )   +...
        template( BBOX(q,2)          ,BBOX(q,1)+BBOX(q,3))   +...
        template( BBOX(q,2)+BBOX(q,4),BBOX(q,1)+BBOX(q,3))   >= corners )
        % Add to new BBOX
        n_p = n_p+1;
        BBOX_prime(n_p,:) = BBOX(q,:);
    end
end

if n_p == 0
    BBOX_prime = [];
end