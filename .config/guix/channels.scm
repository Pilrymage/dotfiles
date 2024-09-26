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
          "7EBE A494 60CE 5E2C 0875  7FDB 3B5A A993 E1A2 DFF0")))))
