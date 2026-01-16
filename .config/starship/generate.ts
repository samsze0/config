import * as fs from "node:fs";
import * as path from "node:path";
import { stringify } from "smol-toml";

const home = process.env.HOME;
if (!home) {
  throw new Error("HOME environment variable is not set.");
}

const separator = "⋅";

const genericFormat = (text: string) => `[${text}]($style) `;

const genericFormatWithSeparator = (text: string) =>
  `${separator} [${text}]($style) `;

type ConfigBlock = {
  [key: string]: string | boolean | number;
  content?: string;
};

const starshipSpec: {
  layout: string[];
  extensionModuleBaseConfig: ConfigBlock;
  extensionModules: {
    [key: string]: ConfigBlock;
  };
  coreModuleBaseConfig: ConfigBlock;
  coreModules: {
    [key: string]: ConfigBlock;
  };
  customModuleBaseConfig: {
    [key: string]: string;
  };
  customModules: {
    [key: string]: ConfigBlock;
  };
} = {
  layout: [
    "directory",
    "git_branch",
    "git_commit",
    "git_state",
    "git_metrics",
    "git_status",
    "all",
    "line_break",
    "character",
  ],
  extensionModuleBaseConfig: {
    style: "blue",
    version_format: "v${raw}",
    content: "$symbol($version)",
  },
  extensionModules: {
    c: {},
    cmake: {},
    golang: {},
    java: {},
    kotlin: {},
    gradle: {},
    lua: {},
    nodejs: {},
    python: {},
    rust: {},
    ruby: {},
    swift: {},
    typst: {},
    zig: {},
    deno: {},
    helm: {},
    terraform: {},
    pulumi: {},
  },
  coreModuleBaseConfig: {},
  coreModules: {
    battery: {
      disabled: true,
    },
    memory_usage: {
      disabled: true,
    },
    username: {
      content: "$user",
      style_root: "bright-black",
      style_user: "bright-black",
      show_always: false,
    },
    hostname: {
      ssh_only: true,
      content: "$hostname",
      style: "bright-yellow",
    },
    localip: {
      ssh_only: true,
      content: "$localipv4",
      style: "bright-yellow",
    },
    character: {
      first_item_in_line: true,
      content: "$symbol",
      success_symbol: "[❯](bold blue)",
      error_symbol: "[❯](bold red)",
      vimcmd_symbol: "[❮](bold blue)",
      vimcmd_visual_symbol: "[❮](bold yellow)",
      vimcmd_replace_symbol: "[❮](bold red)",
      vimcmd_replace_one_symbol: "[❮](bold red)",
    },
    jobs: {
      threshold: 1,
      symbol_threshold: 1,
      number_threshold: 1,
      content: "$symbol$number",
      symbol: "✦",
      style: "blue",
    },
    aws: {
      disabled: true,
    },
    azure: {
      disabled: true,
    },
    cmd_duration: {
      min_time: 0,
      content: "$duration",
      style: "bright-black",
      show_milliseconds: false,
      show_notifications: false,
      min_time_to_notify: 45000,
    },
    nix_shell: {
      symbol: "Nix",
      style: "blue",
      impure_msg: "impure",
      pure_msg: "pure",
    },
    package: {
      disabled: true,
    },
    docker_context: {
      disabled: false,
      symbol: "󰡨 ",
      style: "blue",
      content: "$symbol$context",
      only_with_files: true,
    },
    container: {
      disabled: true,
    },
    directory: {
      first_item_in_line: true,
      style: "bright-black",
    },
    git_status: {
      content: "$all_status$ahead_behind",
      style: " bright-black",
      ahead: "⇡",
      behind: "⇣",
      stashed: "",
      up_to_date: "",
      diverged: "ʏ",
      conflicted: "C",
      deleted: "D",
      renamed: "R",
      modified: "!",
      staged: "+",
      untracked: "?",
      ignore_submodules: true,
    },
    git_state: {
      rebase: "REBASING",
      merge: "MERGING",
      revert: "REVERTING",
      cherry_pick: "CHERRY-PICKING",
      bisect: "BISECTING",
      style: " bright-black",
      content: "$state ($progress_current/$progress_total)",
    },
    git_branch: {
      content: "$symbol$branch(:$remote_branch)",
      symbol: " ",
      style: " blue",
    },
    git_metrics: {
      disabled: true,
      added_style: "blue",
      deleted_style: "red",
      only_nonzero_diffs: true,
      format: "[+$added]($added_style) [-$deleted]($deleted_style)",
    },
    kubernetes: {
      symbol: "󱃾 ",
      content: "$symbol$context$namespace",
      style: "blue",
    },
    shell: {
      bash_indicator: "bash",
      zsh_indicator: "zsh",
      nu_indicator: "nu",
      fish_indicator: "󰈺",
      powershell_indicator: "_",
      unknown_indicator: "?",
      content: "$indicator",
      style: "bright-black",
    },
  },
  customModuleBaseConfig: {
    content: "$symbol($output)",
    style: "bright-black",
  },
  customModules: {
    osx: {
      command: "arch",
      symbol: " ",
      style: "bright-black",
      when: '[[ "$(uname)" == "Darwin" ]]',
    },
    linux: {
      command: "arch",
      symbol: " ",
      style: "bright-black",
      when: '[[ "$(uname)" == "Linux" ]]',
    },
  },
};

function generatingFullModulesConfig(
  baseConfig: ConfigBlock,
  modulesConfig: { [key: string]: ConfigBlock },
): { [key: string]: ConfigBlock } {
  return Object.fromEntries(
    Object.entries(modulesConfig).map(([moduleName, moduleConfig]) => {
      const fullConfig: ConfigBlock = {
        disabled: false,
        ...baseConfig,
        ...moduleConfig,
      };
      const isFirstItem = fullConfig?.first_item_in_line ?? false;
      if ("content" in fullConfig) {
        fullConfig.format = isFirstItem
          ? genericFormat(fullConfig.content)
          : genericFormatWithSeparator(fullConfig.content);
        fullConfig.content = null;
      }
      if (isFirstItem) fullConfig.first_item_in_line = null;
      return [moduleName, fullConfig];
    }),
  );
}

const starshipConfig = {
  format: starshipSpec.layout.map((m) => `$${m}`).join(""),
  ...generatingFullModulesConfig(
    starshipSpec.coreModuleBaseConfig,
    starshipSpec.coreModules,
  ),
  ...generatingFullModulesConfig(
    starshipSpec.extensionModuleBaseConfig,
    starshipSpec.extensionModules,
  ),
  custom: generatingFullModulesConfig(
    starshipSpec.customModuleBaseConfig,
    starshipSpec.customModules,
  ),
};

const tomlString = stringify(starshipConfig);
const schemaLine = `"$schema" = 'https://starship.rs/config-schema.json'`;
const finalToml = `${schemaLine}\n\n${tomlString}`;

const outputPath = path.join(home, ".config", "starship", "starship.toml");
fs.writeFileSync(outputPath, finalToml);

console.log(`Successfully generated starship config at ${outputPath}`);
