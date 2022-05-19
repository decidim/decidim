// GEM_PATH is the shell output of: gem env gemdir
module.exports = {
  content: ["./app/**/*.{html,erb,js,rb}", `${GEM_PATH}/**/decidim-*/app/**/*.{html,erb,js,rb}`],
  theme: {
    extend: {}
  },
  plugins: []
}
