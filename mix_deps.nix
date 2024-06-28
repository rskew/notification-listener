{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    json = buildMix rec {
      name = "json";
      version = "1.4.1";

      src = fetchHex {
        pkg = "json";
        version = "${version}";
        sha256 = "9abf218dbe4ea4fcb875e087d5f904ef263d012ee5ed21d46e9dbca63f053d16";
      };

      beamDeps = [];
    };
  };
in self

