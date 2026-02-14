## home-manager using flakes
step 1: install home-manager and activate it (see official documentation, init command), if not on nixos allow it to manage itself.
step 2:
## Rebuilding your system
assuming your configuration in flake.nix is called cipo:

```bash
home-manager switch --flake ~/dotfiles/home-manager/#cipo
```
## Updating the packages
in this directory run:
```bash
nix flake update
```
