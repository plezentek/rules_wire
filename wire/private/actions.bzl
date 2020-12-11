# Copyright 2020 Plezentek, Inc. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_skylib//lib:versions.bzl", "versions")
load("@io_bazel_rules_go//go:def.bzl", "GoSource")

def wire_compile(ctx, package_dir, config_path_depth, srcs, deps, out):
    """Compile a database library from Wire config and sources"""

    toolchain_wire = ctx.toolchains["@com_plezentek_rules_wire//wire:toolchain"]
    toolchain_go = ctx.toolchains["@io_bazel_rules_go//go:toolchain"]

    # The following hackery is because our toolchain executable needs to be run
    # from the same directory as the source code, which means we need to do
    # path smashing to make all paths relative to this location.
    # TODO(Windows) Figure out path handling for windows
    back_to_root = "/".join([".."] * config_path_depth)

    # Now it's time to build up a GOPATH src folder so that the go list package
    # driver can deliver package information to Wire. We start with the
    # embedded, implicit dependency on github.com/google/wire
    wire_source = ctx.attr._google_wire[GoSource]
    wire_copy = ctx.actions.declare_file(
        "{}%/GOPATH/src/{}/{}".format(
            ctx.label.name,
            wire_source.library.importpath,
            wire_source.srcs[0].basename,
        ),
    )
    ctx.actions.expand_template(
        template = wire_source.srcs[0],
        output = wire_copy,
        substitutions = {},
    )

    # Now, do the same thing with any provided dependencies
    source_copies = [wire_copy]
    for dep in deps:
        library = dep[GoSource]
        importpath = library.library.importpath
        for source in library.orig_srcs:
            source_copy = ctx.actions.declare_file("{}%/GOPATH/src/{}/{}".format(ctx.label.name, importpath, source.basename))
            source_copies.append(source_copy)
            ctx.actions.expand_template(
                template = source,
                output = source_copy,
                substitutions = {},
            )

    # source_copies is guaranteed to have files, because wire depends on github.com/google/wire
    parts = wire_copy.dirname.split("/")
    for i in range(len(parts)):
        if parts[-1] == "GOPATH":
            break
        parts.pop()
    gopath = "/".join(parts)

    tmp = ctx.actions.declare_file("{}%/GOCACHE/ROOT".format(ctx.label.name))
    ctx.actions.write(tmp, "")

    env = {
        "PATH": "/".join([back_to_root, toolchain_go.sdk.go.dirname]),
    }
    ctx.actions.run_shell(
        tools = [toolchain_wire.release.wire, toolchain_go.sdk.go],
        # TODO(Windows) Figure out path handling for windows
        # TODO(Hacky) Turn this into an embedded go program
        command = "export ABS_WIRE_DIR=\"$(pwd)\" && export GOPATH=\"${{ABS_WIRE_DIR}}/{}\" && export GOCACHE=\"${{ABS_WIRE_DIR}}/{}\" && cd {} && {}/{} gen -output_file_prefix {}".format(
            gopath,
            tmp.path,
            package_dir,
            back_to_root,
            toolchain_wire.release.wire.path,
            back_to_root + "/" + out[0].dirname + "/",
        ),
        env = env,
        inputs = srcs + source_copies,
        outputs = out,
        mnemonic = "WireGenerate",
    )
