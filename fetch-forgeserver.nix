{
  pkgs,
  lib,
  forgeVersion,
  minecraftVersion,
  ...
}:
let
  versionLong = "${minecraftVersion}-${forgeVersion}";
  forgeInstaller = pkgs.runCommand "fetchForgeMinecraft-${versionLong}" { buildInputs = [ pkgs.wget ]; } ''
    mkdir -p $out
    cd $out
    wget -q "https://maven.minecraftforge.net/net/minecraftforge/forge/${versionLong}/forge-${versionLong}-installer.jar" -O forge-${versionLong}-installer.jar
  '';
in pkgs.runCommand "gen-forgeInstallerOffline-${versionLong}" { buildInputs = [ pkgs.openjdk17-bootstrap ]; } ''
  mkdir -p $out
  java -jar ${forgeInstaller.out}/forge-${versionLong}-installer.jar --installServer $out
''