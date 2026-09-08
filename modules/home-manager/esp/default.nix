{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
{
  options.esp.rust = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Install the bare-metal Rust toolchain for the RISC-V ESP32 parts
      (C3/C6/H2). Deliberately NOT for the ESP8266: its Xtensa LX106 core needs
      a forked rustc, and esp-rs/esp8266-hal was archived and declared dead in
      February 2024. The ESP32-C3 is pin-compatible with the ESP8266 and is the
      supported way to run Rust on this footprint.
    '';
  };

  config = {
    home.packages = [
      # Firmware-from-YAML. The nixpkgs build wraps platformio in an FHS env,
      # which is what makes the xtensa toolchain it downloads at first compile
      # actually runnable on NixOS. That platformio stays private to esphome:
      # it is on the wrapper's PATH, not on the shell's.
      pkgsUnstable.esphome

      # Bootloader-level access: identify the chip, read the real flash size,
      # wipe a board that got itself into a boot loop.
      pkgsUnstable.esptool

      # Serial monitor. `esphome logs` covers ESPHome devices; tio is for
      # everything else, and for watching a board that no longer talks ESPHome.
      pkgs.tio
    ]
    ++ lib.optionals config.esp.rust [
      pkgsUnstable.espflash # flash + serial monitor for Rust firmware
      pkgs.esp-generate # scaffolds an esp-hal project
      pkgs.rustup # nixpkgs ships no bare-metal rust-std; rustup does
    ];

    # Schema-aware completion and validation for ESPHome YAML. open-vsx carries
    # 2025.7.0; the marketplace copy is stuck on 2022.5.3.
    programs.vscodium.profiles.default.extensions = lib.mkIf config.programs.vscodium.enable [
      pkgs.open-vsx.esphome.esphome-vscode
    ];
  };
}
