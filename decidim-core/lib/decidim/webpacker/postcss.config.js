/* eslint-disable */

module.exports = {
  syntax: 'postcss-scss',
  plugins: [
    // postcss-import must be the very first plugin https://tailwindcss.com/docs/using-with-preprocessors#build-time-imports
    require('postcss-import'),
    require('tailwindcss'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
    require('autoprefixer'),
  ]
}
