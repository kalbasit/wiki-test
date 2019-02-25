let
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = builtins.fetchTarball {
    inherit (pinnedVersion) url sha256;
  };
in

# This allows overriding pkgs by passing `--arg pkgs ...`
{ pkgs ? import pinnedPkgs {}, lib ? pkgs.lib }:

with pkgs;
with lib;

mkShell {
  buildInputs = [
    # The ruby environment
    ruby.devEnv
  ];

  BUNDLE_BUILD__NOKOGIRI = builtins.concatStringsSep " " ([
    "--use-system-libraries"
    "--with-zlib-include=${getDev zlib}/include"
    "--with-zlib-lib=${getLib zlib}/lib"
    "--with-xml2-include=${getDev libxml2}/include/libxml2"
    "--with-xml2-lib=${getLib libxml2}/lib"
    "--with-xslt-include=${getDev libxslt}/include"
    "--with-xslt-lib=${getLib libxslt}/lib"
    "--with-exslt-include=${getDev libxslt}/include"
    "--with-exslt-lib=${getLib libxslt}/lib"
  ] ++ optionals stdenv.isDarwin [
    "--with-iconv-lib=${getLib libiconv}/lib"
    "--with-iconv-include=${getDev libiconv}/include"
  ]);
}
