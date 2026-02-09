{
  config,
  lib,
  home,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        ansible
        autopep8
        boto3
        bech32
        black
        # flake8
        ipykernel
        ipython
        ipywidgets
        jupyter
        matplotlib
        mypy
        numpy
        opencv
        pep8
        pylsp-mypy
        # python-telegram-bot
        torch
        # tensorflow
        # tensorflow_avx2
        torchvision
        requests
        scipy
        setuptools
        virtualenv
      ]
    ))
  ];
}
