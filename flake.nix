# nix run . -- console
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nix-rebar3.url = "github:axelf4/nix-rebar3";
    nix-rebar3.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-rebar3 }:
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
          pname = "notification-server";
          version = "0.1.0";
          releaseType = "release";
        };
      apps.x86_64-linux.default =
        let prog = pkgs.writeShellScript "run" "${packages.x86_64-linux.default}/bin/notify_send_server console";
        in { type = "app"; program = "${prog}"; };
      # NOTE This doesn't work, need to set some env vars for notify-send to work from a systemd service
      nixosModule =
        { lib, config, ... }:
        let
          cfg = config.services.notification-server;
        in {
          options.services.notification-server = {
            port = lib.mkOption {
              type = lib.types.int;
              default = 2001;
            };
            user = lib.mkOption {
              type = lib.types.str;
            };
          };
          config = {
            networking.firewall.allowedTCPPorts = [ cfg.port ];
            systemd.services.notification-server = {
              description = "";
              after = [ "network-pre.target" ];
              wants = [ "network-pre.target" ];
              wantedBy = [ "multi-user.target" ];
              path = [pkgs.gawk];
              serviceConfig = {
                User = cfg.user;
                Restart = "always";
                RestartSec = 10;
                StartLimitBurst = 8640;
                StartLimitIntervalSec = 86400;
                StartLimitInterval = 86400;
                ExecStart = "${packages.x86_64-linux.default}/bin/notify_send_server foreground";
              };
            };
          };
        };
    };
}
