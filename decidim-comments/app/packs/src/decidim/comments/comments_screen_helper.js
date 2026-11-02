import { screens } from "tailwindcss/defaultTheme";

const smBreakpoint = parseInt(screens.md.replace("px", ""), 10);

export const isMobileScreen = () => window.matchMedia(`(max-width: ${smBreakpoint}px)`).matches;
