{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    haskell-ui = {
      url = "github:alt-romes/haskell-ui";
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
      helloReflex = haskell.callCabal2nix "HelloReflex" ./. { haskell-ui = haskellUi; };
      haskellUi = haskell.callCabal2nix "haskell-ui" haskell-ui { };
      helloReflexApp = flake-utils.lib.mkApp { drv = helloReflex; };
    in
    {
      apps = {
        helloReflex = helloReflexApp;
        default = helloReflexApp;
      };
      packages = {
        inherit helloReflex haskellUi;
        default = helloReflex;
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          (haskell.ghcWithPackages (_: haskellDeps helloReflex))
          haskell.cabal-install
          haskell.haskell-language-server
        ];
      };
    });
}

