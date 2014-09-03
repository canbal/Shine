function block = getBlock(im, r, c, blockSz)

block = im((r-1)*blockSz + 1 : r*blockSz, (c-1)*blockSz + 1 : c*blockSz, :);