{
  description = "Helium browser with Widevine CDM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      helium-flake,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      heliumWithWidevine =
        system: pkgs:
        (helium-flake.packages.${system}.helium).overrideAttrs (old: {
          installPhase = old.installPhase + ''
            mkdir -p "$out/opt/helium"
            ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm" "$out/opt/helium/WidevineCdm"
          '';
        });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          helium = heliumWithWidevine system pkgs;
          default = self.packages.${system}.helium;
        }
      );

      overlays.default = final: {
        helium = heliumWithWidevine final.system final;
      };

      homeModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          imports = [ helium-flake.homeModules.default ];

          config = {
            programs.helium = {
              enable = lib.mkDefault true;
              package = lib.mkDefault (heliumWithWidevine pkgs.system pkgs);
            };
          };
        };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
