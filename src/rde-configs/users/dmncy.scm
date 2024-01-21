(define-module (rde-configs users dmncy)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix channels)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module (guix packages)
  #:use-module (rde features base)
  #:use-module (rde features clojure)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features gnupg)
  #:use-module (rde features irc)
  #:use-module (rde features keyboard)
  #:use-module (rde features mail)
  #:use-module (rde features networking)
  #:use-module (rde features password-utils)
  #:use-module (rde features security-token)
  #:use-module (rde features system)
  #:use-module (rde features xdg)
  #:use-module (rde features markup)
  #:use-module (rde features containers)
  #:use-module (rde features virtualization)
  #:use-module (rde features presets)
  #:use-module (rde features version-control)
  #:use-module (rde features)
  #:use-module (rde home services emacs)
  #:use-module (rde home services i2p)
  #:use-module (rde home services wm)
  #:use-module (rde home services video)
  #:use-module (rde packages aspell)
  #:use-module (rde packages)
  #:use-module (srfi srfi-1))

(define* (mail-acc id user #:optional (type 'gmail))
  "Make a simple mail-account with gmail type by default."
  (mail-account
   (id id)
   (fqda user)
   (type type)))

(define* (mail-lst id fqda urls)
  "Make a simple mailing-list."
  (mailing-list
   (id id)
   (fqda fqda)
   (config (l2md-repo
            (name (symbol->string id))
            (urls urls)))))

(define emacs-extra-packages-service
  (simple-service
   'emacs-extra-packages
   home-emacs-service-type
   (home-emacs-extension
    (init-el
     `((with-eval-after-load 'simple
         (setq-default display-fill-column-indicator-column 80)
         (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))

       (setq copyright-names-regexp
             (format "%s <%s>" user-full-name user-mail-adress))
       (add-hook 'after-save-hook (lambda () (copyright-update nil nil)))))
    (elisp-packages
     (append
      (list
       )
      (strings->packages
       "emacs-eat"
       "emacs-wgrep"
       "emacs-hl-todo"
       "emacs-arei"))))))

(define home-extra-packages-service
  (simple-service
   'home-profile-extra-packages
   home-profile-service-type
   (append
    (list
     )
    (strings->packages
     "pavucontrol"
     "obs" "obs-wlrobs"
     "make" "gdb"
     "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-extra"
     "ffmpeg"
     "thunar" "curl"))))

(define (wallpaper url hash)
  (origin
   (method url-fetch)
   (uri url)
   (file-name "wallpaper.png")
   (sha256 (base32 hash))))

(define wallpaper-ai-art
  (wallpaper "https://w.wallhaven.cc/full/j3/wallhaven-j3m8y5.png"
             "0qqx6cfx0krlp0pxrrw0kvwg6x40qq9jic90ln8k4yvwk8fl1nyw"))

(define wallpaper-dark-rider
  (wallpaper "https://w.wallhaven.cc/full/lm/wallhaven-lmlzwl.jpg"
             "01j5z3al8zvzqpig8ygvf7pxihsj2grsazg9yjiqyjgsmp00hpaf"))

(define sway-extra-config-service
  (simple-service
   'sway-extra-config
   home-sway-service-type
   `((input type:touchpad
            ((natural_scroll enabled)
             (tap enabled)))
     )))

(define mpv-add-user-settings-service
  (simple-service
   'mpv-add-user-settings
   home-mpv-service-type
   (home-mpv-extension
    (mpv-conf
     `((global
        ((keep-open . yes)
         (ytdl-format . "bestvideo[height<=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best
")
         (save-position-on-quit . yes)
         (speed . 1.61))))))))

(define (feature-additional-services)
  (feature-custom-services
   #:feature-name-prefix 'dmncy
   #:home-services
   (list
    emacs-extra-packages-service
    home-extra-packages-service
    sway-extra-config-service
    ;; ssh-extra-config-service
    ;; i2pd-add-ilita-irc-service
    mpv-add-user-settings-service)))

(define dev-features
  (list
   (feature-markdown)))

(define general-features
  (append
   rde-base
   rde-desktop
   rde-mail
   rde-cli
   rde-emacs))

(define %all-features
  (append
   dev-features
   general-features))

(define nonguix-key
  (origin
   (method url-fetch)
   (uri "https://substitutes.nonguix.org/signing-key.pub")
   (sha256
    (base32 "0j66nq1bxvbxf5n8q2py14sjbkn57my0mjwq7k1qm9ddghca7177"))))

(define all-features-with-custom-substitutes
  (append
   (remove (lambda (f)
             (member
              (feature-name f)
              '(base-services
                kernel
                git)))
           %all-features)
   (list
    (feature-git #:sign-commits? #f)
    (feature-base-services
     #:default-substitute-urls (list "https://bordeaux.guix.gnu.org")
     #:guix-substitute-urls (list "https://substitutes.nonguix.org")
     #:guix-authorization-keys (list nonguix-key)))))

(define-public %dmncy-features
  (append
   all-features-with-custom-substitutes
   (list
    (feature-additional-services)
    (feature-user-info
     #:user-name "dmncy"
     #:user-name "Dmitry Klementiev"
     #:email "kdmncy@gmail.com"
     #:user-initial-password-hash
     "$6$abc$AW6FKPI/QLxLya0GEsTxE8OdJwOVlvlqVp0IMGFZ9hl2vu90WUgahJg80fBJ7GBPgKSDKHEFO1YoqxoFg4Lk.."
     #:emacs-advanced-user? #t)
    ;; (feature-gnupg
    ;;  #:gpg-primary-key ""
    ;;  #:ssh-keys '())
    ;; (feature-password-store
    ;;  #:password-store-directory "/data/password-store")
    (feature-mail-settings
     ;; #:mail-directory-fn (const "/data/mail")
     #:mail-accounts (list
                      (mail-acc 'personal "kdmncy@gmail.com"))
     #:mailing-lists '())
    (feature-xdg)
    (feature-emacs-keycast #:turn-on? #t)
    (feature-emacs-time)
    (feature-emacs-git)
    (feature-keyboard
     #:keyboard-layout
     (keyboard-layout
      "us,ru"
      #:options '("grp:shifts_toggle" "ctrl:nocaps"))))))
