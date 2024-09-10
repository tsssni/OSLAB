{
  description = "OSLAB devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    tsssni-nur = {
      url = "github:tsssni/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, tsssni-nur, ... }: let
    system = "aarch64-darwin";
  in {
    devShells."${system}".default = let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
      };
      tsssni-lib = tsssni-nur.lib;
      tsssni-cross = lib.mapAttrs (n: crossSystem: 
        import nixpkgs {
          inherit
            system
            crossSystem;
        }
      ) tsssni-lib.system.examples;
      tsssni-pkgs = tsssni-nur.packages.${system};
    in pkgs.mkShell {
      packages = []
        ++ 
        (with pkgs; [
          clang
          lldb
          qemu
          coreutils-prefixed
          cmake
          (python3.withPackages (python-pkgs: with python-pkgs; [
            pyyaml
          ]))
        ]) 
        ++ (with tsssni-pkgs; [
          ggrep
          gmake
          gsed
        ])
        ++ (with tsssni-cross.aarch64-elf; [
          stdenv.cc
        ]);
      shellHook = ''
        exec zsh
      '';
    };
  };
}
