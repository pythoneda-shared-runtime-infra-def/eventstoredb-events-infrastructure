# pythoneda-shared-runtime/lifecycle-events-infrastructure

This is the definition for [https://github.com/pythoneda-shared-runtime/lifecycle-events-infrastructure](https://github.com/pythoneda-shared-runtime/lifecycle-events-infrastructure "pythoneda-shared-runtime/lifecycle-events-infrastructure").

## How to declare it in your flake

Check the latest tag of this repository and use it instead of the `[version]` placeholder below.

```nix
{
  description = "[..]";
  inputs = rec {
    [..]
    pythoneda-shared-runtime-lifecycle-events-infrastructure = {
      [optional follows]
      url =
        "github:pythoneda-shared-runtime-def/lifecycle-events-infrastructure/[version]";
    };
  };
  outputs = [..]
};
```

Should you use another PythonEDA modules, you might want to pin those also used by this project. The same applies to [nixpkgs](https://github.com/nixos/nixpkgs "nixpkgs") and [flake-utils](https://github.com/numtide/flake-utils "flake-utils").

Use the specific package depending on your system (one of `flake-utils.lib.defaultSystems`) and Python version:

- `#packages.[system].pythoneda-shared-runtime-lifecycle-events-infrastructure-python38` 
- `#packages.[system].pythoneda-shared-runtime-lifecycle-events-infrastructure-python39` 
- `#packages.[system].pythoneda-shared-runtime-lifecycle-events-infrastructure-python310` 
- `#packages.[system].pythoneda-shared-runtime-lifecycle-events-infrastructure-python311` 
