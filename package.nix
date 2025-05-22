{
  lib,
  python3Packages,
  fetchFromGitHub,
  ffmpeg-headless,
  rtmpdump,
  atomicparsley,
  atomicparsleySupport ? true,
  ffmpegSupport ? true,
  rtmpSupport ? true,
}:

python3Packages.buildPythonApplication rec {
  pname = "yt-dlp";
  version = "415b4c9f955b1a0391204bd24a7132590e7b3bdb";
  pyproject = true;

  # src = fetchPypi {
  #   inherit version;
  #   pname = "yt_dlp";
  #   hash = "sha256-0BNn0MOulONcseLsy3p8cOGBxMpEj07iN08mSJ0mNgM=";
  # };

  # python3 -m pip install -U pip hatchling wheel
  # python3 -m pip install --force-reinstall "yt-dlp[default] @ https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz"
  # got this with nurl
  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "yt-dlp";
    rev = "415b4c9f955b1a0391204bd24a7132590e7b3bdb";
    hash = "sha256-Ahdu52dTbRz+8c06yQ6QOTVcbVYP2d1iYjYyjKDi8Wk=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  # expose optional-dependencies, but provide all features
  dependencies = lib.flatten (lib.attrValues optional-dependencies);

  optional-dependencies = {
    default = with python3Packages; [
      brotli
      certifi
      mutagen
      pycryptodomex
      requests
      urllib3
      websockets
    ];
    curl-cffi = [ python3Packages.curl-cffi ];
    secretstorage = with python3Packages; [
      cffi
      secretstorage
    ];
  };

  pythonRelaxDeps = [ "websockets" ];

  # Ensure these utilities are available in $PATH:
  # - ffmpeg: post-processing & transcoding support
  # - rtmpdump: download files over RTMP
  # - atomicparsley: embedding thumbnails
  makeWrapperArgs =
    let
      packagesToBinPath =
        lib.optional atomicparsleySupport atomicparsley
        ++ lib.optional ffmpegSupport ffmpeg-headless
        ++ lib.optional rtmpSupport rtmpdump;
    in
    lib.optionals (packagesToBinPath != [ ]) [
      ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"''
    ];

  setupPyBuildFlags = [
    "build_lazy_extractors"
  ];

  # Requires network
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/yt-dlp/yt-dlp/";
    description = "TODO";
    longDescription = ''
      TODO
    '';
    changelog = "https://github.com/yt-dlp/yt-dlp/blob/HEAD/Changelog.md";
    license = licenses.unlicense;
    maintainers = with maintainers; [
      ajaxbits
    ];
    mainProgram = "yt-dlp";
  };
}
