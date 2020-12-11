This directory is a partial copy of github.com/bazelbuild/rules_go/private.
Version 0.24.7, retrieved on 2020-11-24.
Only platforms.bzl and toolchains.bzl are included.

The constraint names have been altered to be unique to this repository.

platforms.bzl is needed by repository rules imported from
//wire/private:release.bzl and //wire/private:wire_toolchain.bzl.

toolchains.bzl is needed by repository rules imported from
//wire/private:release.bzl.

Uses of rules_go outside of files loaded by //wire/private:release.bzl and
//wire/private:wire_toolchain.bzl should use the external rules_go repository,
@io_bazel_rules_go.

