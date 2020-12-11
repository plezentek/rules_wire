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

load("//wire/private:providers.bzl", "WireRelease")

def _wire_release_impl(ctx):
    return [WireRelease(
        version = ctx.attr.version,
        goos = ctx.attr.goos,
        goarch = ctx.attr.goarch,
        root_file = ctx.file.root_file,
        wire = ctx.executable.wire,
    )]

wire_release = rule(
    _wire_release_impl,
    attrs = {
        "goos": attr.string(
            mandatory = True,
            doc = "The host OS the release was built for",
        ),
        "goarch": attr.string(
            mandatory = True,
            doc = "The host architecture the release was built for",
        ),
        "root_file": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The root file in the directory.",
        ),
        "wire": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "The wire binary",
        ),
        "version": attr.string(
            mandatory = True,
            doc = "The version of this release",
        ),
    },
    doc = "Information about a Wire binary release",
    provides = [WireRelease],
)
