function filter = makeMe1DFilter(orgFilter, desSz)

if size(orgFilter,1) ~= 1
    error('This is a 1D filter tool dude!');
end

filter = zeros([1 desSz]);

len = size(orgFilter,2);

if len <= desSz
    pad = floor((desSz - len)/2);
    filter(1+pad:len+pad) = orgFilter;
else
    trunc = floor((len - desSz)/2);
    filter = orgFilter(1+trunc:desSz+trunc);
end