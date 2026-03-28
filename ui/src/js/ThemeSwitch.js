const setThemeAttribute = (theme) => {
  document.documentElement.setAttribute("data-bs-theme", theme);
};

const getInitialTheme = () => {
  let theme = localStorage.getItem("theme");
  if (!theme) {
    const isDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    theme = isDark ? "dark" : "light";
  }
  setThemeAttribute(theme);
  return theme;
};

const initThemePort = (app) => {
  app.ports.saveTheme.subscribe((theme) => {
    localStorage.setItem("theme", theme);
    setThemeAttribute(theme);
  });
};

export { getInitialTheme, initThemePort };
