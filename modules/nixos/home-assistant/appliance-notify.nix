# "The washing is done": one automation per appliance that has someone to tell.
#
# Both halves are already declared elsewhere -- hass.dashboard.appliances knows
# the status entity, hass.ringPhone.targets knows the phones -- so this only
# joins them up. The trigger leaves `running` for one of the finished states,
# which is what keeps an appliance coming back from `unavailable` from claiming
# it has just finished a wash.
{
  config,
  lib,
  ...
}:
let
  appliances = lib.filter (a: a.notify != [ ]) (lib.attrValues config.hass.dashboard.appliances);
  phones = config.hass.ringPhone.targets;

  automation = appliance: {
    alias = "${appliance.title} finished";
    mode = "single";
    triggers = [
      {
        trigger = "state";
        entity_id = appliance.status;
        from = "running";
        to = appliance.finishedStates;
      }
    ];
    actions = map (key: {
      action = "notify.${lib.removePrefix "notify." phones.${key}.service}";
      data = {
        title = appliance.title;
        message = appliance.finishedMessage;
      };
    }) appliance.notify;
  };
in
{
  config = lib.mkIf (appliances != [ ]) {
    # A key that is not a phone would silently tell nobody.
    assertions = map (a: {
      assertion = lib.all (key: phones ? ${key}) a.notify;
      message = "hass.dashboard.appliances.${a.title}.notify: not all of ${toString a.notify} are keys of hass.ringPhone.targets.";
    }) appliances;

    services.home-assistant.config."automation manual" = map automation appliances;
  };
}
