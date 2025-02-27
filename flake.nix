{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./overlay.nix) ];  # Load external overlay
        };

        # Old approach for R: define an explicit list of R packages
        rPackages = with pkgs.rPackages; [
          ggplot2
          tidyverse
          cowplot
          IRkernel      # Needed for Jupyter R support
          languageserver
          pkgs.PepTools # Explicitly include PepTools
        ];

        rEnv = pkgs.rWrapper.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ rPackages;
        });

        # New approach for Python: define pythonEnv with python3
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          ipython
          ipykernel    # Required for Jupyter integration
          numpy
          pandas
          tensorflow
          matplotlib
          seaborn
          keras
          rpy2         # Enables Python-R communication via rpy2
          jupyter      # Ensure Jupyter is installed in the Python env
        ]);

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jupyter
            python3     # Use python3 as the base interpreter
            pythonEnv
            rEnv
            pkgs.PepTools  # Ensure PepTools is available
          ];
        };
      }
    );
}
