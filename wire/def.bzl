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

"""Public definitions for Wire rules.

All public Wire rules, providers, and other definitions are imported and
re-exported in this file. This allows the real location of definitions to
change for easier maintenance.

Definitions outside this file are private unless otherwise noted, and may
change without notice.
"""

load("//wire/private/rules:release.bzl", _wire_release = "wire_release")
load("//wire/private/rules:injector.bzl", _wire_injector = "wire_injector")
load(
    "//wire/private:wire_toolchain.bzl",
    _declare_toolchains = "declare_toolchains",
    _wire_toolchain = "wire_toolchain",
)
load(
    "//wire/private:providers.bzl",
    _WireRelease = "WireRelease",
)

WireRelease = _WireRelease

declare_toolchains = _declare_toolchains
wire_release = _wire_release
wire_injector = _wire_injector
wire_toolchain = _wire_toolchain
