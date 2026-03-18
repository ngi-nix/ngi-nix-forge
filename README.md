# NGI Nix Forge

**WARNING: this sofware is currently in alpha state of development.**

## Features

* Simple, type checked configuration recipes for **packages** and
  **mutli-component applications** using
  [module system](https://nix.dev/tutorials/module-system/index.html)

* [Web UI](https://ngi-nix.github.io/ngi-nix-forge)

* [LLMs support](./AGENTS.md)

* Easy [self hosting](#self-hosting)


### Conceptual diagram

```mermaid
graph TB
    subgraph Sources["Sources"]
        SW1[Git Repository]
        SW2[Tarball URL]
        SW3[Local Path]
        NIXPKGS(Nixpkgs)
    end

    PKG[Package Recipe<br/>recipe.nix]

    subgraph PackageOutputs["Packages"]
        PO4[Nix Package]
        PO1[Development Environment]
        PO2[Shell Environment]
    end

    APP[Application Recipe<br/>recipe.nix]

    subgraph AppOutputs["Applications"]
        AO1[Shell Environment<br/>for CLI and GUI components]
        AO2[Container Images<br/>for Multi-component services]
        AO3[NixOS VM<br/>for Multi-component services]
    end

    REG[Nix Forge Registry]

    subgraph Deployment["Deployment"]
        SHELL[Shell Environment<br/>for CLI and GUI components]
        K8S[Kubernetes Cluster<br/>for Multi-component services]
        NIXOS[NixOS System<br/>for Multi-component services]
    end

    SW1 & SW2 & SW3 & NIXPKGS--> PKG
    PKG --> PO1 & PO2 & PO4

    PO4 & NIXPKGS --> APP
    APP --> AO1
    APP --> AO2
    APP --> AO3

    AO2 --> REG

    AO1 --> SHELL
    AO3 --> NIXOS
    REG --> K8S
```

## Self hosting

* Initiate new Nix Forge instance from template

```bash
nix flake init --template github:ngi-nix/ngi-nix-forge#example
```

* Set `repositoryUrl` attribute in `flake.nix` to your repository

* Add all new files to git

* Start creating recipes  in `recipes` directory


## LLM agents

LLM agents, read [these instructions](./AGENTS.md) first.


## Credits

This software was originally started as a fork of
[imincik/nix-forge](https://github.com/imincik/nix-forge).
