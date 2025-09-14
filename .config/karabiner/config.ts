import { promises } from "fs";

// TODO: migrate to use this https://github.com/evan-liu/karabiner.ts
// https://genesy.github.io/karabiner-complex-rules-generator/

const rules = [
  {
    description: "Capslock -> Hyper",
    manipulators: [
      {
        from: { key_code: "caps_lock", modifiers: { optional: ["any"] } },
        to: [
          {
            key_code: "left_command",
            modifiers: ["left_control", "left_option"],
          },
        ],
        type: "basic",
      },
    ],
  },
  {
    description: "RCommand -> Modifier",
    manipulators: [
      {
        from: { key_code: "right_command", modifiers: { optional: ["any"] } },
        to: [{ set_variable: { name: "rcommand", value: 1 } }],
        to_after_key_up: [{ set_variable: { name: "rcommand", value: 0 } }],
        type: "basic",
      },
    ],
  },
  {
    description: "Arrow",
    manipulators: [
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "e", modifiers: { optional: ["any"] } },
        to: [{ key_code: "up_arrow" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "f", modifiers: { optional: ["any"] } },
        to: [{ key_code: "right_arrow" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "d", modifiers: { optional: ["any"] } },
        to: [{ key_code: "down_arrow" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "s", modifiers: { optional: ["any"] } },
        to: [{ key_code: "left_arrow" }],
        type: "basic",
      },
    ],
  },
  {
    description: "Del",
    manipulators: [
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "w", modifiers: { optional: ["any"] } },
        to: [{ key_code: "delete_forward" }],
        type: "basic",
      },
    ],
  },
  {
    description: "Backquote & Escape",
    manipulators: [
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: {
          key_code: "grave_accent_and_tilde",
          modifiers: { optional: ["any"] },
        },
        to: [{ key_code: "grave_accent_and_tilde" }],
        type: "basic",
      },
      {
        from: {
          key_code: "grave_accent_and_tilde",
          modifiers: { optional: ["any"] },
        },
        to: [{ key_code: "escape" }],
        type: "basic",
      },
    ],
  },
  {
    description: "f1-f12",
    manipulators: [
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "1", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f1" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "2", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f2" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "3", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f3" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "4", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f4" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "5", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f5" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "6", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f6" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "7", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f7" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "8", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f8" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "9", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f9" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "0", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f10" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "hyphen", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f11" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "equal_sign", modifiers: { optional: ["any"] } },
        to: [{ key_code: "f12" }],
        type: "basic",
      },
    ],
  },
  {
    description: "Home, End, PageUp, PageDown",
    manipulators: [
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "i", modifiers: { optional: ["any"] } },
        to: [{ key_code: "page_up" }],
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "k", modifiers: { optional: ["any"] } },
        to: [{ key_code: "page_down" }],
        type: "basic",
      },
      // Use Home/End for terminal
      {
        conditions: [
          { name: "rcommand", type: "variable_if", value: 1 },
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["kitty$"],
          },
        ],
        from: { key_code: "j", modifiers: { optional: ["any"] } },
        to: { key_code: "home" },
        type: "basic",
      },
      {
        conditions: [
          { name: "rcommand", type: "variable_if", value: 1 },
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["kitty$"],
          },
        ],
        from: { key_code: "l", modifiers: { optional: ["any"] } },
        to: { key_code: "end" },
        type: "basic",
      },
      // Use Ctrl + left/right for other apps
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "j", modifiers: { optional: ["any"] } },
        to: { key_code: "left_arrow", modifiers: ["left_command"] },
        type: "basic",
      },
      {
        conditions: [{ name: "rcommand", type: "variable_if", value: 1 }],
        from: { key_code: "l", modifiers: { optional: ["any"] } },
        to: { key_code: "right_arrow", modifiers: ["left_command"] },
        type: "basic",
      },
    ],
  },
  {
    description: "Command Backspace -> Option Backspace",
    manipulators: [
      {
        from: {
          key_code: "delete_or_backspace",
          modifiers: { mandatory: ["left_command"], optional: ["any"] },
        },
        to: { key_code: "delete_or_backspace", modifiers: ["left_option"] },
        type: "basic",
      },
    ],
  },
  {
    // Move cursor by word
    description: "Command Left/Right -> Option Left/Right",
    manipulators: [
      {
        from: {
          key_code: "left_arrow",
          modifiers: { mandatory: ["left_command"], optional: ["any"] },
        },
        to: { key_code: "left_arrow", modifiers: ["left_option"] },
        type: "basic",
      },
      {
        from: {
          key_code: "right_arrow",
          modifiers: { mandatory: ["left_command"], optional: ["any"] },
        },
        to: { key_code: "right_arrow", modifiers: ["left_option"] },
        type: "basic",
      },
    ],
  },

  // Application specific
  {
    description: "LCommand -> LCtrl (Terminal)",
    manipulators: [
      {
        conditions: [
          { type: "frontmost_application_if", bundle_identifiers: ["kitty$"] },
        ],
        from: {
          key_code: "left_command",
          modifiers: { optional: ["any"] },
        },
        to: { key_code: "left_control" },
        type: "basic",
      },
    ],
  },
  {
    // Firefox prev/next tab
    // Cannot be mapped in system preferences
    description: "Commnd J/L -> Cmd + Opt + Left/Right (Firefox)",
    manipulators: [
      {
        conditions: [
          { type: "frontmost_application_if", bundle_identifiers: ["firefox"] },
        ],
        from: { key_code: "j", modifiers: { mandatory: ["left_command"] } },
        to: {
          key_code: "left_arrow",
          modifiers: ["left_command", "left_option"],
        },
        type: "basic",
      },
      {
        conditions: [
          { type: "frontmost_application_if", bundle_identifiers: ["firefox"] },
        ],
        from: { key_code: "l", modifiers: { mandatory: ["left_command"] } },
        to: {
          key_code: "right_arrow",
          modifiers: ["left_command", "left_option"],
        },
        type: "basic",
      },
    ],
  },
  {
    // Google chrome and Brave (nightly) prev/next tab
    description: "Commnd J/L -> Ctrl (+ Shift) + Tab (Chrome and Brave nightly)",
    manipulators: [
      {
        conditions: [
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["com.google.Chrome", "com.brave.Browser.nightly"],
          },
        ],
        from: { key_code: "l", modifiers: { mandatory: ["left_command"] } },
        to: {
          key_code: "tab",
          modifiers: ["left_control"],
        },
        type: "basic",
      },
      {
        conditions: [
          {
            type: "frontmost_application_if",
            bundle_identifiers: ["com.google.Chrome", "com.brave.Browser.nightly"],
          },
        ],
        from: { key_code: "j", modifiers: { mandatory: ["left_command"] } },
        to: {
          key_code: "tab",
          modifiers: ["left_control", "left_shift"],
        },
        type: "basic",
      },
    ],
  }
];

async function updateConfig() {
  let data = await promises.readFile("default_config.json");
  let config = JSON.parse(data.toString());

  config.profiles[0].name = "IM";
  config.profiles[0].selected = true;

  // Simple modifications are applied before complex modifications.
  config.profiles[0].simple_modifications = [
    {
      from: { key_code: "right_option" },
      to: [{ key_code: "right_option", modifiers: ["left_command"] }],
    },
  ];
  config.profiles[0].complex_modifications.rules = rules;

  await promises.writeFile("karabiner.json", JSON.stringify(config));
}

updateConfig()
  .then(() => console.log("Config updated successfully"))
  .catch((err) => console.log(err));
