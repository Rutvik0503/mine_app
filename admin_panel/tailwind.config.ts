import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        background: "#0B0F1A",
        surface: "#141A2A",
        surfaceElevated: "#1C2338",
        border: "#2A3350",
        primary: "#FF8A1E",
        secondary: "#3DDC97",
      },
    },
  },
  plugins: [],
};

export default config;
