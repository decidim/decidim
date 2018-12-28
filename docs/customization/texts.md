# Custom Texts

You can change most of the texts through the Administration panel.

If you want to change a given text that isn’t on the Administration panel, and belongs on Decidim code, you should first find out which key is being used. For instance, you want to change the home page text where it says "Let's build a more open, transparent and collaborative society.", you would search the text (using [github](https://github.com/decidim/decidim/search?utf8=%E2%9C%93&q=%22Let%27s+build+a+more+open%2C+transparent+and+collaborative+society.%22&type= ) or grep) and then you would extract that key and their parents. On this case it’d be:

```yml
en:
  pages:
    home:
      footer_sub_hero:
        footer_sub_hero_body: Let's build a more open, transparent and collaborative society.<br /> Join, participate and decide.
```

You need to create a file for this translation as [Ruby on Rails i18n documentation](http://guides.rubyonrails.org/i18n.html) says, for instance config/locales/home.en.yml

## By organization

To have different translations by organization on a multitenant (for instance, if an organization would want to call *Councils* instead of *Assemblies*), you'll need to make these steps:

* Add a new file to `config/locales/` with a new regional. For instance we'll call it **"es-CST"**

* Add a new file for datepicker locales on `vendor/assets/javascripts/datepicker-locales/foundation-datepicker.es-CST.js`, based on availables languages.

* Change your available locales on `config/initializers/decidim.rb`:

```ruby
  config.available_locales = [:en, :ca, :es, :"es-CST"]
```

* Add the fallback language on `config/application.rb`:

```ruby
  config.i18n.fallbacks = { 'es-CST' => 'es' }
```

* Create the organization on System panel with the new language.

At the moment this solution has two handicaps:

* It's only possible to do it with new Organizations
* It's ugly at the URL level (?locale=es-CST)
