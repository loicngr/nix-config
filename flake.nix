{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";

    noctalia = {
      # v5 pinné sur un tag : aucun tag v5.0.0 stable n'existe encore, beta.7 est
      # la dernière beta (2026-07-30). Pin par tag = `nup` ne re-bumpe pas le shell ;
      # la montée de version reste une décision explicite. Rollback = branche main (v4.7.7).
      url = "github:noctalia-dev/noctalia/v5.0.0-beta.8";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      claude-code,
      codex-cli-nix,
      noctalia,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
        overlays = [
          claude-code.overlays.default
          codex-cli-nix.overlays.default
        ];
      };

      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;
      nixosConfigurations.loicngr = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstable; };
        modules = [
          ./configuration.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
      homeConfigurations.loicngr = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit unstable noctalia; };
        modules = [
          noctalia.homeModules.default
          ./modules/php.nix
          ./home-manager/loicngr.nix
        ];
      };
    };
}
