{
  description = "Default flake for Ti84-CE Programs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    ce-program.url = "github:myclevorname/nix-calculators";
  };

  outputs = { self, nixpkgs, ce-program }: let
  ce_program_name = "RPN2ASM";
  ce_archived = true;
  ce_compressed = false;
  system = "x86_64-linux";
  cepkgs = ce-program.legacyPackages."${system}";
  pkgs = import nixpkgs { inherit system;};
  tilp = pkgs.stdenv.mkDerivation {
     name = "tilp";
     src = pkgs.fetchurl {
       url = "https://www.ticalc.org/pub/unix/tilp.tar.gz";
       sha256 = "1mww2pjzvlbnjp2z57qf465nilfjmqi451marhc9ikmvzpvk9a3b";
     };
     postUnpack = ''
     	sed -i -e '/AC_PATH_KDE/d' tilp2-1.18/configure.ac || die
        sed -i \
            -e 's/@[^@]*\(KDE\|QT\|KIO\)[^@]*@//g' \
            -e 's/@X_LDFLAGS@//g' \
            tilp2-1.18/src/Makefile.am || die
     '';
     nativeBuildInputs = with pkgs; [ autoreconfHook pkg-config intltool libtifiles2 libticalcs2 libticables2 libticonv gtk2 ];
     buildInputs = with pkgs; [ glib ];
  };
  in {
    devShells."${system}".default = pkgs.mkShell {
      packages = with pkgs; [ cepkgs.ce-toolchain gnumake cemu-ti man-pages tilp];
      shellHook = ''
        tmux rename-session "${ce_program_name}"
        tmux rename-window $EDITOR
        export CFLAGS=${cepkgs.ce-toolchain}/include:$CFLAGS
        exec nvim ./src
      '';
    };
    packages.x86_64-linux.default = let
      makefile = pkgs.writeText "" ''
# ----------------------------
# Makefile Options
# ----------------------------

NAME ?= ${ce_program_name}
DESCRIPTION ?= "Reverse Polish Notation"
COMPRESSED ?= ${if ce_compressed then "YES" else "NO"}
ARCHIVED ?= ${if ce_archived then "YES" else "NO"}

CFLAGS ?= -Wall -Wextra -Oz
CXXFLAGS ?= -Wall -Wextra -Oz

# ----------------------------

include $(shell cedev-config --makefile)
      '';
      in cepkgs.buildCEProgram {
      name = "${ce_program_name}";
      src = self;
      preBuild = ''
        cp ${makefile} ./makefile
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp bin/*.8xp $out/bin
      '';
    };
  };
}
