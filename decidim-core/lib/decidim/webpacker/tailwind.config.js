const { inherit, current, transparent, white } = require("tailwindcss/colors")

module.exports = {
  content: [
    "./app/**/*.{html,erb,js,rb}",
    "../decidim-*/**/app/**/*.{html,erb,js,rb}"
    // `${process.env.GEM_PATH}/**/decidim-*/**/app/**/*.{html,erb,js,rb}`
  ],
  safelist: [{ pattern: /.*/ }], // Do not purge
  theme: {
    colors: {
      inherit,
      current,
      transparent,
      white,
      primary: "var(--primary, #FF3333)",
      secondary: "var(--secondary, #155ABF)",
      tertiary: "var(--tertiary, #EBC34B)",
      green: "var(--green, #28A745)",
      red: "var(--red, #ED1C24)",
      yellow: "var(--yellow, #FFB703)",
      black: "#020203",
      gray: {
        DEFAULT: "#C0C6CC",
        2: "#576075"
      },
      background: {
        DEFAULT: "#FAFBFC",
        2: "#F8F8F8",
        3: "#F3F4F7"
      },
      border: {
        DEFAULT: "#C0C6CC",
        2: "#F3F4F7"
      }
    },
    container: {
      center: true
    },
    fontFamily: {
      sans: ["Source Sans Pro", "ui-sans-serif", "system-ui", "sans-serif"]
    },
    fontSize: {
      xs: ["13px", "16px"],
      sm: ["14px", "18px"],
      md: ["16px", "20px"],
      lg: ["18px", "23px"],
      xl: ["20px", "25px"]
    }
  },
  plugins: [require("@tailwindcss/typography")]
};
