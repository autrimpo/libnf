{
  description = "C interface for processing nfdump files";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "nixpkgs/nixos-23.05";
  };

  outputs = {self, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = {
          nfdump = pkgs.nfdump.overrideAttrs (oa: rec {
            version = "1.6.25";
            src = pkgs.fetchFromGitHub {
              owner = "phaag";
              repo = "nfdump";
              rev = "v${version}";
              sha256 = "sha256-4MKoH0nrP/F7GQZxjxiqtA+3rXYNn6iA1DnoB+iq7e8=";
            };

            patches = [nix/nfdump/patches/lex.patch];
          });

          libnf = pkgs.stdenv.mkDerivation rec {
            pname = "libnf";
            version = "1.33";

            src = pkgs.fetchurl {
              url = "http://libnf.net/packages/libnf-${version}.tar.gz";
              sha256 = "sha256-FNQdr98u1vyQTu028wBik0nVRnG/JeONFpm6Z3TZqj8=";
            };

            buildInputs = self'.packages.nfdump.buildInputs;
            nativeBuildInputs = self'.packages.nfdump.nativeBuildInputs;

            dontDisableStatic = true;
          };

          default = self'.packages.libnf;
        };
      };
    };
}
