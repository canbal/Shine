% this is the main processing function for altering the DC value of the
% shiny blocks

function [procMapVals newR] = processShinyImage(qlR,R,shine_hz,shine_vt,shine_tot,thresh,SGN)

blockSz = 8;

%depending on the quantization level of JPEG, the step size changes
if (qlR < 50)
    c = 50/qlR;
else
    c = (100 - qlR)/50;
end
step_sz = round(16*c/blockSz);

[M N] = size(R);
Mb = floor(M/blockSz);
Nb = floor(N/blockSz);
Mbpix = Mb*blockSz;
Nbpix = Nb*blockSz;

shineMapHz = shine_hz~=0;
shineMapVt = shine_vt~=0;
shineMap = or(shineMapHz, shineMapVt);

procMap = zeros(Mb,Nb); %3 or more edges shiny blocks

% detect shining blocks
for ii=1:Mb
    for jj=1:Nb
        det = shineMap((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
            (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz));
                   
        if sum(det(:)) > thresh %test for blocks with 3 or more edges shiny
            procMap(ii,jj) = 1;
        end
    end
end

newR = double(R(1:Mbpix,1:Nbpix));

% process shining blocks
procMapVals = zeros(Mb,Nb);
for ii=1:Mb
    for jj=1:Nb
        if procMap(ii,jj) == 1
            Rb = R((ii-1)*blockSz+1:ii*blockSz, (jj-1)*blockSz+1:jj*blockSz);
            shine = shine_tot((ii-1)*blockSz+1 : min(Mbpix,ii*blockSz), ...
                (jj-1)*blockSz+1 : min(Nbpix,jj*blockSz));
            procMapVals(ii,jj) = mean(abs(shine(:)));
 
            if nargout > 1
                if isequal(SGN,'positive')
                    val = Rb + step_sz;%*min(round(adjVal/step_sz),stepThresh);
                elseif isequal(SGN,'negative')
                    val = Rb - step_sz;%*min(round(adjVal/step_sz),stepThresh);
                else
                    error('SGN is either ''positive'' or ''negative''.');
                end
                newR((ii-1)*blockSz+1:ii*blockSz, (jj-1)*blockSz+1:jj*blockSz) = val;
            end
        end
    end
end