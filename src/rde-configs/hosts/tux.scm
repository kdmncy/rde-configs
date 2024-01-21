(define-module (rde-configs hosts tux)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (ice-9 match))

(define tux-file-systems
  (append
   (map (match-lambda
          ((subvol . mount-point)
           (file-system
            (type "btrfs")
            (device (file-system-label "ROOT"))
            (mount-point mount-point)
            (options (format
                      #f "subvol=~a~a" subvol
                      (if (string= mount-point "/gnu")
                          ",comress=zstd,noatime" ""))))))
        '((@ . "/")
          (@boot . "/boot")
          (@gnu . "/gnu")
          (@var-log . "/var/log")
          (@swap . "/swap")))
   (map (match-lambda
          ((subvol . mount-point)
           (file-system
            (type "btrfs")
            (device (file-system-label "DATA"))
            (mount-point mount-point)
            (options (format #f "subvol=~a,compress=zstd" subvol)))))
        '((@data . "/data")
          (@home . "/home")))
   (list
    (file-system
     (type "vfat")
     (device (file-system-label "ROOT"))
     (mount-point "/boot/efi")))))

(define-public %tux-features
  (list
   (feature-host-info
    #:host-name "tux"
    ;; ls `guix build tzdata`/share/zoneinfo
    #:timezone "Asia/Yekaterinburg")
   (feature-bootloader)
   (feature-file-systems
    #:file-systems tux-file-systems)
   (feature-kanshi
    #:extra-config '())
   (feature-hidpi)))
