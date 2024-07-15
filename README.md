
# Sparkler

Sparkler is a nix module for declarative modded minecraft servers.

Sparkler performs 3 primary functions:
- generates a container for a modded minecraft server, as a nix container.
- provides a way to host forge-based servers.
- provides a static site for the minecraft server that:
  - provides the server status (down, offline, online, etc)
  - provides a download for the current pack file
  - has optional modules for:
    - [create track map](https://modrinth.com/mod/create-track-map)

# Usage
Sparkler is intended to be used from within a system configuration:
```nix

sparkler.enable = true;
sparkler.passthru = {
  # global options for nix-minecraft: https://github.com/Infinidoge/nix-minecraft
  # ...
};
sparkler.servers.myMinecraftServer = {
    packFile = "/where/is/the/pack/file";

    passthru = {
      # server-specific options for nix-minecraft: https://github.com/Infinidoge/nix-minecraft
      # ...
    };

    server.forge = {
      enable = true;

      version = "47.2.17";          # used for checks and validations
      minecraftVersion = "1.20.1";  # used for checks and validations

      url = "...";
      sha512 = "...";
    };

    # settings for sparkler servers' web portals
    webPortal = {
      enable = true;
      port = 8080;
      staticfilesDir = "/";

      # not yet in use
      # features = [ ];
    };

    ports.enable = true;

    # explicit port definitions
    ports.udp = [
      25565  # default minecraft server port
      25575  # default minecraft rcon port
      24454  # default simple-voice-chat port
       3876  # default create-track-map port
    ];
};

```

