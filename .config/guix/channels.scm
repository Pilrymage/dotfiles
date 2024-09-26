(list (channel
       (name 'guix)
       (url "https://mirror.sjtu.edu.cn/git/guix.git")
       (branch "master")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'guixcn)
       (url "https://github.com/guixcn/guix-channel.git")
       (branch "master")
       (introduction
        (make-channel-introduction
         "993d200265630e9c408028a022f32f34acacdf29"
         (openpgp-fingerprint
          "7EBE A494 60CE 5E2C 0875  7FDB 3B5A A993 E1A2 DFF0"))))
      (channel
       (name 'giuliano108-guix-packages)
       (url "https://github.com/giuliano108/guix-packages")
       (branch "master"))
      (channel
       (name 'nebula)
       (url "https://git.sr.ht/~apoorv569/nebula")
       (branch "master")
       (introduction
        (make-channel-introduction
         "2f1be757b40f78456220823b71aace5277c5f33d"
         (openpgp-fingerprint
          "53B4 8418 D76A 3EF1 1BCC  92A8 4FDB 05CF 5D67 6283"))))
      (channel
       (name 'emacs)
       (url "https://github.com/babariviere/guix-emacs")
       (branch "master")
       (introduction
        (make-channel-introduction
         "72ca4ef5b572fea10a4589c37264fa35d4564783"
         (openpgp-fingerprint
          "261C A284 3452 FB01 F6DF  6CF4 F9B7 864F 2AB4 6F18")))))
