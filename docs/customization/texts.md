# Custom Texts

## Using custom locales

You can change most of the texts through the Administration panel.

If you want to change a given text that isn’t on the Administration panel, and belongs on Decidim code, you should first find out which key is being used. For instance, you want to change the home page text where it says "Let's build a more open, transparent and collaborative society.", you would search the text (using [github](https://github.com/decidim/decidim/search?utf8=%E2%9C%93&q=%22Let%27s+build+a+more+open%2C+transparent+and+collaborative+society.%22&type= ) or grep) and then you would extract that key and their parents. On this case it’d be:

```yml
en:
  pages:
    home:
      footer_sub_hero:
        footer_sub_hero_body: Let's build a more open, transparent and collaborative society.<br /> Join, participate and decide.
```

You need to create a file for this translation as [Ruby on Rails i18n documentation](http://guides.rubyonrails.org/i18n.html) says, for instance config/locales/home.en.yml, you can see a currently working example in [this PR](https://github.com/AjuntamentdeBarcelona/decidim-barcelona/pull/206).

## Using external module

There is an external module [decidim-term_customizer](https://github.com/mainio/decidim-module-term_customizer), according with the project README:

> The module allows administrators to add "translation sets" through the admin panel which contain customized terms for any module in the system. These sets can be applied against different scopes within the system, e.g. the whole system, participatory space scope (e.g. all participatory processes or a specific participatory process) or a specific component within a participatory space.

To implement this on your decidim installation follow the [documentation in the external module](https://github.com/mainio/decidim-module-term_customizer/blob/master/README.md).

You can see an example in [this PR](https://github.com/decidim/metadecidim/pull/38).
