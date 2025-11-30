{
  config,
  dream2nix,
  lib,
  ...
}:
let
  inherit (builtins) substring;

  meta = config.lock.content.fetchPipMetadata.sources.yt-dlp;
  semver = meta.version;
  hash = meta.sha256;

  name = "yt-dlp";
  version = "${semver}-${substring 0 6 hash}";
  src = "https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz";
in
{
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps =
    { nixpkgs, ... }:
    {
      python = nixpkgs.python3;
      inherit (nixpkgs.python3Packages) hatchling;
      inherit (nixpkgs)
        atomicparsley
        deno
        ffmpeg-headless
        rtmpdump
        ;
    };

  inherit name version;

  buildPythonPackage = {
    pyproject = true;
    makeWrapperArgs =
      let
        runtimeDeps = with config.deps; [
          atomicparsley # thumbnails
          deno # EJS https://github.com/yt-dlp/yt-dlp/wiki/EJS
          ffmpeg-headless # transcoding
          rtmpdump # RTMP stuff
        ];
      in
      [
        ''--prefix PATH : "${lib.makeBinPath runtimeDeps}"''
      ];
  };
  mkDerivation.nativeBuildInputs = with config.deps; [ hatchling ];

  paths.lockFile = "lock.${config.deps.stdenv.system}.json";

  pip = {
    requirementsList = [
      "${config.name}[default] @ ${src}"
    ];
    pipFlags = [
      "--no-binary"
      ":all:"
    ];
    nativeBuildInputs = with config.deps; [
      deno # needed by EJS when locking
    ];
  };
}
