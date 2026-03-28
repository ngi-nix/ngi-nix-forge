import { init as initNavigationPort } from "./Navigation.js";
import { getInitialTheme, initThemePort } from "./ThemeSwitch.js";
import { initClipboardListener } from "./Clipboard.js";
import {
  getInitialFlakePreference,
  initFlakePreferencePort,
} from "./FlakePreference.js";

const startingFlakePreference = getInitialFlakePreference();
const startingTheme = getInitialTheme();

// init state
const app = Elm.Main.init({
  node: document.getElementById("elm-main"),
  flags: {
    href: location.href,
    theme: startingTheme,
    prefersFlakes: startingFlakePreference,
  },
});

// register ports

initClipboardListener(app);

initNavigationPort({
  navCmd: app.ports.navCmd,
  onNavEvent: app.ports.onNavEvent,
});

initFlakePreferencePort(app);

initThemePort(app);
