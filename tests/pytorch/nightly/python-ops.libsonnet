// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

local common = import 'common.libsonnet';
local timeouts = import 'templates/timeouts.libsonnet';
local tpus = import 'templates/tpus.libsonnet';
local utils = import 'templates/utils.libsonnet';

{
  local operations = common.PyTorchTest {
    modelName: 'python-ops',
    command: [
      'bash',
      'pytorch/xla/test/run_tests.sh',
    ],
    metricConfig+: {
      sourceMap+:: {
        tensorboard+: {
          aggregateAssertionsMap:: {},
        },
        literals: {},
      },
    },
  },
  local v2_8 = {
    accelerator: tpus.v2_8,
  },
  local v3_8 = {
    accelerator: tpus.v3_8,
  },
  local tpuVm = common.PyTorchTpuVmMixin {
    tpuSettings+: {
      tpuVmExports+: |||
        export XLA_USE_BF16=$(XLA_USE_BF16)
      |||,
      tpuVmExtraSetup: |||
        echo 'export PATH=~/.local/bin:$PATH' >> ~/.bash_profile
        echo 'export XLA_USE_BF16=1' >> ~/.bash_profile
      |||,
    },
  },


  configs: [
    operations + v2_8 + common.Functional + timeouts.Hours(6) + tpuVm,
    operations + v3_8 + common.Functional + timeouts.Hours(6) + tpuVm,
  ],
}
