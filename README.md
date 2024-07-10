
# MRPack2Nix

Modrinth Pack (mrpack) 2 nix is a nix utility for generating a nixos container for
a modded minecraft server from a modrinth modpack profile.

# Usage
MRPack2Nix is intended to be used via flake:
`flake.nix`:
```nix
{
  description = "My modded minecraft server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.mrpack2nix.url = "github:MaxTheMooshroom/mrpack2nix";

  outputs = { self, nixpkgs, mrpack2nix, ... }@inputs: {
    imports = [ inputs.mrpack2nix.flakeModule ];
    systems = [ "x86_64-linux" ];

    mrpack2nix.my-server = mrpack2nix.mkModpack {
      # mrpack files are zips ; extract <pack>.mrpack/modrinth.index.json
      # and use that to generate the container. Use modids and their versions
      # to generate the hash for the container.
      pack = ./my-pack-1.0.2.mrpack;

      # if true, mrpack2nix will generate a eula.txt file with "eula=true",
      # otherwise errors
      eula = true;

      worldName = "my-world";  # gets added as a sparkler volume

      udpPorts = [
        55265  # server itself
        55275  # rcon port

        3876   # web server for viewing live create railway statuses
        24454  # simple voice chat
      ];

      serverProperties = {
        "motd" = "A wonderful minecraft server! :D";

        "level-name" = "world";
        # "level-seed" = "";
        "gamemode" = "survival";
        "difficulty" = "hard";

        "max-players" = 5;
        
        "enable-rcon" = true;
        "rcon.port" = 25575;
        "rcon.password" = "hunter2";

        # "enable-jmx-monitoring" = false;
        # "enable-command-block" = false;
        # "enable-query" = false;
        # "generator-settings" = "{}";
        # "enforce-secure-profile" = true;
        # "query.port" = 25565;
        # "pvp" = true;
        # "generate-structures" = true;
        # "max-chained-neighbor-updates" = 1000000;
        # "network-compression-threshold" = 256;
        # "max-tick-time" = 60000;
        # "require-resource-pack" = true;
        # "use-native-transport" = true;
        # "online-mode" = true;
        # "enable-status" = true;
        # "allow-flight" = false;
        # "initial-disabled-packs" = ;
        # "broadcast-rcon-to-ops" = true;
        # "view-distance" = 10;
        # "server-ip" = ;
        # "resource-pack-prompt" = ;
        # "allow-nether" = true;
        # "server-port" = 25565;
        # "sync-chunk-writes" = true;
        # "op-permission-level" = 4;
        # "prevent-proxy-connections" = false;
        # "hide-online-players" = false;
        # "resource-pack" = ;
        # "entity-broadcast-range-percentage" = 100;
        # "simulation-distance" = 10;
        # "player-idle-timeout" = 0;
        # "force-gamemode" = false;
        # "rate-limit" = 0;
        # "hardcore" = false;
        # "white-list" = false;
        # "broadcast-console-to-ops" = true;
        # "spawn-npcs" = true;
        # "spawn-animals" = true;
        # "log-ips" = true;
        # "function-permission-level" = 2;
        # "initial-enabled-packs" = vanilla;
        # "level-type" = minecraft\:normal;
        # "text-filtering-config" = ;
        # "spawn-monsters" = true;
        # "enforce-whitelist" = false;
        # "spawn-protection" = 16;
        # "resource-pack-sha1" = ;
        # "max-world-size" = 29999984;
      };
    };
  };
}
```

### See Also

- https://github.com/systemd/systemd/issues/30239
- https://github.com/systemd/systemd/pull/26826
