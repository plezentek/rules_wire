# [Wire](https://github.com/google/wire) rules for [Bazel](https://bazel.build)

This repository contains rules for Bazel that allow you to use Wire dependency
injection.  These rules are an **Alpha** release and are being built from the
ground up.

## Table of Contents
1. [Alpha Status](#alpha-status)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Documentation](#documentation)

## Alpha Status
These rules are considered an Alpha release for two (2) reasons:
1. Incomplete: The test suite is small, and the project is being built first
   for small projects, so it probably won't work when dropped into a very large
   codebase.
2. Performance: Wire requires a go build tool that supports the
   `golang.org/x/tools/go/packages` API, but `rules_go` does not yet support
   that API (See [Issue
   #512](https://github.com/bazelbuild/rules_go/issues/512)). To workaround
   this issue, these rules build up a source representation of dependencies for
   each `wire_injector` instance.  This is slow and expensive.

## Setup
The first thing you need to do is load the rules in your WORKSPACE file to make
them available in your Bazel repository.  Before you can use `rules_wire`, you
must first import and register both `rules_go` and `gazelle`.

```Starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the Go rules.
http_archive(
    name = "io_bazel_rules_go",
    sha256 = "207fad3e6689135c5d8713e5a17ba9d1290238f47b9ba545b63d9303406209c6",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.24.7/rules_go-v0.24.7.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.24.7/rules_go-v0.24.7.tar.gz",
    ],
)

# Download Gazelle.
http_archive(
    name = "bazel_gazelle",
    sha256 = "b85f48fa105c4403326e9525ad2b2cc437babaa6e15a3fc0b1dbab0ab064bc7c",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.2/bazel-gazelle-v0.22.2.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.2/bazel-gazelle-v0.22.2.tar.gz",
    ],
)

# Load macros and repository rules.
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

# Download the Wire rules
http_archive(
    name = "com_plezentek_rules_wire",
    sha256 = "ad42429b6b9625f2ee3ce5894aaa9b5574cbb655e63ea13967d7648f11b049ec",
    urls = [
        "https://github.com/plezentek/rules_wire/releases/download/v0.1.0-alpha/rules_wire-v0.1.0-alpha.tar.gz"
    ],
)

load("@com_plezentek_rules_wire//wire:deps.bzl", "wire_register_toolchains", "wire_rules_dependencies")

wire_rules_dependencies()

wire_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()
```

If you'd like to use the development version of these rules, you can fetch them
with `git_repository` by setting the `commit` parameter to a recent commit hash.

```Starlark
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "com_plezentek_rules_wire",
    commit = "<RECENT_COMMIT>",
    remote = "https://github.com/plezentek/rules_wire",
)

load("@com_plezentek_rules_wire//wire:deps.bzl", "wire_register_toolchains", "wire_rules_dependencies")

wire_rules_dependencies()

wire_register_toolchains()
```

## Usage
In order to generate a Wire injector called `product_injector`, use the following
`wire_injector` rule.

```Starlark
load("@com_plezentek_rules_wire//wire:def.bzl", "wire_injector")

wire_injector(
    name = "product_injector",
    srcs = [
        "main.go",
        "wire.go",
    ],
)
```

You can combine this with [rules_go](https://github.com/bazelbuild/rules_go) in
order to compile a Go library and/or binary. Notice how the we use a filegroup
to share the sources.

```Starlark
load("@com_plezentek_rules_wire//wire:def.bzl", "wire_injector")
load("@io_bazel_rules_go//go:def.bzl", "go_library")

filegroup(
    name = "product_sources",
    srcs = glob("*.go"),
)

wire_injector(
    name = "product_injector",
    srcs = [
        ":product_sources",
    ],
)

go_library(
    name = "product_library",
    srcs = [
        ":product_injector",
        ":product_sources",
    ],
    importpath = "example.com/owner/repo/product",
)

go_binary(
    name = "product_binary",
    embed = [":product_library"],
)
```

# Documentation
Full details on the use of the wire_injector rule can be found in the [rules
documentation](docs/rules.md).

The `WireRelease` bazel provider (for writers of further bazel rules) can be
found in the [provider documentation](docs/providers.md).
