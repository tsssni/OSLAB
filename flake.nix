{
  description = "OSLAB devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    tsssni-nur = {
      url = "github:tsssni/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, tsssni-nur, ... }: let
    system = "aarch64-darwin";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
      tsssni-lib = tsssni-nur.lib;
      tsssni-pkgs = tsssni-nur.pkgs {
        localSystem = system;
      };
      aarch64-elf-pkgs = import nixpkgs {
        localSystem = system;
        crossSystem = tsssni-lib.systems.aarch64-elf;
      };
    in pkgs.mkShell {
      packages = []
        ++ (with pkgs; [
            clang
            lldb
            qemu
            coreutils-prefixed
            cmake
          ]) 
        ++ (with tsssni-pkgs.gnu; [
            ggrep
            gmake
            gsed
          ])
        ++ (with aarch64-elf-pkgs; [
            stdenv.cc
          ]);
      shellHook = ''
        # Because it’s getting called from a Darwin stdenv, aarch64-elf-cc will pick up on
        # Darwin-specific flags, and it will barf and die on -iframework in
        # particular. Strip them out, so simavr can compile its test firmware.
        cflagsFilter='s|-F[^ ]*||g;s|-iframework [^ ]*||g;s|-isystem [^ ]*||g;s|  *| |g'

        # The `CoreFoundation` reference is added by `linkSystemCoreFoundationFramework` in the
        # Apple SDK’s setup hook. Remove that because aarch64-elf-cc will fail due to file not found.
        ldFlagsFilter='s|/nix/store/[^-]*-apple-framework-CoreFoundation[^ ]*||g'

        # Make sure the global flags aren’t accidentally influencing the platform-specific flags.
        export NIX_CFLAGS_COMPILE="$(sed "$cflagsFilter" <<< "$NIX_CFLAGS_COMPILE")"
        export NIX_LDFLAGS="$(sed "$ldFlagsFilter;$cflagsFilter" <<< "$NIX_LDFLAGS")"

        exec zsh
      '';
    };
  };
}
