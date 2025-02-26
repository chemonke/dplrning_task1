self: super: {
  PepTools = super.rPackages.buildRPackage rec {
    name = "PepTools";
    version = "main";

    src = super.fetchFromGitHub {
      owner = "leonjessen";
      repo = "PepTools";
      rev = "master";
      sha256 = "1zj0nl4ik0dizg6wd9ms1s6bvmsd9r91yny0n092zar77mw9f6pv";  # Replace with actual hash
    };

    propagatedBuildInputs = with super.rPackages; [
      tidyverse
      cowplot
      ggseqlogo
      data_table
      magrittr
      ggplot2
      stringr
    ];

    nativeBuildInputs = with super.rPackages; [ devtools ];
  };
}
