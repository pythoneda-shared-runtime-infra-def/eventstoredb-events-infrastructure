# flake.nix
#
# This file packages pythoneda-shared-runtime-infrastructure/eventstoredb-events-infrastructure as a Nix flake.
#
# Copyright (C) 2024-today rydnr's pythoneda-shared-runtime-infra-def/eventstoredb-events-infrastructure
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description =
    "Infrastructure support for the infrastructure events relevant to https://www.eventstore.com";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-shared-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-def/banner/0.0.47";
    };
    pythoneda-shared-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      url = "github:pythoneda-shared-def/domain/0.0.27";
    };
    pythoneda-shared-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/infrastructure/0.0.24";
    };
    pythoneda-shared-runtime-infrastructure-eventstoredb-events = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url =
        "github:pythoneda-shared-runtime-infra-def/eventstoredb-events/0.0.0";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-shared-runtime-infrastructure";
        repo = "eventstoredb-events-infrastructure";
        version = "0.0.1";
        sha256 = "1wsap1068c2nznswzs5040wyc51jf8a34nx9my6dl39gf57yc8zp";
        pname = "${org}-${repo}";
        pythonpackage =
          "pythoneda.shared.runtime.infrastructure.events.infrastructure.eventstoredb";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        pkgs = import nixos { inherit system; };
        description =
          "Infrastructure support for the infrastructure events relevant to https://www.eventstore.com";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "rydnr <github@acm-sl.org>" ];
        archRole = "E";
        space = "R";
        layer = "I";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-banner}/nix/shared.nix";
        pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-for =
          { python, pythoneda-shared-domain, pythoneda-shared-infrastructure
          , pythoneda-shared-runtime-infrastructure-eventstoredb-events }:
          let
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaSharedDomainVersion = pythoneda-shared-domain.version;
              pythonedaSharedRuntimeInfrastructureEventstoredbEventsVersion =
                pythoneda-shared-runtime-infrastructure-eventstoredb-events.version;
              pythonedaSharedInfrastructureVersion =
                pythoneda-shared-infrastructure.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-shared-domain
              pythoneda-shared-infrastructure
              pythoneda-shared-runtime-infrastructure-eventstoredb-events
            ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              cat ${pyprojectTemplate}
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-default;
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-default =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python311;
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python38 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python38;
              python = pkgs.python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python39;
              python = pkgs.python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python310;
              python = pkgs.python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python311;
              python = pkgs.python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-default;
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-default =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python311;
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python38 =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-for {
              python = pkgs.python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python38;
              pythoneda-shared-runtime-infrastructure-eventstoredb-events =
                pythoneda-shared-runtime-infrastructure-eventstoredb-events.packages.${system}.pythoneda-shared-runtime-infrastructure-eventstoredb-events-python38;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python39 =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-for {
              python = pkgs.python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python39;
              pythoneda-shared-runtime-infrastructure-eventstoredb-events =
                pythoneda-shared-runtime-infrastructure-eventstoredb-events.packages.${system}.pythoneda-shared-runtime-infrastructure-eventstoredb-events-python39;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python310 =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-for {
              python = pkgs.python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python310;
              pythoneda-shared-runtime-infrastructure-eventstoredb-events =
                pythoneda-shared-runtime-infrastructure-eventstoredb-events.packages.${system}.pythoneda-shared-runtime-infrastructure-eventstoredb-events-python310;
            };
          pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-python311 =
            pythoneda-shared-runtime-infrastructure-eventstoredb-events-infrastructure-for {
              python = pkgs.python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              pythoneda-shared-infrastructure =
                pythoneda-shared-infrastructure.packages.${system}.pythoneda-shared-infrastructure-python311;
              pythoneda-shared-runtime-infrastructure-eventstoredb-events =
                pythoneda-shared-runtime-infrastructure-eventstoredb-events.packages.${system}.pythoneda-shared-runtime-infrastructure-eventstoredb-events-python311;
            };
        };
      });
}
