{
  description = "A dev shell flake for personal karabiner configuration building";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nodejs_20
        ];

        # Nix store is immutable so NPM global install won't work
        shellHook = ''
          npm install -D ts-node typescript
          alias ts-node="npx ts-node"
          alias tsc="npx tsc"
          echo "Run ts-node config.ts to build karabiner configuration"
        '';
      };
    };
}