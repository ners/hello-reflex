{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      haskellDeps = drv: with builtins; concatLists (attrValues drv.getCabalDeps);
      haskellPackages = pkgs.haskellPackages.override {
        overrides = self: super: {
          hello-reflex = self.callCabal2nix "HelloReflex" ./. { };
        };
      };
    in
    {
      packages = rec {
        inherit (haskellPackages) hello-reflex;
        default = hello-reflex;
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with haskellPackages; [
          (ghcWithPackages (_: haskellDeps hello-reflex))
          cabal-install
          fourmolu
          haskell-language-server
        ];
      };
    });
}

