{
  description = "OSLAB devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
  };

  outputs = { nixpkgs ,... }: let
    system = "aarch64-darwin";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in pkgs.mkShell {
      packages = with pkgs; [
          clang
          lldb
          qemu
          coreutils-prefixed
          cmake
          (python3.withPackages (python-pkgs: with python-pkgs; [
            pyyaml
          ]))
          (gnumake.overrideAttrs (oldAttrs: { configureFlags = oldAttrs.configureFlags ++ [ "--program-prefix=g" ]; }))
          (gnused.overrideAttrs { configureFlags = [ "--program-prefix=g" ]; })
          (gnugrep.overrideAttrs { 
            configureFlags = [ "--program-prefix=g" ]; 
            postInstall =
              ''
                echo "#! /bin/sh" > $out/bin/egrep
                echo "exec $out/bin/grep -E \"\$@\"" >> $out/bin/egrep
                echo "#! /bin/sh" > $out/bin/fgrep
                echo "exec $out/bin/grep -F \"\$@\"" >> $out/bin/fgrep
                chmod +x $out/bin/egrep $out/bin/fgrep
              '';  
          })
      ];

      shellHook = ''
        exec zsh
      '';
    };
  };
}
