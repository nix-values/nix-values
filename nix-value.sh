set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  nix-value [--flake | --flake-false] [-o DIR] VALUE

Generate a local directory that can be used as a Nix flake input carrying VALUE.

Options:
  --flake         Write default.nix and a minimal flake.nix. This is the default.
  --flake-false  Write only default.nix for inputs declared with flake = false.
  -o, --output   Write to DIR instead of creating a temporary directory.
  -h, --help     Show this help text.

Examples:
  nix-value true
  nix-value '"x86_64-linux"'
  nix-value --flake-false '{ debug = true; libc = "musl"; }'
EOF
}

die() {
  printf 'nix-value: %s\n' "$*" >&2
  exit 1
}

write_flake=true
output_dir=
value=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --flake)
      write_flake=true
      shift
      ;;
    --flake-false | --no-flake)
      write_flake=false
      shift
      ;;
    -o | --output)
      [ "$#" -ge 2 ] || die "$1 requires a directory"
      output_dir=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      if [ -z "${value}" ]; then
        value=$1
      else
        die "expected one VALUE argument"
      fi
      shift
      ;;
  esac
done

[ "$#" -eq 0 ] || die "unexpected arguments after --"
[ -n "${value}" ] || die "missing VALUE argument"

if [ -z "${output_dir}" ]; then
  output_dir=$(mktemp -d "${TMPDIR:-/tmp}/nix-value.XXXXXXXXXX")
else
  mkdir -p "${output_dir}"
  if [ -n "$(find "${output_dir}" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    die "output directory is not empty: ${output_dir}"
  fi
fi

printf '%s\n' "${value}" >"${output_dir}/default.nix"

if [ "${write_flake}" = true ]; then
  printf '%s\n' '{ outputs = _: { }; }' >"${output_dir}/flake.nix"
fi

nix eval --file "${output_dir}/default.nix" >/dev/null
printf '%s\n' "${output_dir}"
