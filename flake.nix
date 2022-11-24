{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-rebar3.url = "github:axelf4/nix-rebar3";
    nix-rebar3.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nix-rebar3 }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in rec {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.erlang
          pkgs.rebar3
        ];
      };
      packages.x86_64-linux.default =
        (pkgs.callPackage nix-rebar3 {}).buildRebar3 {
          root = ./.;
          pname = "notify_send_server";
          version = "0.1.0";
          releaseType = "release";
        };
      apps.x86_64-linux.default = {
        type = "app";
        program = let prog = pkgs.writeShellScriptBin "notify_send_server" "${packages.x86_64-linux.default}/bin/notify_send_server console";
                  in "${prog}/bin/notify_send_server";
      };
    };
}
