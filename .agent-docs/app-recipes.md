<!-- .agent-docs/app-recipes.md -->
<!-- Read this file when creating application recipes with programs, containers, or VMs. -->

# Application Recipes

## Structure

```nix
{
  name = "app-name";
  version = "1.0.0";
  description = "Application description.";
  usage = "Usage instructions in markdown...";  # Optional but helpful

  # Enable output types (at least one must be enabled):
  programs = { ... };    # Shell bundle
  containers = { ... };  # Docker containers
  vm = { ... };         # NixOS VM
}
```

**IMPORTANT:** Apps are always included in the packages output. However, individual outputs (programs bundle, containers, VM) are only generated when their respective `enable` option is set to `true`. If all three options are disabled, the app package will be available but will have no functional outputs.

---

## Programs (Shell Bundle)

```nix
programs = {
  enable = true;  # Set to true to enable programs bundle output
  requirements = [
    pkgs.mypkgs.my-package  # Reference packages from forge
    pkgs.curl
  ];
};
```

---

## Containers

```nix
containers = {
  enable = true;  # Set to true to enable container images output
  images = [
    {
      name = "api-server";
      requirements = [ pkgs.mypkgs.my-package ];
      config.CMD = [ "my-package" "--serve" ];
    }
  ];
  composeFile = ./compose.yaml;  # Optional
};
```

---

## Virtual Machine

```nix
vm = {
  enable = true;  # Set to true to enable VM output
  name = "my-vm";
  requirements = [ pkgs.mypkgs.my-package ];
  config = {
    ports = [ "8080:8080" ];
    system = {
      services.postgresql.enable = true;
      systemd.services.my-service = {
        script = "${pkgs.mypkgs.my-package}/bin/my-package";
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
};
```

---

## Output Control

Each app output type can be independently enabled or disabled:

- **programs.enable**: Controls the base programs bundle (accessed via `nix build .#<app>`)
- **containers.enable**: Controls the container images output (accessed via `nix build .#<app>.containers`)
- **vm.enable**: Controls the virtual machine output (accessed via `nix build .#<app>.vm`)

**Example with selective outputs:**

```nix
{
  name = "my-app";
  version = "1.0.0";
  description = "Example app with selective outputs.";

  programs = {
    enable = true;  # Programs bundle will be built
    requirements = [ pkgs.hello ];
  };

  containers = {
    enable = false;  # Container images will NOT be built
    images = [ /* ... */ ];
  };

  vm = {
    enable = true;  # VM will be built
    name = "my-vm";
    requirements = [ pkgs.hello ];
  };
}
```
