{
  description = "Generate minimal Nix value inputs for flakes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.writeShellApplication {
            name = "nix-value";
            runtimeInputs = [ pkgs.nix ];
            text = builtins.readFile ./nix-value.sh;
          };

          nix-value = pkgs.writeShellApplication {
            name = "nix-value";
            runtimeInputs = [ pkgs.nix ];
            text = builtins.readFile ./nix-value.sh;
          };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.lib.getExe self.packages.${system}.nix-value}";
        };

        nix-value = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.lib.getExe self.packages.${system}.nix-value}";
        };
      });
    };
}
