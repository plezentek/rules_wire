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

load("//wire/private:actions.bzl", "wire_compile")

def _wire_injector_impl(ctx):
    # For output files, we use a unique per-target prefix to avoid conflict
    # with files from other targets in the same package (which would otherwise
    # be placed into the same package directory)
    target_prefix = ctx.label.name + "%/"

    # Wire outputs one schema(db) file, one models file, one additional file if
    # the interface is requested, and one file for each query file.
    injector_file = ctx.actions.declare_file(target_prefix + "wire_gen.go")
    outputs = [injector_file]

    package_paths = {s.dirname: True for s in ctx.files.srcs}
    if len(package_paths) != 1:
        fail("Source files must all be from the same package.")

    # TODO(Windows) Figure out path handling for windows
    config_path_depth = len(package_paths.keys()[0].split("/"))

    wire_compile(
        ctx,
        package_dir = package_paths.keys()[0],
        config_path_depth = config_path_depth,
        srcs = ctx.files.srcs,
        deps = ctx.attr.deps,
        out = outputs,
    )

    # TODO(V2) Investigate direct compilation by embedding a go_library rule
    return struct(providers = [
        DefaultInfo(
            files = depset(outputs),
            runfiles = ctx.runfiles(outputs),  # For tests
        ),
    ])

wire_injector = rule(
    _wire_injector_impl,
    attrs = {
        "deps": attr.label_list(
            doc = "Packages this injector depends on",
        ),
        "srcs": attr.label_list(
            allow_files = [".go"],
            doc = "The source files in the package of this injector",
        ),
        "_google_wire": attr.label(
            default = "@com_github_google_wire//:wire",
            doc = "Implicit dependency of all injectors",
        ),
    },
    doc = """
Wire is a code generation tool that automates connecting components using
[dependency injection](https://en.wikipedia.org/wiki/Dependency_injection).

Example:
```
    wire_injector(
        name = "product_injector",
        srcs = [
            "main.go",
            "wire.go",
        ],
    )
```
""",
    executable = False,
    output_to_genfiles = True,
    toolchains = [
        "@com_plezentek_rules_wire//wire:toolchain",
        "@io_bazel_rules_go//go:toolchain",
    ],
)
