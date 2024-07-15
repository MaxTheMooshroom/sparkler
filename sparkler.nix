{ config, lib, pkgs, ... }:
let
  cfg = config.sparkler;
  nix-minecraft = import (pkgs.fetchFromGithub {
    owner = "Infinidoge";
    repo = "nix-minecraft";
    rev = "...";
    sha256 = "...";
  });
  types = lib.types;
  submodule = (submod: types.submodule { options = submod; });
  submoduleByNames = (submod:
    types.attrsOf (types.submodule { options = submod; })
  );
in {
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  options = {
    sparkler = {
      enable = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Enable the use of sparkler";
      };

      passthru = lib.mkOption {
        type = types.attrs;
        default = {};
        description = ''
          The options to pass through to
          [nix-minecraft](https://github.com/Infinidoge/nix-minecraft).
        '';
      };

      servers = lib.mkOption {
        description = "A set of server instances";
        type = submoduleByNames {
          enable = lib.mkOption {
            type = types.bool;
            description = "Enable the server? (does not delete server data when false)";
          };

          server = lib.mkOption {
            description = "Options specific to the minecraft server";
            type = submodule {
              mrpack = lib.mkOption {
                type = types.string;
                description = "The path to the mrpack used by the server.";
              };

              forge = lib.mkOption {
                description = "A dirty hack for adding forge support to nix-minecraft";
                type = submodule {
                  enable = lib.mkOption {
                    type = types.bool;
                    default = false;
                    description = "Enable forge support.";
                  };

                  # url = lib.mkOption {
                  #   type = types.string;
                  #   description = "The URL for downloading the forge server jar.";
                  # };

                  # sha512 = lib.mkOption {
                  #   type = types.string;
                  #   description = "The forge server's hash.";
                  # };
                };
              };
            };
          };

          ports = lib.mkOption {
            description = "Options related to ports for the server instance.";
            type = submodule {
              udp = lib.mkOption {
                type = types.listOf types.port;
                default = [ 25565 25575 ];
                description = "List of UDP ports to allow access to.";
              };

              tcp = lib.mkOption {
                type = types.listOf types.port;
                default = [ ];
                description = "List of TCP ports to allow access to.";
              };
            };
          };

          webPortal = lib.mkOption {
            description = "Options related to the web portal for the server instance.";
            type = submodule {
              enable = lib.mkOption {
                type = types.bool;
                default = true;
                description = "Enable the web portal (default false)";
              };

              port = lib.mkOption {
                type = types.port;
                default = 8080;
                description = "Port that gets used by the web portal.";
              };

              passthru = lib.mkOption {
                type = types.attrs;
                default = {};
                description = ''
                  The options to pass through to [nginx](https://nixos.wiki/wiki/Nginx).
                '';
              };

              features = lib.mkOption {
                type = types.listOf (types.enum [ ]);
                default = [ ];
                description = "TODO";
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      inherit (cfg.passthru);

      enable = true;
      openFirewall = false;

      servers = lib.attrsets.mapAttrs (serverName: serverOptions:
      let
        pack = (import ./fetch-mrpack.nix) {
          inherit pkgs;
          inherit lib;
          mrpackFile = serverOptions.mrpack;
        };
        forgeServer = (import ./fetch-forgeserver.nix) {
          inherit pkgs;
          inherit lib;
          minecraftVersion = pack.cfg.dependencies.minecraft;
          forgeVersion = pack.cfg.dependencies.forge;
        };
      in {
          inherit (serverOptions.passthru);

          symlinks.mods = pkgs.linkFarmFromDrvs "remotes" pack.remotes;
          files = [
            (pack.mrpack.out + "/overrides")
            forgeServer.out
          ];
        }
      ) cfg.servers;
    };

    services.nginx.virtualHosts = lib.attrsets.mapAttrs (serverName: serverOptions: {
      inherit (serverOptions.passthru);
      default = true;

      listen.port = serverOptions.webPortal.port;
    }) cfg.servers;

    networking.firewall = {
      allowedUDPPorts = lib.concatLists (lib.map (opts: opts.ports.udp) cfg.servers);
      allowedTCPPorts = lib.concatLists (lib.map (opts: opts.ports.tcp) cfg.servers);
    };
  };
}