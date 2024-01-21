include profiles.mk

# By default substitute urls specified only for Profiles and Initialization
SUBSTITUTE_URLS=https://bordeaux.guix.gnu.org \
https://substitutes.nonguix.org

GUIX_PROFILE=target/profiles/guix
GUIX=./pre-inst-env ${GUIX_PROFILE}/bin/guix

SRC_DIR=./src
CONFIGS=${SRC_DIR}/rde-configs/configs.scm
PULL_EXTRA_OPTIONS= \
--allow-downgrades

ROOT_MOUNT_POINT=/mnt

repl: guix
	${GUIX} repl -L ../tests \
	-L ../files/emacs/gider/src

ares-rs: guix
	${GUIX} shell guile-next guix guile-ares-rs -- guile \
	-c "((@ (nrepl server) run-nrepl-server) #:port 7888)"

tux/system/init: guix
	RDE_TARGET=tux-system \
	INTEGRATE_HE=1 \
	${GUIX} system --substitute-urls="${SUBSTITUTE_URLS}" \
	init ${CONFIGS} ${ROOT_MOUNT_POINT}
