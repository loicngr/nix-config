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
      url = "github:noctalia-dev/noctalia/v5.4.1";
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
      # shortcut: solaar (stable) teste un vrai dbus dans le sandbox de build et
      # plante -> on prend la version unstable (deja en cache binaire, pas de
      # rebuild). upgrade: retirer si nixpkgs stable corrige le test upstream
      solaarOverlay = final: prev: {
        solaar = unstable.solaar;
      };
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
        overlays = [
          claude-code.overlays.default
          codex-cli-nix.overlays.default
          solaarOverlay
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
            nixpkgs.overlays = [ solaarOverlay ];
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
