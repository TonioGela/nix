Refactor the config
install polkit agent and a secret service agent
Import git config from HM
disko: partition order and names in content
VSCode UI state in hm
Configure Noctalia with HM
Configure calibre con HM
Power profile daemon, configure
Lanzaboote
Read niri documentation and rice it
Nixos wiki about niri mentions a few stuff
add secretservice, polkit and a polkit-agent
laptop things in nixos, like power management
optimise store
Set dark mode in system to tell apps to be dark in dconf

Remote builder
Document a bit all the TUIs to change settings
WayDroid per NOWTV

# USEFUL STUFF
gamemoderun gamescope -w 1440 -h 960 -W 2880 -H 1920 -F nis --adaptive-sync -f --mangoapp --force-grab-cursor -- %command%

SDL_VIDEODRIVER=wayland qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -drive file=nixos.img,format=qcow2 -device virtio-vga-gl -display sdl,gl=on
