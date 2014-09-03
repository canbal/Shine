function rows = getTwoRowBlocks(im, r, blockSz)

rows = im((r-1)*blockSz + 1 : (r+1)*blockSz, :, :);

