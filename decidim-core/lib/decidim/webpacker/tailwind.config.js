// GEM_PATH is the shell output of: gem env gemdir
module.exports = {
  content: ["./app/**/*.{html,erb,js,rb}", `${GEM_PATH}/**/decidim-*/app/**/*.{html,erb,js,rb}`],
  theme: {
    colors: {
      primary: "var(--primary)",
      secondary: "var(--secondary)"
    },
    container: {
      center: true
    },
    fontFamily: {
      "sans": ["Source Sans Pro", "ui-sans-serif", "system-ui", "sans-serif"]
    },
    fontSize: {
      xs: ["0.813rem", "16px"],
      sm: ["0.875rem", "18px"],
      md: ["1rem", "20px"],
      lg: ["1.125rem", "23px"],
      xl: ["1.25rem", "25px"],
      "2xl": ["1.5rem", "30px"],
      "3xl": ["1.75rem", "35px"],
      "4xl": ["2rem", "40px"],
      "5xl": ["2.25rem", "45px"],
      "6xl": ["2.625rem", "53px"],
      "7xl": ["3rem", "60px"],
      "8xl": ["3.375rem", "68px"]
    }
  },
  plugins: [
    require("@tailwindcss/typography")
  ]
}
