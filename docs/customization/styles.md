# CSS Styles with SASS

One of the first things you’ll want to do after you install Decidim is applying your own corporative image. To do this, you can go to app/assets/stylesheets/application.css.sass on your generated application with your own colors. There you can override any class using CSS with SASS.

In [decidim-core/app/assets/stylesheets/decidim/_variables.scss](https://github.com/decidim/decidim/blob/master/decidim-core/app/assets/stylesheets/decidim/_variables.scss) you can find the `variables` that can be overriden in your `sass`.

We use [SASS, with SCSS syntax](http://sass-lang.com/guide) as CSS preprocessor.

## **Accesibility**

To maintain accesibility level, if you add new colors use a [Color contrast checker](http://webaim.org/resources/contrastchecker/) (WCAG AA is mandatory, WCAG AAA is recommended)
