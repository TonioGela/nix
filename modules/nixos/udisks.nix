{
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  # MTP for Android phones, used by the yazi gvfs plugin
  services.gvfs.enable = true;
}
