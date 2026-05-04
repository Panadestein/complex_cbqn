{
  description = "Complex numbers support for BQN.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
      {
        packages = forAllSystems (system:
          let
            pkgs = import nixpkgs { inherit system; };
            nativeStdenv = pkgs.impureUseNativeOptimizations pkgs.stdenv;

            patchedBootstrap = pkgs.stdenv.mkDerivation {
              pname = "BQN";
              version = "complex";
              src = pkgs.fetchFromGitHub {
                owner = "mlochbaum";
                repo = "BQN";
                rev = "985fd110d216e6d3f6a1f24434611c41161921fc";
                hash = "sha256-bZlYKNVX++NEuQJReCcchRxvOoSB1eowHhy6+sja2gY=";
              };

              patchPhase = ''
                for path in src/bootstrap/boot1.bqn src/bootstrap/boot2.bqn src/glyphs.bqn; do
                  substituteInPlace "$path" \
                    --replace-fail "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" \
                                   "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍳"
                done
                substituteInPlace src/pr.bqn \
                  --replace-fail "keep ← \"!+-×÷⋆⌊=≤≢⥊⊑↕⌜\`⊘⎊\"" \
                                 "keep ← \"!+-×÷⋆⌊=≤≢⥊⊑↕⌜\`⊘⎊⍳\""
              '';
              installPhase = "cp -r . $out";
            };
          in {
            default = nativeStdenv.mkDerivation {
              pname = "cbqn";
              version = "complex";
              src = pkgs.fetchFromGitHub {
                owner = "dzaima";
                repo = "CBQN";
                rev = "c88ce9d844155f2ddacdbe925b4c01f36cad1daf";
                hash = "sha256-DpAvHvQ8bqxxIPP0PPhct0HZo53yQF3HQgeufXlcIeY";
                fetchSubmodules = true;
              };

              nativeBuildInputs = [ pkgs.pkg-config ];
              buildInputs = [ pkgs.libffi ];

              makeFlags = [ "CC=${nativeStdenv.cc.targetPrefix}cc" ];
              buildFlags = [ "o3" "notui=1" "REPLXX=1" "target_from_cc=1" ];

              dontConfigure = true;

              preBuild = ''
                mkdir -p build/{singeliLocal,bytecodeLocal,replxxLocal,bytecodeLocal/gen}
                cp -r build/singeliSubmodule/. build/singeliLocal/
                cp -r build/bytecodeSubmodule/. build/bytecodeLocal/
                cp -r build/replxxSubmodule/. build/replxxLocal/
                make for-bootstrap
                ./BQN build/bootstrap.bqn "${patchedBootstrap}"
              '';

              postPatch = ''
                sed -i '/SHELL =/d' makefile build/makefile
                patchShebangs build/build
              '';

              installPhase = ''
                mkdir -p $out/bin
                cp BQN $out/bin/
                ln -sf BQN $out/bin/bqn
                ln -sf BQN $out/bin/cbqn
              '';

              meta.mainProgram = "cbqn";
            };
          });

        # nix run
        apps = forAllSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in {
            default = {
              type = "app";
              program = "${self.packages.${system}.default}/bin/cbqn";
            };
          });

        # nix develop
        devShells = forAllSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in {
            default = pkgs.mkShell {
              inputsFrom = [ self.packages.${system}.default ];
              shellHook = ''
                export PATH="$PWD/result/bin:$PWD:$PATH"
              '';
            };
        });
      };
}
