{ pkgs, ... }:
{
  home.packages = [ pkgs.calibre ];

  xdg.desktopEntries = {
    calibre-ebook-edit = {
      name = "E-book editor";
      noDisplay = true;
    };
    calibre-ebook-viewer = {
      name = "E=book viewer";
      noDisplay = true;
    };
    calibre-lrfviewer = {
      name = "LRF viewer";
      noDisplay = true;
    };
  };
}
