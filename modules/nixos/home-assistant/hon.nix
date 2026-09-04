# Haier hOn integration, not packaged in nixpkgs.
#
# Haier, Candy and Hoover are all the same group and all talk to the same
# "hOn" cloud API, so this single component covers both the Haier washing
# machine and the Candy dryer.
#
# Andre0512/hon is unmaintained; mmalolepszy/hon-revived is the fork that
# still gets releases, and it renamed the pypi library to pyhon-revived
# (the python module is still called `pyhon`).
{ pkgs }:
let
  # Custom components have to build against home-assistant's own python
  # package set, otherwise conflicting versions end up in the environment.
  ps = pkgs.home-assistant.python3Packages;

  pyhon-revived = ps.buildPythonPackage rec {
    pname = "pyhon-revived";
    version = "0.19.2";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "pyhon_revived";
      inherit version;
      hash = "sha256-CT4d1HkBrNk6ObxHvLoUG7NG1KEniZ5H3k5uQI2SdDc=";
    };

    build-system = [ ps.setuptools ];

    dependencies = with ps; [
      aiohttp
      awsiotsdk
      typing-extensions
      yarl
    ];

    pythonImportsCheck = [ "pyhon" ];
    doCheck = false; # no tests shipped in the sdist

    meta = {
      description = "Control hOn devices with python";
      homepage = "https://github.com/mmalolepszy/pyhon-revived";
      license = pkgs.lib.licenses.mit;
    };
  };
in
pkgs.buildHomeAssistantComponent rec {
  owner = "mmalolepszy";
  domain = "hon";
  version = "0.19.2";

  src = pkgs.fetchFromGitHub {
    owner = "mmalolepszy";
    repo = "hon-revived";
    tag = "v${version}";
    hash = "sha256-yTfSLQ8vQSONBpUqOhH+kEI79SnFB1hQjrqqTv2b83o=";
  };

  dependencies = [ pyhon-revived ];

  meta = {
    description = "Home Assistant integration for Haier/Candy/Hoover appliances via the hOn cloud";
    homepage = "https://github.com/mmalolepszy/hon-revived";
    license = pkgs.lib.licenses.mit;
  };
}
