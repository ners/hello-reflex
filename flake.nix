{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      haskell = pkgs.haskellPackages;
      haskellDeps = drv: builtins.foldl'
        (acc: type: acc ++ drv.getCabalDeps."${type}HaskellDepends")
        [ ]
        [ "executable" "library" "test" ];
      helloReflex = haskell.callCabal2nix "HelloReflex" ./. { };
    in
    {
      packages.default = helloReflex;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          (haskell.ghcWithPackages (_: haskellDeps helloReflex))
          haskell.cabal-install
          haskell.haskell-language-server
        ];
      };
    });
}

