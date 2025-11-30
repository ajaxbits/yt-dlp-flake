{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      dream2nix,
      unstable,
    }:
    let
      eachSystem = unstable.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      packages = eachSystem (system: {
        default = dream2nix.lib.evalModules {
          packageSets.nixpkgs = unstable.legacyPackages.${system};
          modules = [
            ./package.nix
            {
              paths = {
                package = ./.;
                projectRoot = ./.;
                projectRootFile = "flake.nix";
              };
            }
          ];
        };
      });
    };
}
