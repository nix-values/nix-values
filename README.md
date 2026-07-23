<div align="center">

<img width="400" alt="Nix Values" src="./assets/logo.svg">

</div>

Generate minimal local Nix value inputs for flakes.

`nix-value` takes a Nix expression, writes it to `default.nix`, validates it with
`nix eval`, and prints the generated directory. By default it also writes the
smallest `flake.nix` needed for the directory to qualify as a flake input.

## Usage

```console
$ nix run github:nix-values/nix-values -- true
/tmp/nix-value.abc123defg
```

Use the printed path with `--override-input`:

```console
$ value=$(nix run github:nix-values/nix-values -- true)
$ nix run github:username/project --override-input debug-mode "path:$value"
```

The generated directory contains:

```nix
# default.nix
true
```

```nix
# flake.nix
{ outputs = _: { }; }
```

Values are raw Nix expressions, so strings and structured values work too:

```console
$ nix run github:nix-values/nix-values -- '"x86_64-linux"'
$ nix run github:nix-values/nix-values -- '{ debug = true; libc = "musl"; }'
```

## `flake = false`

For inputs declared with `flake = false`, only `default.nix` is needed:

```nix
inputs.debug-mode = {
  url = "github:nix-values/false";
  flake = false;
};
```

Generate that smaller directory with:

```console
$ value=$(nix run github:nix-values/nix-values -- --flake-false true)
$ nix run github:username/project --override-input debug-mode "path:$value"
```

## Output Directory

Pass `-o` or `--output` to choose the output directory:

```console
$ nix run github:nix-values/nix-values -- -o ./debug-value true
./debug-value
```

The output directory must be empty.
