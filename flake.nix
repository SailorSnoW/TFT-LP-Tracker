{
  description = "Flake for running a dev env and derivation of the TFT Tracker.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: 
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
    in
    {
      devShells = forAllSystems (system: 
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          buildInputs = [
            pkgs.elixir
            pkgs.erlang
          ];

          shellHook = ''
            mix local.hex --force
            mix local.rebar --force
            mix deps.get
          '';
        }
      );

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.stdenv.mkDerivation {
          pname = "tft-tracker-bot";
          version = "1.0.0";

          src = self;

          nativeBuildInputs = [ pkgs.elixir pkgs.erlang ];

          buildPhase = ''
            mix local.hex --force
            mix local.rebar --force
            mix deps.get
            mix compile
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp -r . $out/bin/
          '';

          meta = with pkgs.lib; {
            description = "TFT Tracker discord bot";
            license = licenses.mit;
            maintainers = [ maintainers.sailorsnow ];
          };
        }
      );

      nixosModules.tftTrackerBot = {

        options.services.tft-tracker-bot = {
          enable = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.bool;
            default = false;
            description = "Enable the TFT Tracker discord bot service";
          };

          redisHost = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.string;
            default = "127.0.0.1";
              description = "Address of the redis host server.";
          };

          redisPort = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.int;
            default = 6379;
            description = "Port on which the redis server run.";
          };

          riotApiKey = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.string;
            default = "";
            description = "RIOT API Key to request game data.";
          };

          discordToken = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.string;
            default = "";
            description = "Discord Bot Token to control your bot account.";
          };
        };

        config = { config, pkgs, lib, ... }: {
          services.redis.enable = true;

          environment.systemPackages = [ self.packages.${pkgs.system} ];

          systemd.services.tft-tracker-bot = {
            description = "TFT Tracker discord bot";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              WorkingDirectory = "${self.packages.${pkgs.system}}/bin";
              ExecStart = "${self.packages.${pkgs.system}}/bin/_build/prod/rel/tft_tracker/ebin/tft_tracker start";
              Restart = "always";
              User = "username";
              Environment = "MIX_ENV=dev";
            };
          };

          networking.firewall.allowedTCPPorts = [ config.services.tft-tracker-bot.port ];
        };
      };
    };
}
