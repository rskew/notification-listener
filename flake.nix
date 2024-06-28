{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in {
        devShells.x86_64-linux.default = pkgs.mkShell {
          # keep your shell history in iex
          ERL_FLAGS = "-kernel shell_history enabled";

          buildInputs = [
            pkgs.elixir
            pkgs.elixir-ls
            pkgs.inotify-tools
            pkgs.mix2nix
          ];
          shellHook = ''
            cat << EOF
              Fetch elixir deps
                  mix deps.get

              Start the server:
                  iex -S mix

              Send test notification:
                  nix run .#notify localhost '["hello", "there", false]'

              Update dependencies:
                  mix2nix > mix_deps.nix
            EOF
          '';
        };

        packages.x86_64-linux.notify = pkgs.writeShellScriptBin "notify" ''
          HOST="''${1:-localhost}"
          MESSAGE="''${2:-[\"hello\",\"\"]}"
          echo -n "$MESSAGE" | ${pkgs.netcat-gnu}/bin/netcat -cu "$HOST" 2001
        '';

        packages.x86_64-linux.server =
          let release = pkgs.beamPackages.mixRelease {
                pname = "notify_send_server";
                version = "0.0.1";
                src = pkgs.runCommand "src" {} ''
                  mkdir $out
                  cp ${./mix.exs} $out/mix.exs
                  cp ${./mix.lock} $out/mix.lock
                  cp -r ${./lib} $out/lib
                '';
                mixNixDeps = with pkgs; import ./mix_deps.nix { inherit lib beamPackages; };
              };
          in pkgs.writeShellApplication {
               name = "notify-send-server";
               runtimeInputs = [ pkgs.libnotify pkgs.dbus ];
               text = "ERL_FLAGS='-kernel shell_history enabled' RELEASE_COOKIE=hi ${release}/bin/notify_send_server start";
             };
      };
}
