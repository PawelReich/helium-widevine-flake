# Helium browser with Widevine CDM

Nix flake that packages [Helium](https://helium.computer/) [oxcl/nix-flake-helium-browser](https://github.com/oxcl/nix-flake-helium-browser) together with the Widevine CDM sourced from `nixpkgs.widevine-cdm`.

That bundle allows you to play DRMed content, such as Spotify.

Note that this is a L3 Widevine solution, so e.g. Netflix will cap the media at 720p.

Browser will will require a restart after the first launch to properly register the binary.

## Usage

### Flake

```nix
inputs = {
  helium-widevine.url = "github:USER/helium-widevine-flake";
};
```

### Overlay

```nix
nixpkgs.overlays = [ inputs.helium-widevine.overlays.default ];
```

### Home Manager module

```nix
{
  imports = [ inputs.helium-widevine.homeModules.default ];

  programs.helium.enable = true;
}
```

Widevine is an unfree package, so enable those in your config:

```nix
nixpkgs.config.allowUnfree = true;
```
