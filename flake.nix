{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      perSystem =
        { pkgs, system, ... }:
        let
          yt-dlp-pkg = pkgs.callPackage ./package.nix {
            inherit (pkgs)
              lib
              fetchFromGitHub
              ;

            inherit (pkgs)
              python3Packages
              ffmpeg-headless
              rtmpdump
              atomicparsley
              ;
          };
        in
        {
          packages.default = yt-dlp-pkg;
        };
    };
}
