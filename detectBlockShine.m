% Shine Detector w/o Figure Outputs:
% Author: Can Bal (cbal -at- ucsd.edu), Ankit Jain (ankitkj -at- ucsd@edu)
% Last updated: 11/02/2010
%
% Usage: [etrR, shine_hz, shine_vt, reliable] = detectBlockShine(L, R, DL, mask)
% 
% Outputs:
%     etrR: extrapolated right view
%     shine_hz: detected shine in horizontal direction
%     shine_vt: detected shine in vertical direction
%     reliable: for explanation see Notes section
%        
% Inputs:
%     L: left view
%     R: right view
%     DL: disparity map of left view
%     mask: for explanation see Notes section
%
% Notes:
%   1- call detectBlockShine with original, uncompressed images
%   2- calculate the object boundaries and erroneous shine detections
%   3- call detectBlockShine with compressed images, and pass the reliable
%      pixels as the input "mask"
%   4- remove shine_tot calculated in step 1 from the shine_tot calculated
%      in step 4

function [etrR, shine_vt, shine_hz, reliable] = detectBlockShine(L, R, DL, mask)

if nargin < 4
    mask = ones(size(DL));
end

% parameters
filterCoef = 0.8;   % decay coefficient of the filter
filterLen = 8;      % even number, less then 16; values higher 16 has no effect!!
blockSz = 8;        % hard-coded in the JPEG algorithm
polDiffThresh = 1;  % prevents really small values of polarity differences
                    %    from showing up in polarity difference map

% calculate the disparity map in block level
[M N C] = size(L);
m = floor(M/blockSz);
n = floor(N/blockSz);
cube = zeros(m,n,blockSz^2);
for r = 1:m
    for c = 1:n
        tmp_d = DL((r-1)*blockSz+1 : r*blockSz, (c-1)*blockSz+1 : c*blockSz, :);
        cube(r,c,:) = tmp_d(:);
    end
end
dl = median(cube,3);

% block mapping to second view from the first view
test1 = round(dl)~=0;
x1p = repmat((1:n),[m 1]) - round(dl/blockSz);
tmp1 = zeros(M,2*N,C);
for y=1:m      % have to do in a loop for memory reasons
    for ff = find(test1(y,:));
        x1 = x1p(y,ff) + n;
        tmp1((y-1)*blockSz + 1: y*blockSz, (x1-1)*blockSz + 1: x1*blockSz,:)...
                    = getBlock(L,y,ff,blockSz);
    end
end
etrR = uint8(tmp1(:,n*blockSz+1:n*blockSz+N,:));

% edge detection
% detect the object boundaries using sobel edge detection, not used in this
% instance, calculated for using it as such:
%   1- call detectBlockShine with original, uncompressed images
%   2- calculate the object boundaries and erroneous shine detections
%   3- call detectBlockShine with compressed images, and pass the reliable
%      pixels as the input "mask"
%   4- remove shine_tot calculated in step 1 from the shine_tot calculated
%      in step 4
if nargout==4
    edges = edge(R,'sobel','nothinning');
    reliable = not(edges);%not(imdilate(edges,strel('rectangle',[3 3])));
end

% generate the shine filters, basically HPFs
filt_hz = filterCoef.^(0:7);
filt_hz = [-1*fliplr(filt_hz) filt_hz];
filt_hz = makeMe1DFilter(filt_hz, filterLen);
filt_hz = makeMe1DFilter(filt_hz, 16);
filt_hz = filt_hz/sum(filt_hz.^2); % normalize power of filter
filt_vt = filt_hz';

% shine along horizontal direction
filt_hz = repmat(filt_hz, [M 1]);
pol_hz_R = zeros(M,N);
pol_hz_etrR = zeros(M,N);
for c = 1:n-1
    colsR = double(getTwoColBlocks(R,c,blockSz));
    colsEtrR = double(getTwoColBlocks(etrR,c,blockSz));
    colsEtrRMask = (sum(colsEtrR(:,1:blockSz),2)...    % remove occluded and unknown
        .*sum(colsEtrR(:,blockSz+1:2*blockSz),2))~=0;  %    block values from calculations
    pol_hz_R(:,c*blockSz+(0:1)) = repmat(sum(filt_hz.*colsR,2).*colsEtrRMask,[1 2]);
    pol_hz_etrR(:,c*blockSz+(0:1)) = repmat(sum(filt_hz.*colsEtrR,2).*colsEtrRMask,[1 2]);
end
pol_hz_R(abs(pol_hz_R) < polDiffThresh) = 0;
pol_hz_etrR(abs(pol_hz_etrR) < polDiffThresh) = 0;

% find the opposing contrast polarities between original and rendered view
shine_hz_mask = and((pol_hz_R >= 0),(pol_hz_etrR <= 0));
shine_hz_mask = or(shine_hz_mask,and((pol_hz_R <= 0),(pol_hz_etrR >= 0)));
shine_hz_mask = xor(shine_hz_mask,and((pol_hz_R == 0),(pol_hz_etrR == 0)));
shine_hz = (pol_hz_R-pol_hz_etrR).*shine_hz_mask;
shine_hz = shine_hz.*double(mask);
shine_hz = medfilt2(shine_hz,[blockSz+1 1]);

% shine along vertical direction
filt_vt = repmat(filt_vt, [1 N]);
pol_vt_R = zeros(M,N);
pol_vt_etrR = zeros(M,N);
for r = 1:m-1
    rowsR = double(getTwoRowBlocks(R,r,blockSz));
    rowsEtrR = double(getTwoRowBlocks(etrR,r,blockSz));
    rowsEtrRMask = (sum(rowsEtrR(1:blockSz,:),1)...    % remove occluded and unknown
        .*sum(rowsEtrR(blockSz+1:2*blockSz,:),1))~=0;  %    block values from calculations
    pol_vt_R(r*blockSz+(0:1),:) = repmat(sum(filt_vt.*rowsR,1).*rowsEtrRMask,[2 1]);
    pol_vt_etrR(r*blockSz+(0:1),:) = repmat(sum(filt_vt.*rowsEtrR,1).*rowsEtrRMask,[2 1]);
end
pol_vt_R(abs(pol_vt_R) < polDiffThresh) = 0;
pol_vt_etrR(abs(pol_vt_etrR) < polDiffThresh) = 0;

% find the opposing contrast polarities between original and rendered view
shine_vt_mask = and((pol_vt_R >= 0),(pol_vt_etrR <= 0));
shine_vt_mask = or(shine_vt_mask,and((pol_vt_R <= 0),(pol_vt_etrR >= 0)));
shine_vt_mask = xor(shine_vt_mask,and((pol_vt_R == 0),(pol_vt_etrR == 0)));
shine_vt = (pol_vt_R-pol_vt_etrR).*shine_vt_mask;
shine_vt = shine_vt.*double(mask);
shine_vt = medfilt2(shine_vt,[1 blockSz+1]);