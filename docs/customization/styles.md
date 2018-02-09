# CSS Styles with SASS

One of the first things you’ll want to do after you install Decidim is applying your own corporative image. To do this, you can go to app/assets/stylesheets/application.css.sass on your generated application with your own colors. There you can override any class using CSS with SASS.

We use [SASS, with SCSS syntax](http://sass-lang.com/guide) as CSS preprocessor.

Also you can check your scss files syntax with

```bash
$ scss-lint
# Will show a report of scss code violations.
```

## **Accesibility**

To maintain accesibility level, if you add new colors use a [Color contrast checker](http://webaim.org/resources/contrastchecker/) (WCAG AA is mandatory, WCAG AAA is recommended)
