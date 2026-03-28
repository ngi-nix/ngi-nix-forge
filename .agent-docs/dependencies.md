<!-- .agent-docs/dependencies.md -->
<!-- Read this file for common dependency mappings between build systems and nixpkgs packages. -->

# Common Dependencies Mapping

## C/C++ Libraries

| If build system looks for | Nix package to add |
|---------------------------|-------------------|
| SQLite, sqlite3, sqlite | `pkgs.sqlite` |
| GDAL, gdal | `pkgs.gdal` |
| PostgreSQL, libpq, pq | `pkgs.postgresql` |
| OpenSSL, ssl | `pkgs.openssl` |
| CURL, curl, libcurl | `pkgs.curl` |
| zlib, z | `pkgs.zlib` |
| Boost, boost | `pkgs.boost` |
| GEOS, geos | `pkgs.geos` |
| PROJ, proj | `pkgs.proj` |
| libxml2, xml2 | `pkgs.libxml2` |
| expat | `pkgs.expat` |

---

## Python Packages

| If pyproject.toml/requirements has | Nix package to add |
|-----------------------------------|-------------------|
| click | `pkgs.python3Packages.click` |
| requests | `pkgs.python3Packages.requests` |
| numpy | `pkgs.python3Packages.numpy` |
| attrs | `pkgs.python3Packages.attrs` |
| certifi | `pkgs.python3Packages.certifi` |
| setuptools | `pkgs.python3Packages.setuptools` |
| cython | `pkgs.python3Packages.cython` |
| wheel | `pkgs.python3Packages.wheel` |
| pytest | `pkgs.python3Packages.pytest` (test only) |

---

## Build Tools (always in requirements.native)

- `pkgs.cmake` - CMake build system
- `pkgs.pkg-config` - Finding library dependencies
- `pkgs.meson` - Meson build system
- `pkgs.ninja` - Ninja build tool
- `pkgs.autoconf` - Autotools
- `pkgs.automake` - Autotools
- `pkgs.libtool` - Autotools
