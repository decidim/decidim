# Managing translations (i18n)

## The workflow

Decidim uses [Crowdin](https://crowdin.com/) to manage the translations.

- Whenever someone [adds a new translation key](https://github.com/decidim/decidim/pull/1814/files#diff-c78c80097da59920d55b3f462ca21afaR177) to _Decidim_, _Crowdin_ gets notified and the new content is available to be translated from [Crowdin's Decidim dashboard](https://crowdin.com/project/decidim).
- When a translator translates any key from Crowdin, it automatically creates a [PR in Github](https://github.com/decidim/decidim/pull/2207), adding the keys in the corresponding _yaml_ files.
- 🌈

## Adding a new language

- Setup the new language in [_Crowdin's Decidim project_](https://crowdin.com/project/decidim) (or open an issue on Github asking an admin to do that).
- Translate at least one key from every engine, so, your _yaml_ files are not empty. The easiest way to do this is to automatically translate and sync all the content. Later you'll be able to fix the content that wasn't properly translated.
- Add [Foundation Datepicker](https://github.com/najlepsiwebdesigner/foundation-datepicker/tree/master/js/locales)'s translations ([PR](https://github.com/decidim/decidim/pull/2039)).
- Add Select2 translations ([PR](https://github.com/decidim/decidim/pull/2214)).
- Add the new language to `available_locales` ([PR](https://github.com/decidim/decidim/pull/1991)).
- Announce the new language in the Readme ([PR](https://github.com/decidim/decidim/pull/2125)).

## Test the new language

To test the new language in a local development app, first, you need to add the new language to the [initializer template](https://github.com/decidim/decidim/blob/master/lib/generators/decidim/templates/initializer.rb#L9). After that, [create the `development_app` and start the server](https://github.com/decidim/decidim#browse-decidim).
