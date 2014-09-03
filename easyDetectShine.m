% just a small script that slightly changes the interface 
% of easyDetectShine

function [shine_tot shine_hz shine_vt] = easyDetectShine(L,R,DL)

[~, shine_hz, shine_vt] = detectBlockShine(L, R, DL);
shine_tot = shine_hz + shine_vt;