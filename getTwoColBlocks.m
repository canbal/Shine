function cols = getTwoColBlocks(im, c, blockSz)

cols = im(:, (c-1)*blockSz + 1 : (c+1)*blockSz, :);

