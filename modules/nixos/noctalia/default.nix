{ sources, ... }:
{
  # This conflicts with noctalia automatically calling fprintd
  security.pam.services.login.fprintAuth = false;

  home-manager.sharedModules = [
    sources.noctalia5.homeModule
    (
      { pkgs, ... }:
      {
        home.file.".config/face.jpg".source = ./avatar.jpg;
        home.file.".config/wallpaper.png".source = pkgs.runCommand "wallpaper.png" {
          nativeBuildInputs = [ pkgs.librsvg ];
        } "rsvg-convert -w 4096 -h 4096 -o $out ${./wallpaper.svg}";
      }
    )
    {
      programs.noctalia = {
        enable = true;

        settings = {
          accessibility = {
            high_contrast = false;
            ui_scale = 1.0;
          };

          audio = {
            enable_overdrive = false;
            enable_sounds = false;
            notification_sound = "";
            sound_volume = 0.5;
            volume_change_sound = "";
          };

          backdrop = {
            blur_intensity = 0.5;
            enabled = false;
            tint_intensity = 0.3;
          };

          bar = {
            order = [ "default" ];

            default = {
              auto_hide = true;
              start = [
                "control-center"
              ];
              center = [
                "bar"
                "clock"
                "battery"
              ];
              end = [
                "notifications"
                "tray"
              ];
              background_opacity = 1.0;
              border = "tertiary";
              border_width = 1.0;
              capsule = false;
              capsule_fill = "surface_variant";
              capsule_group = [ ];
              capsule_opacity = 1.0;
              capsule_padding = 6.0;
              capsule_thickness = 0.76;
              concave_edge_corners = false;
              contact_shadow = false;
              enabled = true;
              font_family = "SauceCodePro Nerd Font Mono";
              font_scale = 1.0;
              font_weight = 500;
              hover_highlight = true;
              layer = "overlay";
              margin_edge = 4;
              margin_ends = 100;
              margin_opposite_edge = 0;
              padding = 14;
              panel_overlap = 0;
              position = "top";
              radius = 12;
              radius_bottom_left = 12;
              radius_bottom_right = 12;
              radius_top_left = 12;
              radius_top_right = 12;
              reserve_space = false;
              scale = 1.0;
              shadow = false;
              show_on_workspace_switch = false;
              smart_auto_hide = false;
              thickness = 35;
              widget_spacing = 10;
              dead_zone.actions.right = "none";
            };
          };

          battery.warning_threshold = 10;

          brightness = {
            enable_ddcutil = false;
            ignore_mmids = [ ];
            minimum_brightness = 0.0;
            sync_all_monitors = false;
          };

          calendar = {
            enabled = true;
            refresh_minutes = 15;

            account.personal_google = {
              calendars = [ ];
              color = "";
              credential_source = "secret-service";
              name = "";
              password_file = "";
              provider = "";
              server_url = "";
              type = "google";
              username = "";
            };
          };

          control_center = {
            hidden_tabs = [
              "media"
              "monitor"
              "weather"
              "calendar"
              "notifications"
            ];
            show_session_button = false;
            show_shortcut_labels = false;
            sidebar = "compact";
            sidebar_section = "none";
            width = 700;

            calendar = {
              event_date_format = "%A %e %B";
              event_time_format = "%H:%M";
              show_events_card = true;
              show_week_numbers = false;
            };

            shortcuts = [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "audio"; }
              { type = "power_profile"; }
              { type = "caffeine"; }
              { type = "session"; }
            ];
          };

          desktop_widgets = {
            enabled = false;
            schema_version = 2;

            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
          };

          dock = {
            active_monitor_only = false;
            active_opacity = 1.0;
            active_scale = 1.0;
            auto_hide = false;
            background_opacity = 0.88;
            border = "outline";
            border_width = 0.0;
            concave_edge_corners = true;
            cross_axis_padding = 8;
            enabled = false;
            icon_size = 48;
            inactive_opacity = 0.85;
            inactive_scale = 0.85;
            item_spacing = 6;
            launcher_custom_image = "";
            launcher_custom_image_colorize = false;
            launcher_icon = "grid-dots";
            launcher_position = "none";
            layer = "top";
            magnification = true;
            magnification_scale = 1.45;
            main_axis_padding = 16;
            margin_edge = 0;
            margin_ends = 0;
            monitors = [ ];
            pinned = [ ];
            position = "bottom";
            radius = 16;
            radius_bottom_left = 16;
            radius_bottom_right = 16;
            radius_top_left = 16;
            radius_top_right = 16;
            reserve_space = true;
            shadow = true;
            show_dots = false;
            show_instance_count = true;
            show_running = true;
            smart_auto_hide = false;
          };

          hooks = {
            battery_charging = [ ];
            battery_discharging = [ ];
            battery_percentage_changed = [ ];
            battery_plugged = [ ];
            bluetooth_disabled = [ ];
            bluetooth_enabled = [ ];
            colors_changed = [ ];
            logging_out = [ ];
            power_profile_changed = [ ];
            rebooting = [ ];
            session_locked = [ ];
            session_unlocked = [ ];
            shutting_down = [ ];
            started = [ ];
            theme_mode_changed = [ ];
            wallpaper_changed = [ ];
            wifi_disabled = [ ];
            wifi_enabled = [ ];
          };

          hot_corners = {
            delay_ms = 0;
            enabled = false;

            bottom_left = {
              action = "none";
              command = "";
            };
            bottom_right = {
              action = "none";
              command = "";
            };
            top_left = {
              action = "none";
              command = "";
            };
            top_right = {
              action = "none";
              command = "";
            };
          };

          idle = {
            behavior_order = [
              "lock"
              "screen-off"
              "lock-and-suspend"
            ];
            pre_action_fade_seconds = 2.0;

            behavior = {
              lock = {
                action = "lock";
                command = "";
                enabled = true;
                locked_timeout = 0.0;
                resume_command = "";
                timeout = 60.0;
              };
              lock-and-suspend = {
                action = "lock_and_suspend";
                command = "";
                enabled = true;
                locked_timeout = 0.0;
                resume_command = "";
                timeout = 900.0;
              };
              screen-off = {
                action = "screen_off";
                command = "";
                enabled = true;
                locked_timeout = 60.0;
                resume_command = "";
                timeout = 0.0;
              };
            };
          };

          keybinds = {
            cancel = [ "Escape" ];
            copy = [ "Ctrl+c" ];
            delete = [ "Delete" ];
            down = [ "Down" ];
            left = [ "Left" ];
            right = [ "Right" ];
            save = [ "Ctrl+s" ];
            tab_next = [ "Tab" ];
            tab_previous = [ "Shift+ISO_Left_Tab" ];
            up = [ "Up" ];
            validate = [
              "Return"
              "KP_Enter"
              "space"
            ];
          };

          location = {
            address = "Milano, Italy";
            auto_locate = false;
            custom_schedule = false;
            sunrise = "";
            sunset = "";
          };

          lockscreen = {
            allow_empty_password = false;
            blur_intensity = 0.2;
            blurred_desktop = false;
            enabled = true;
            fingerprint = true;
            lock_before_suspend = true;
            monitors = [ ];
            tint_intensity = 0.0;
            wallpaper = "";
          };

          lockscreen_widgets = {
            enabled = true;
            schema_version = 2;
            widget_order = [ "lockscreen-login-box@eDP-1" ];

            grid = {
              cell_size = 8;
              major_interval = 4;
              visible = true;
            };

            widget."lockscreen-login-box@eDP-1" = {
              box_height = 70.0;
              box_width = 400.0;
              cx = 720.0;
              cy = 784.0;
              enabled = true;
              output = "eDP-1";
              placement_height = 960.0;
              placement_width = 1440.0;
              rotation = 0.0;
              type = "login_box";

              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = true;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "compact";
                show_caps_lock = false;
                show_keyboard_layout = false;
                show_login_button = false;
                show_media = false;
                show_session_buttons = true;
                show_unlock_hint = false;
                show_weather = false;
              };
            };
          };

          nightlight = {
            enabled = false;
            force = false;
            temperature_day = 6500;
            temperature_night = 4000;
          };

          notification = {
            background_opacity = 0.97;
            border = true;
            collapse_on_dismiss = true;
            enable_daemon = true;
            history_retention_hours = 0;
            layer = "top";
            max_visible = 0;
            monitors = [ ];
            offset_x = 20;
            offset_y = 8;
            position = "top_right";
            scale = 1.0;
            show_actions = true;
            show_app_name = true;
          };

          osd = {
            background_opacity = 1.0;
            border = true;
            enabled = true;
            monitors = [ ];
            offset_x = 20;
            offset_y = 8;
            orientation = "horizontal";
            position = "top_center";
            position_vertical = "top_center";
            scale = 1.0;

            kinds = {
              bluetooth = true;
              brightness = true;
              caffeine = true;
              dnd = true;
              keyboard_backlight = true;
              keyboard_layout = true;
              lock_keys = false;
              media = true;
              nightlight = true;
              power_profile = true;
              privacy = true;
              volume = true;
              volume_input = true;
              volume_output = true;
              wifi = true;
            };
          };

          plugin_settings = { };

          plugins = {
            auto_update = "all";
            enabled = [
              "rylos/tailnet"
              "aristides/udiskie"
              "emrtnn/pass"
            ];

            source = [
              {
                enabled = true;
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
                name = "official";
              }
              {
                enabled = true;
                kind = "git";
                location = "https://github.com/noctalia-dev/community-plugins";
                name = "community";
              }
            ];
          };

          shell = {
            app_icon_color = "primary";
            app_icon_colorize = false;
            avatar_path = "/home/toniogela/.config/face.jpg";
            button_borders = false;
            card_borders = false;
            clipboard_auto_paste = "auto";
            clipboard_confirm_clear_history = true;
            clipboard_enabled = true;
            clipboard_history_max_entries = 100;
            clipboard_image_action_command = "";
            clipboard_keep_from_closed_apps = true;
            corner_radius_scale = 1.0;
            date_format = "%A, %x";
            disable_mipmaps = false;
            external_ip_enabled = false;
            font_family = "SauceCodePro Nerd Font Mono";
            input_borders = false;
            lang = "en";
            launch_apps_as_systemd_services = false;
            launch_apps_custom_command = "";
            niri_overview_type_to_launch_enabled = false;
            offline_mode = false;
            password_style = "random";
            polkit_agent = true;
            popup_borders = false;
            popup_shadows = false;
            screen_time_enabled = false;
            settings_show_advanced = true;
            settings_window_translucent = false;
            setup_wizard_enabled = true;
            shared_gl_context = true;
            show_location = true;
            telemetry_enabled = false;
            time_format = "{:%H:%M}";

            animation = {
              enabled = true;
              speed = 1.0;
            };

            greeter_sync.auto_sync = false;

            keyboard_layout = { };

            launcher = {
              app_grid = false;
              auto_paste = "auto";
              categories = false;
              compact = true;
              fetch_exchange_rates = false;
              pinned = [ ];
              provider_prefix = "/";
              show_app_actions = false;
              show_app_origin_indicator = false;
              show_icons = true;
              sort_by_usage = true;

              dmenu = { };
            };

            mpris.blacklist = [ ];

            panel = {
              borders = true;
              clipboard_placement = "floating";
              clipboard_position = "center";
              control_center_placement = "floating";
              control_center_position = "auto";
              floating_layer = "overlay";
              floating_offset = 8;
              launcher_placement = "floating";
              launcher_position = "center";
              list_item_background = false;
              open_near_click_clipboard = false;
              open_near_click_control_center = true;
              open_near_click_launcher = false;
              open_near_click_session = false;
              open_near_click_wallpaper = false;
              polkit_placement = "floating";
              polkit_position = "center";
              session_placement = "floating";
              session_position = "center";
              shadow = true;
              transparency_mode = "solid";
              wallpaper_placement = "attached";
              wallpaper_position = "auto";
            };

            privacy = {
              cam_filter_regex = "";
              mic_filter_regex = "";
              screen_filter_regex = "";
            };

            screen_corners = {
              enabled = true;
              size = 32;
            };

            screenshot = {
              confirm_region = false;
              copy_to_clipboard = true;
              directory = "";
              filename_pattern = "";
              freeze_screen = true;
              pipe_command = "";
              pipe_to_command = false;
              remember_last_region = false;
              save_to_file = true;
              show_cursor = false;
            };

            session = {
              grid = false;
              grid_columns = 2;
              show_shortcuts = false;

              power = { };

              actions = [
                {
                  action = "lock";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "1";
                  variant = "default";
                }
                {
                  action = "lock_and_suspend";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "zzz";
                  label = "";
                  shortcut = "2";
                  variant = "default";
                }
                {
                  action = "reboot";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "3";
                  variant = "default";
                }
                {
                  action = "shutdown";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = true;
                  glyph = "";
                  label = "";
                  shortcut = "4";
                  variant = "destructive";
                }
                {
                  action = "logout";
                  command = "";
                  countdown_seconds = 0.0;
                  enabled = false;
                  glyph = "";
                  label = "";
                  shortcut = "5";
                  variant = "default";
                }
              ];
            };

            shadow = {
              alpha = 0.0;
              direction = "center";
            };
          };

          storage = {
            key_file = "";
            key_source = "secret-service";
          };

          system.monitor = {
            cpu_freq_activity_threshold = 2.5;
            cpu_freq_critical_threshold = 4.5;
            cpu_poll_seconds = 2.0;
            cpu_temp_activity_threshold = 60.0;
            cpu_temp_critical_threshold = 85.0;
            cpu_temp_sensor_path = "";
            cpu_usage_activity_threshold = 50.0;
            cpu_usage_critical_threshold = 90.0;
            disk_free_activity_threshold = 80.0;
            disk_free_critical_threshold = 95.0;
            disk_free_pct_activity_threshold = 80.0;
            disk_free_pct_critical_threshold = 95.0;
            disk_poll_seconds = 10.0;
            disk_used_activity_threshold = 80.0;
            disk_used_critical_threshold = 95.0;
            disk_used_pct_activity_threshold = 80.0;
            disk_used_pct_critical_threshold = 95.0;
            enabled = false;
            gpu_poll_seconds = 5.0;
            gpu_temp_activity_threshold = 60.0;
            gpu_temp_critical_threshold = 85.0;
            gpu_usage_activity_threshold = 50.0;
            gpu_usage_critical_threshold = 95.0;
            gpu_vram_activity_threshold = 50.0;
            gpu_vram_critical_threshold = 90.0;
            memory_poll_seconds = 2.0;
            net_rx_activity_threshold = 1.0;
            net_rx_critical_threshold = 50.0;
            net_tx_activity_threshold = 1.0;
            net_tx_critical_threshold = 50.0;
            network_poll_seconds = 3.0;
            ram_pct_activity_threshold = 60.0;
            ram_pct_critical_threshold = 90.0;
            swap_pct_activity_threshold = 20.0;
            swap_pct_critical_threshold = 80.0;
          };

          theme = {
            builtin = "Nord";
            community_palette = "Oxocarbon";
            custom_palette = "";
            mode = "dark";
            pure_black_dark = false;
            source = "builtin";
            wallpaper_scheme = "m3-content";

            templates = {
              builtin_ids = [ ];
              community_ids = [ "neovim" ];
              enable_builtin_templates = true;
              enable_community_templates = true;
            };
          };

          wallpaper = {
            directory = "/home/toniogela/.config";
            default.path = "/home/toniogela/.config/wallpaper.png";
            directory_dark = "";
            directory_light = "";
            edge_smoothness = 0.3;
            enabled = true;
            fill_color = "";
            fill_mode = "crop";
            per_monitor_directories = false;
            transition = [ ];
            transition_duration = 1500.0;
            transition_on_startup = false;

            automation = {
              enabled = false;
              interval_seconds = 1800;
              order = "random";
              recursive = true;
            };
          };

          weather = {
            effects = true;
            enabled = true;
            refresh_minutes = 30;
            unit = "metric";
          };

          widget = {
            active_window = {
              icon_size = 14.0;
              max_length = 260.0;
              min_length = 80.0;
              title_scroll = "none";
              type = "active_window";
            };

            bar = {
              show_count = false;
              type = "rylos/tailnet:bar";
            };

            battery = {
              hide_when_full = true;
              hide_when_plugged = true;
              show_label = false;
              type = "battery";
            };

            brightness = {
              show_label = false;
              type = "brightness";
            };

            clock = {
              anchor = true;
              type = "clock";
            };

            control-center = {
              custom_image = "/home/toniogela/Pictures/nixos-logo-black.png";
              custom_image_colorize = true;
              type = "control-center";
            };

            cpu = {
              stat = "cpu_usage";
              type = "sysmon";
            };

            date = {
              format = "{:%a %d %b}";
              type = "clock";
            };

            input_volume = {
              device = "input";
              type = "volume";
            };

            keyboard_layout = {
              hide_when_single_layout = false;
              type = "keyboard_layout";
            };

            lock_keys = {
              display = "short";
              hide_when_off = false;
              show_caps_lock = true;
              show_num_lock = true;
              show_scroll_lock = false;
              type = "lock_keys";
            };

            media = {
              art_size = 16.0;
              max_length = 220.0;
              min_length = 80.0;
              title_scroll = "none";
              type = "media";
            };

            network = {
              show_label = false;
              type = "network";
            };

            network_rx = {
              stat = "net_rx";
              type = "sysmon";
            };

            network_tx = {
              stat = "net_tx";
              type = "sysmon";
            };

            notifications = {
              hide_when_no_unread = true;
              type = "notifications";
            };

            output_volume = {
              device = "output";
              type = "volume";
            };

            ram = {
              stat = "ram_used";
              type = "sysmon";
            };

            spacer = {
              interactive = false;
              type = "spacer";
            };

            temp = {
              stat = "cpu_temp";
              type = "sysmon";
            };

            volume = {
              show_label = false;
              type = "volume";
            };
          };
        };
      };
    }
  ];
}
