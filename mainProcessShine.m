% this is the main function
% it optimizes for the shine energy by iterative processing
% until convergence or 20 iterations.

function mainProcessShine(seq, qlR)

% feedback
fprintf('Processing %s, quality level: %d\n',seq,qlR);

% parameters
qlL = qlR;
const = (3-1)/(5-1);
ds = 3;                % downsampling factor
numIter = 20;          % pmOld = zeros(floor(size(R)/8));
enerOld = inf;

%processing threshold
thresh = 17;           % 28 means perfect / full detection
                       % thresh = 17; %3 edge detections

% read images
DL = const*double(imread(sprintf('input/%s/disp1_cropped.png',seq)))/ds;    % disparity map
L = imread(sprintf('input/%s/view1_ql%d.jpg',seq,qlL));   % compressed images
R = imread(sprintf('input/%s/view3_ql%d.jpg',seq,qlR));   %

% write the initial detections to a file
[shine_tot shine_hz shine_vt] = easyDetectShine(L,R,DL);
R = double(R);
map_hz = abs(shine_hz) == 0;
map_vt = abs(shine_vt) == 0;
map = ~or(~map_hz, ~map_vt);
overlayR = R.*map + abs(shine_tot).*(~map);
overlayR(:,:,2:3) = repmat(R.*map,[1 1 2]);
imwrite(uint8(overlayR), sprintf('output/%s/view3_ql%d_overlayR.png',seq,qlR)); 
 

% check for convergence
for idx=1:numIter
%     counter(1,ii,20)
    [R pm] = processIterationShine(L,R,DL,qlR,thresh);
    
    if sum(pm(:)) == enerOld
        break;
    end
    enerOld = sum(pm(:));
end

% write the processed image into a file
imwrite(uint8(R), sprintf('output/%s/view3_ql%d_processed.jpg',seq,qlR)); 

% write the final detections after processing into a file
R = double(imread(sprintf('output/%s/view3_ql%d_processed.jpg',seq,qlR)));
[shine_tot shine_hz shine_vt] = easyDetectShine(L,R,DL);
map_hz = abs(shine_hz) == 0;
map_vt = abs(shine_vt) == 0;
map = ~or(~map_hz, ~map_vt);overlayR = R.*map + abs(shine_tot).*(~map);
overlayR(:,:,2:3) = repmat(R.*map,[1 1 2]);
imwrite(uint8(overlayR), sprintf('output/%s/view3_ql%d_overlayR_processed.png',seq,qlR)); 