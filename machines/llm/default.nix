{ modules, ... }:
{
  imports = with modules.home-manager; [
    darwin
    llm-server
    nix-tools
    zsh
  ];

  home = {
    username = "toniogela";
    homeDirectory = "/Users/toniogela";
  };

  programs.nh = {
    nhFile = "/Users/toniogela/.config/nix/configuration.nix";
    nhAttrPath = "llm";
  };

  home.file.".hushlogin".text = "";
}
