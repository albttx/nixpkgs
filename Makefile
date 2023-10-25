IMPURE ?= false

UNAME := $(shell uname)
UNAME_P := $(shell uname -p)
HOSTNAME := $(shell hostname)

ifeq ($(UNAME_P),arm)
BOOTSTRAP := bootstrap-arm
else
BOOTSTRAP := bootstrap-x86
endif

# Channels
NIX_CHANNELS := nixpkgs-master nixpkgs-stable nixpkgs-unstable nixos-stable
HOME_CHANNELS := home-manager darwin
EMACS_CHANNELS := emacs-overlay doom-emacs
SPACEMACS_CHANNELS := spacemacs
DOOM_CHANNELS := doomemacs
ZSH_CHANNELS := fast-syntax-highlighting fzf-tab powerlevel10k zi zsh-colored-man-pages
ASDF_CHANNELS := asdf-plugins
MISC_CHANNELS := flake-utils flake-compat

NIX_FILES := $(shell find . -type f -name '*.nix')

impure := $(if $(filter $(IMPURE),true),--impure,)


ifeq ($(UNAME), Darwin) # darwin rules
all: switch

switch: result/sw/bin/darwin-rebuild
	TERM=xterm ./result/sw/bin/darwin-rebuild switch ${impure} --verbose --flake ".#$(HOSTNAME)"

switch.bootstrap: result/sw/bin/darwin-rebuild
	./result/sw/bin/darwin-rebuild switch ${impure} --verbose --flake ".#$(BOOTSTRAP)"
	TERM=xterm ./result/sw/bin/darwin-rebuild switch ${impure} --verbose --flake .#mbp-albttx

result/sw/bin/darwin-rebuild:
	nix --experimental-features 'flakes nix-command' build ".#darwinConfigurations.$(BOOTSTRAP).system"


endif # end osx


ifeq ($(UNAME), Linux) # linux rules

all:
	@echo "switch.cloud"

switch.cloud:
	nix build .#homeConfigurations.cloud.activationPackage
	./result/activate switch ${impure} --verbose; ./result/activate

endif # end linux

fmt:
	nix-shell -p nixfmt --command "nixfmt  $(NIX_FILES)"

clean:
	./result/sw/bin/nix-collect-garbage

fclean:
	@echo "/!\ require to be root"
	sudo ./result/sw/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations old
	./result/sw/bin/nix-collect-garbage -d
# Remove entries from /boot/loader/entries:


update: update.nix update.emacs update.zsh  update.misc
update.nix:; nix flake lock $(addprefix --update-input , $(NIX_CHANNELS))
update.emacs:; nix flake lock $(addprefix --update-input , $(EMACS_CHANNELS))
