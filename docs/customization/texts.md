# Custom Texts

You can change most of the texts through the Administration panel.

If you want to change a given text that isn’t on the Administration panel, and belongs on Decidim code, you should first find out which key is being used. For instance, we want to change the home page text where it says "Let's build a more open, transparent and collaborative society.", we would search the text (using [github](https://github.com/decidim/decidim/search?utf8=%E2%9C%93&q=%22Let%27s+build+a+more+open%2C+transparent+and+collaborative+society.%22&type= ) or grep) and then I’d extract that key and their parents. On this case it’d be:

```yml
en:
  pages:
    home:
      footer_sub_hero:
        footer_sub_hero_body: Let's build a more open, transparent and collaborative society.<br /> Join, participate and decide.
```

We need to create a file for this translation as Rails documentation says, for instance config/locales/home.en.yml
