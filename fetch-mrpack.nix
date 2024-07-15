{
  pkgs,
  lib,
  mrpackFile,
  ...
}:
let
  packFiles = pkgs.runCommand "unpack-mrpack" { buildInputs = [ pkgs.unzip ]; } ''
    mkdir -p $out
    unzip ${mrpackFile} -d $out
  '';
  cfg = builtins.fromJSON (builtins.readFile "${packFiles}/modrinth.index.json");
in {
  inherit cfg;
  remotes = lib.lists.forEach pack.files (data: fetchurl {
    pname = lib.strings.removePrefix "mods/" data.path;
    urls = data.downloads;
    sha512 = data.hashes.sha512;
    passthru = {
      env = data.env;
      fullPath = data.path;
    };
  });
  mrpack = packFiles;
}
  