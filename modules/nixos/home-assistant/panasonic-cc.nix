# Panasonic Comfort Cloud, not packaged in nixpkgs.
#
# nixpkgs only ships panasonic_viera (TVs) and panasonic_bluray, neither of
# which touches the AC units, so both the component and its client library
# are built here.
{ pkgs }:
let
  # Custom components have to build against home-assistant's own python
  # package set, otherwise conflicting versions end up in the environment.
  ps = pkgs.home-assistant.python3Packages;

  aio-panasonic-comfort-cloud = ps.buildPythonPackage rec {
    pname = "aio-panasonic-comfort-cloud";
    version = "2026.8.9";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "aio_panasonic_comfort_cloud";
      inherit version;
      hash = "sha256-5ggJUYHNEFYd/Ofyc7Ts3/a9vXAd02Rp+xaoI8qrC0M=";
    };

    # Upstream depends on the "bs4" stub distribution; nixpkgs ships the real
    # thing as beautifulsoup4, which provides the same `bs4` module.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail '"bs4",' '"beautifulsoup4",'
    '';

    # setuptools_scm derives the version from git, which the sdist has no
    # trace of.
    env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

    build-system = with ps; [
      setuptools
      setuptools-scm
    ];

    dependencies = with ps; [
      aiofiles
      aiohttp
      beautifulsoup4
      packaging
      urllib3
    ];

    pythonImportsCheck = [ "aio_panasonic_comfort_cloud" ];
    doCheck = false; # no tests shipped in the sdist

    meta = {
      description = "Asynchronous Python library for the Panasonic Comfort Cloud API";
      homepage = "https://github.com/sockless-coding/aio-panasonic-comfort-cloud";
      license = pkgs.lib.licenses.mit;
    };
  };
in
pkgs.buildHomeAssistantComponent rec {
  owner = "sockless-coding";
  domain = "panasonic_cc";
  version = "2026.8.7";

  src = pkgs.fetchFromGitHub {
    owner = "sockless-coding";
    repo = "panasonic_cc";
    tag = version;
    hash = "sha256-8mpZ4u4rDIEfvk6ffYvfS9xNxvz4ZnNHkPiCJb6uvzY=";
  };

  dependencies = [ aio-panasonic-comfort-cloud ];

  meta = {
    description = "Control Panasonic Comfort Cloud air conditioners and heat pumps";
    homepage = "https://github.com/sockless-coding/panasonic_cc";
    license = pkgs.lib.licenses.mit;
  };
}
