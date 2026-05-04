# CBQN Complex Numbers

This repo exists to make the complex numbers support in [CBQN](https://github.com/dzaima/CBQN) easy to try.

It packages a pinned CBQN checkout together with the bootstrap changes needed for the complex-number work, so you do not need to juggle branches or patch things by hand.

## Quick start

Install Nix with flakes enabled if you don't have it. The simplest route is [Determinate Nix](https://determinate.systems/nix-installer),
which enables flakes by default:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Then run this repo directly:

```sh
nix run github:Panadestein/complex_cbqn
```

If you already cloned the repo, this also works:

```sh
nix run
```

That starts the patched `cbqn` executable.

## What this flake provides

- `nix run` starts `cbqn`
- `nix build` builds the same executable
- `nix develop` opens a shell with the build inputs

## Scope

Linux only for now: `x86_64-linux` and `aarch64-linux`
