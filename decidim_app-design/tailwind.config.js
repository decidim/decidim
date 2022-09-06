const { inherit, current, transparent, white } = require("tailwindcss/colors")

const withOpacity =
  (variable) =>
  ({ opacityValue }) =>
    opacityValue === undefined
      ? `rgb(var(${variable}))`
      : `rgb(var(${variable}) / ${opacityValue})`;

module.exports = {
  // This content is generated automatically by decidim:webpacker:install task, it
  // shouldn't be updated manually.
  // The array must contain all the decidim modules active in the application
  content: ['/home/hugo/populate/decidim/decidim-api','/home/hugo/populate/decidim/decidim-core','/home/hugo/populate/decidim/decidim-comments','/home/hugo/populate/decidim/decidim-accountability','/home/hugo/populate/decidim/decidim-admin','/home/hugo/populate/decidim/decidim-assemblies','/home/hugo/populate/decidim/decidim-blogs','/home/hugo/populate/decidim/decidim-budgets','/home/hugo/populate/decidim/decidim-debates','/home/hugo/populate/decidim/decidim-forms','/home/hugo/populate/decidim/decidim-generators','/home/hugo/populate/decidim/decidim-meetings','/home/hugo/populate/decidim/decidim-pages','/home/hugo/populate/decidim/decidim-participatory_processes','/home/hugo/populate/decidim/decidim-proposals','/home/hugo/populate/decidim/decidim-sortitions','/home/hugo/populate/decidim/decidim-templates','/home/hugo/populate/decidim/decidim-surveys','/home/hugo/populate/decidim/decidim-system','/home/hugo/populate/decidim/decidim-verifications','/home/hugo/.rbenv/versions/3.1.1/lib/ruby/gems/3.1.0/gems/decidim-bulletin_board-0.23.0','/home/hugo/populate/decidim/decidim-conferences','/home/hugo/populate/decidim/decidim-consultations','/home/hugo/populate/decidim/decidim-dev','/home/hugo/populate/decidim/decidim-elections','/home/hugo/populate/decidim/decidim-initiatives','.'].flatMap(directory => [
    `${directory}/app/views/**/*.html.erb`,
    `${directory}/app/cells/**/*.{rb,erb}`,
    `${directory}/app/helpers/**/*.rb`,
    `${directory}/app/packs/**/*.js`,
    `${directory}/lib/**/*.rb`
  ]),
  // Comment out the next line to disable purging the tailwind styles
  // safelist: [{ pattern: /.*/ }],
  theme: {
    colors: {
      inherit,
      current,
      transparent,
      white,
      primary: withOpacity("--primary-rgb"),
      secondary: withOpacity("--secondary-rgb"),
      tertiary: withOpacity("--tertiary-rgb"),
      success: withOpacity("--success-rgb"),
      alert: withOpacity("--alert-rgb"),
      warning: withOpacity("--warning-rgb"),
      black: "#020203",
      gray: {
        DEFAULT: "#6B72804D", // 30% opacity
        2: "#3E4C5C",
        3: "#E1E5EF",
        4: "#242424",
        5: "#F6F8FA"
      },
      background: {
        DEFAULT: "#F3F4F7",
        2: "#FAFBFC",
        3: "#EFEFEF",
        4: "#E4EEFF99" // 60% opacity
      }
    },
    container: {
      center: true,
      padding: {
        DEFAULT: "1rem",
        lg: "4rem"
      }
    },
    fontFamily: {
      sans: ["Source Sans Pro", "ui-sans-serif", "system-ui", "sans-serif"]
    },
    fontSize: {
      xs: ["13px", "16px"],
      sm: ["14px", "18px"],
      md: ["16px", "20px"],
      lg: ["18px", "23px"],
      xl: ["20px", "25px"],
      "2xl": ["24px", "30px"],
      "3xl": ["32px", "40px"],
      "4xl": ["36px", "45px"],
    }
  },
  plugins: [require("@tailwindcss/typography")]
}
