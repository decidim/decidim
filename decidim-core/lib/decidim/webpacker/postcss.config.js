/* eslint-disable */

module.exports = {
  syntax: 'postcss-scss',
  plugins: [
    // postcss-import must be the very first plugin https://tailwindcss.com/docs/using-with-preprocessors#build-time-imports
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
  ]
}
