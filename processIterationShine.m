% this handles the processing in both directions (positive/negative)
% after each step checks for the blocks that have reduced the shine
% replaces the beneficial ones with the older ones
% for the rest, it puts the previous block values back

function [finalImg pm2] = processIterationShine(L,R,DL,qlR,thresh)

blockSz = 8;
[M N] = size(R);
Mb = floor(M/blockSz);
Nb = floor(N/blockSz);
Mbpix = Mb*blockSz;
Nbpix = Nb*blockSz;

% run detector
[shine_tot, shine_hz, shine_vt] = easyDetectShine(L,R,DL);
% process image with positive adjustment
[procMapVals, newR_pos] = processShinyImage(qlR,R,shine_hz,shine_vt,shine_tot,thresh,'positive');
[~, shine_hz_proc1 shine_vt_proc1] = easyDetectShine(L,newR_pos,DL);
pm1 = processShinyImage(qlR,newR_pos,shine_hz_proc1,shine_vt_proc1,shine_tot,thresh);
finalImg = zeros(size(newR_pos));
for ii=1:Mb
    for jj=1:Nb
        if (procMapVals(ii,jj) - pm1(ii,jj)) > 0% if the amount of shine is decreased
            block = newR_pos((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                          (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz));
        else
            block = R((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                      (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz));
        end
        finalImg((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                 (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz)) = block;
    end
end

% run detector 
[shine_tot, shine_hz, shine_vt] = easyDetectShine(L,finalImg,DL);
% process image with negative adjustment
[procMapVals, newR_neg] = processShinyImage(qlR,finalImg,shine_hz,shine_vt,shine_tot,thresh,'negative');
[~, shine_hz_proc2, shine_vt_proc2] = easyDetectShine(L,newR_neg,DL);
pm2 = processShinyImage(qlR,newR_neg,shine_hz_proc2,shine_vt_proc2,shine_tot,thresh);

% compose final image from the image processed both directions
for ii=1:Mb
    for jj=1:Nb
        if (procMapVals(ii,jj) - pm2(ii,jj)) > 0
            block = newR_neg((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz));
            finalImg((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz)) = block;
        end
    end
end

