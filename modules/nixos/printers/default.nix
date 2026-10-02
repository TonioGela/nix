{ pkgs, ... }:
{

  # User must be in "lp" or "lpadmin" group
  services.printing = {
    enable = true;
    package = pkgs.cups;
    startWhenNeeded = true;
    webInterface = true;
    drivers = with pkgs; [
      cups-filters
      brlaser
    ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_DCP-1610W";
        deviceUri = "dnssd://Brother%20DCP-1610W%20series._printer._tcp.local/?uuid=e3248000-80ce-11db-8000-485f9971fd39";
        model = "drv:///brlaser.drv/br1610.ppd";
        ppdOptions = {
          # lpoptions -p Brother_DCP-1610W -l
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
          brlaserEconomode = "True";
          brlaserDensityAdjus = "103";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_DCP-1610W";
  };

  # User must be in "scanner" group
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];

  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "manage-printing";
      desktopName = "Printers";
      exec = "xdg-open http://localhost:631";
      icon = ./printer.svg;
    })
    pkgs.naps2
    # Trim whitespace around images, in place
    (pkgs.writeShellApplication {
      name = "imgtrim";
      runtimeInputs = [ pkgs.imagemagick ];
      text = ''
        [ $# -ge 1 ] || { echo "usage: imgtrim image..." >&2; exit 1; }
        magick mogrify -auto-orient -fuzz 10% -trim +repage "$@"
      '';
    })
    # Trim one or two images and fit them centered on one A4 page as a PDF:
    # 1cm page margin, 1cm gap between two images, both images at the same scale,
    # page orientation and layout (stacked / side by side) chosen to make them biggest.
    # Without --dpi the scanned pixels are kept as they are and the PDF density is derived.
    (pkgs.writeShellApplication {
      name = "img2a4";
      runtimeInputs = [ pkgs.imagemagick ];
      text = ''
        usage() { echo "usage: img2a4 [--dpi N] [-o out.pdf] image [image2]" >&2; exit 1; }
        dpi="" out="" imgs=()
        while [ $# -gt 0 ]; do
          case "$1" in
            --dpi) [ $# -ge 2 ] || usage; dpi="$2"; shift 2 ;;
            -o | --output) [ $# -ge 2 ] || usage; out="$2"; shift 2 ;;
            -h | --help) usage ;;
            *) imgs+=("$1"); shift ;;
          esac
        done
        n=''${#imgs[@]}
        { [ "$n" -ge 1 ] && [ "$n" -le 2 ]; } || usage
        out="''${out:-''${imgs[0]%.*}.pdf}"

        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        w=() h=()
        for i in "''${!imgs[@]}"; do
          magick "''${imgs[i]}" -auto-orient -fuzz 10% -trim +repage "$tmp/$i.png"
          read -r "w[$i]" "h[$i]" < <(magick identify -format '%w %h\n' "$tmp/$i.png")
        done

        # Lengths in mm; d = pixels per mm * 1e6 (bash has integer math only).
        # need CONTENT_PX AVAIL_MM -> d needed to fit
        need() { echo $((($1 * 1000000 + $2 - 1) / $2)); }
        max() { echo $(($1 > $2 ? $1 : $2)); }
        d=0
        for page in "210 297" "297 210"; do
          read -r pw ph <<<"$page"
          if [ "$n" -eq 1 ]; then
            opts=("single $(max "$(need "''${w[0]}" $((pw - 20)))" "$(need "''${h[0]}" $((ph - 20)))")")
          else
            mw=$(max "''${w[0]}" "''${w[1]}") mh=$(max "''${h[0]}" "''${h[1]}")
            opts=(
              "stack $(max "$(need "$mw" $((pw - 20)))" "$(need $((h[0] + h[1])) $((ph - 30)))")"
              "side $(max "$(need $((w[0] + w[1])) $((pw - 30)))" "$(need "$mh" $((ph - 20)))")"
            )
          fi
          for o in "''${opts[@]}"; do
            read -r l c <<<"$o"
            if [ "$d" -eq 0 ] || [ "$c" -lt "$d" ]; then d=$c layout=$l W=$pw H=$ph; fi
          done
        done

        px() { echo $((($1 * d + 500000) / 1000000)); }
        gap=$(px 10)
        case "$layout" in
          single) args=("$tmp/0.png") ;;
          stack) args=("$tmp/0.png" -size "1x$gap" xc:white "$tmp/1.png" -append) ;;
          side) args=("$tmp/0.png" -size "''${gap}x1" xc:white "$tmp/1.png" +append) ;;
        esac
        if [ -n "$dpi" ]; then
          res=(-resize "$(((W * dpi * 10 + 127) / 254))x$(((H * dpi * 10 + 127) / 254))!"
            -units PixelsPerInch -density "$dpi")
        else
          res=(-units PixelsPerCentimeter -density "$((d / 100000)).$(printf %05d $((d % 100000)))")
        fi
        magick -background white -gravity center "''${args[@]}" \
          -extent "$(px "$W")x$(px "$H")" -repage "$(px "$W")x$(px "$H")+0+0" "''${res[@]}" "$out"
        echo "$out"
      '';
    })
  ];

  # TODO Consider re-enabling this after 26.05
  # hardware.sane.brscan4.enable = true;
  # hardware.sane.brscan4.netDevices = {
  #   Brother_DCP-1610W = {
  #     model = "Brother_DCP-1610W";
  #     # http://BRN485F9971FD39.local/
  #     nodename = "BRN485F9971FD39"; # avahi-browse -art | grep -i brother
  #   };
  # };

  # systemd.tmpfiles.rules = [
  #   "L+ /opt/brother/scanner/brscan4 - - - - ${pkgs.brscan4}/opt/brother/scanner/brscan4"
  # ];
}
