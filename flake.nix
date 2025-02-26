{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs with the overlay applied
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./overlay.nix) ];  # Load external overlay
        };

        # Define R packages separately
        rPackages = with pkgs.rPackages; [
          ggplot2
          dplyr
          xts
          freqparcoord
          RANN
          MASS
          Rcpp
          tidyverse
          mice
          Rtsne
          clValid
          car
          IRkernel  # Needed for Jupyter R support
          languageserver
          pkgs.PepTools  # 🔧 FIX: Explicitly use pkgs.PepTools
        ];

        rEnv = pkgs.rWrapper.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ rPackages;
        });

        rstudioEnv = pkgs.rstudioWrapper.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ rPackages;
        });

        # Define Python environment
        pythonEnv = pkgs.python312.withPackages (ps: with ps; [
          ipython
          ipykernel  # Needed for Jupyter Python kernel
          numpy
          pandas
          tensorflow
          matplotlib
          seaborn
          keras
        ]);

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            texliveFull
            quarto
            jupyter
            pythonEnv
            rEnv
            rstudioEnv
            pkgs.PepTools  # 🔧 FIX: Use pkgs.PepTools explicitly
          ];

          shellHook = ''
            echo "Ensuring Jupyter kernels for Python and R are installed..."

            # Register Python kernel
            ${pythonEnv}/bin/python -m ipykernel install --user --name=python312 --display-name "Python 3.12"

            # Register R kernel
            ${rEnv}/bin/R -e 'IRkernel::installspec(user = TRUE)'

            echo "Jupyter setup complete."
          '';
        };
      }
    );
}
