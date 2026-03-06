{ sources, username, ... }:
let

  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
  modules = filterAttrs (key: value: value == "directory") (builtins.readDir ./.);
  modulesImports = map (m: import ./${m}) (builtins.attrNames modules);
in
{
  imports = [
    sources.homeManager
  ];

  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # You should fix the modules to be as shallow as possible and to install packages in global packages (the reason some stuff is installed but not available is this one)
  home-manager.users.${username} = {
    imports = modulesImports;
    _module.args = {
      pkgsUnstable = sources.pkgsUnstable;
    };
    # home.packages = [ ];
    # home.enableNixpkgsReleaseCheck = true;
    # home.file = {
    #   ".config/niri/config.kdl".source = ./dotfiles/niri.kdl;
    #   ".config/wallpaper.svg".source = ./dotfiles/wallpaper.svg;
    #   ".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
    #   "notes.md".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/notes.md;
    #   ".config/noctalia/settings.json".source =
    #     config.lib.file.mkOutOfStoreSymlink ./dotfiles/noctalia-settings.json;
    # };

    # services.swayidle = {
    #   enable = true;
    #   timeouts = [
    #     {
    #       timeout = 120;
    #       command = "${pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call lockScreen lock";
    #     }
    #     {
    #       timeout = 300;
    #       command = "${pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call sessionMenu lockAndSuspend";
    #     }
    #   ];
    #   events = [
    #     {
    #       event = "before-sleep";
    #       command = "${pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call lockScreen lock";
    #     }
    #   ];
    # };

    # programs.home-manager.enable = true;
    # home.stateVersion = "25.11";
  };
}
