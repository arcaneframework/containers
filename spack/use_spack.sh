#
# Copyright 2021 IFPEN-CEA
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
#
ENV_FILE=/tmp/foo

[[ $# -ge 1 ]] && ENV_FILE="$1"

if [ ! -f "${ENV_FILE}" ]; then
  . /spack/share/spack/setup-env.sh
  spack env activate -V alien
  spack build-env --dump "${ENV_FILE}" alien
  # Remove functions from environment.
  awk '/function BASH_FUNC_(.*?)%%/,/export -f (.\S*?)/ { next } {print}' "${ENV_FILE}" > /tmp/foo && mv /tmp/foo "${ENV_FILE}"
fi
. "${ENV_FILE}"

