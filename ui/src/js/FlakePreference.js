const getInitialFlakePreference = () => {
  // flakes is the default (true) unless explicitly set to "false"
  const stored = localStorage.getItem("prefers-flakes");
  return stored !== "false";
};

const initFlakePreferencePort = (app) => {
  app.ports.saveFlakePreference.subscribe((isFlakes) => {
    localStorage.setItem("prefers-flakes", isFlakes ? "true" : "false");
  });
};

export { getInitialFlakePreference, initFlakePreferencePort };
