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

load("//wire/private/skylib/lib:versions.bzl", "versions")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# The user must ensure that io_bazel_rules_go and bazel_gazelle exist before calling wire_rules_dependencies()
load("@bazel_gazelle//:deps.bzl", "go_repository")

MINIMUM_BAZEL_VERSION = "3.0.0"

def wire_rules_dependencies():
    """Declares workspaces the Wire rules depend on.  Workspaces that use
    wire_injector should call this.
    """
    if getattr(native, "bazel_version", None):
        versions.check(MINIMUM_BAZEL_VERSION, bazel_version = native.bazel_version)

    # Needed by wire implementation and tests.
    # We can't call bazel_skylib_workspace from here. At the moment, it's only
    # used to register unittest toolchains, which wire does not need.
    _maybe(
        http_archive,
        name = "bazel_skylib",
        # 1.0.2, latest as of 2020-08-24
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    )

    _maybe(
        http_archive,
        name = "io_bazel_rules_go",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.24.7/rules_go-v0.24.7.tar.gz",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.24.7/rules_go-v0.24.7.tar.gz",
        ],
        sha256 = "207fad3e6689135c5d8713e5a17ba9d1290238f47b9ba545b63d9303406209c6",
    )

    _maybe(
        go_repository,
        name = "com_github_google_wire",
        build_extra_args = [
            "-exclude=internal/wire/testdata",
        ],
        importpath = "github.com/google/wire",
        sum = "h1:kXcsA/rIGzJImVqPdhfnr6q0xsS9gU0515q1EPpJ9fE=",
        # latest, as of 2020-11-18
        version = "v0.4.0",
    )

def _maybe(repo_rule, name, **kwargs):
    """Declares an external repository if it hasn't been declared already."""
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
