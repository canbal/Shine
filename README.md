# Welcome to Shine

Binocular luster is an extremely salient effect seen in 3D when an object in each stereo image exhibits a different contrast polarity relative to the background. The object appears to shimmer, a phenomenon seen in nature and on 3D displays, which the Human Visual System rapidly detects. This binocular luster is also induced by compression of stereo imagery where corresponding blocks are quantized to different values. In this paper, we discuss the psychovisual background of binocular luster, introduce the "shine" artifact induced by compression, and present an algorithm for detection and removal of shine from JPEG compressed stereo images without introducing additional bitrate.

## Contents

The Matlab code for our ICASSP publication: C. Bal, A. Jain, T.Q. Nguyen, "Detection and Removal of Binocular Luster in Compressed 3D Images," IEEE Int. Conf. on Acoustics, Speech and Signal Processing (ICASSP) 2011, May 2011. 

[[Project Link](http://canbal.me/shine.php)] [[Paper Link](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=5946661)]

## Authors and Contributors

Can Bal (<a href="https://github.com/canbal" class="user-mention">@canbal</a>) Ankit K. Jain (<a href="https://github.com/ankitkj" class="user-mention">@ankitkj</a>)

## License

This content is released under the [MIT License](https://github.com/canbal/Shine/blob/master/LICENSE). For any documented use of our software in reports, publications, etc., we ask that you cite our paper [1].  If you want to cite the Shine website, please use [2].

[1] C. Bal, A. Jain, T.Q. Nguyen, "Detection and Removal of Binocular Luster in Compressed 3D Images," IEEE Int. Conf. on Acoustics, Speech and Signal Processing (ICASSP) 2011, May 2011. [[Link](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=5946661)]

[2] http://canbal.me/shine.php

## How to Run

- Run "processAllImages.m" to apply "mainProcessShine.m" over all images.
