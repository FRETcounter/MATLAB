function [ out ] = thresher(in)

thresh = graythresh(in);
out = imbinarize(in,thresh);


end 