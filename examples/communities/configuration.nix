{
  imports = [ ../../sparkler.nix ];

  services.sparkler = {
    enable = true;

    passthru = {

    };

    servers.communities = {
      packFile = "./communities-0.1.1.mrpack";
      server.forge.enable = true;

      ports.bhgfgvwehgwe = [];
      ports.udp = [ 25565 255575 24454 3876 8080 ];
      ports.tcp = [ ];

      passthru = {

      };

      webPortal = {
        enable = true;
        port = 8080;
        staticFiles = "./static";
      };
    };
  };
}