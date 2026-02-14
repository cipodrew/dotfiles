## via gpt
the cleanest and most flexible way to manage **different Home Manager configs per machine** is with **flakes**, using either:

* Conditional logic based on hostname
* Or defining separate `homeConfigurations` per machine

Here’s how to do **both**, step-by-step.

---

## ✅ Option 1: Use hostname-based conditional logic (single config)

This allows shared config with per-machine overrides.

### 🗂️ `flake.nix`

```nix
{
  description = "Home Manager config for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      hostname = builtins.getEnv "HOSTNAME";
    in {
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./home.nix

            (if hostname == "work-pc" then ./work.nix else {})
            (if hostname == "gaming-pc" then ./gaming.nix else {})
          ];
          username = "your-username";
          homeDirectory = "/home/your-username";
        };
      };
    };
}
```

### 📝 `home.nix` (shared config)

```nix
{ config, pkgs, ... }:

{
  home.packages = [ pkgs.git ];
}
```

### 📝 `work.nix`

```nix
{ config, pkgs, ... }:

{
  home.packages = [ pkgs.vscode pkgs.zoom-us ];
}
```

### 📝 `gaming.nix`

```nix
{ config, pkgs, ... }:

{
  home.packages = [ pkgs.steam pkgs.discord ];
}
```

### ▶️ To apply:

Make sure `HOSTNAME` is correct (set automatically on most systems), then run:

```bash
home-manager switch --flake .#user
```

---

## ✅ Option 2: One config per host (preferred for clean separation)

```nix
{
  description = "Multi-PC Home Manager setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      "user@work-pc" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [ ./work.nix ];
        username = "user";
        homeDirectory = "/home/user";
      };

      "user@gaming-pc" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [ ./gaming.nix ];
        username = "user";
        homeDirectory = "/home/user";
      };
    };
  };
}
```

Apply with:

```bash
home-manager switch --flake .#user@work-pc
```

or

```bash
home-manager switch --flake .#user@gaming-pc
```

---

## 🧼 Recommendation

* Use **Option 1** if you prefer a shared config with some branching.
* Use **Option 2** if you want maximum clarity and separation (e.g. fewer conditionals, easier maintenance as the setup grows).

Would you like me to help you bootstrap this flake structure in a folder?

