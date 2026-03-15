/**
 * JS companion for mpizenberg/elm-url-navigation-port.
 *
 * Bridges Elm ports to the History API.
 *
 * @example
 * import * as Navigation from "elm-url-navigation-port";
 *
 * const app = Elm.Main.init({
 *   node: document.getElementById("app"),
 *   flags: location.href,
 * });
 *
 * Navigation.init({
 *   navCmd: app.ports.navCmd,
 *   onNavEvent: app.ports.onNavEvent,
 * });
 */

/**
 * Wire up navigation ports and the popstate listener.
 *
 * @param {Object} ports
 * @param {Object} ports.navCmd     - Elm outgoing command port (has `.subscribe`)
 * @param {Object} ports.onNavEvent - Elm incoming event port (has `.send`)
 */
export function init(ports) {
  function sendNavigation(state) {
    ports.onNavEvent.send({ href: location.href, state: state });
  }

  ports.navCmd.subscribe(function (msg) {
    switch (msg.tag) {
      case "pushUrl":
        history.pushState(null, "", msg.url);
        sendNavigation(null);
        break;

      case "pushState":
        history.pushState(msg.state, "", msg.url);
        sendNavigation(msg.state);
        break;

      case "replaceUrl":
        history.replaceState(history.state, "", msg.url);
        // No sendNavigation — Elm is not notified.
        // The model is the source of truth for replaceUrl updates.
        break;

      case "go":
        history.go(msg.steps);
        // No sendNavigation — popstate fires automatically.
        break;
    }
  });

  window.addEventListener("popstate", function (event) {
    sendNavigation(event.state);
  });
}

// Explanation(compatibility): when using `esbuild --bundle`
// functions are no longer exported, hence not `import`-able.
// Therefore export instead through `window`.
window.Navigation.init = init;

