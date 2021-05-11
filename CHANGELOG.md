# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

#### Webpacker migration
As per [#7464](https://github.com/decidim/decidim/pull/7464), [#7733](https://github.com/decidim/decidim/pull/7733) Decidim has been upgraded to use Webpacker to manage its assets. It's a huge change that requires some updates in your applications. Please refere to the guide [Migrate to Webpacker an instance app](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_app.adoc) and follow the steps described.

#### Improved menu api
As per [#7368](https://github.com/decidim/decidim/pull/7368), [#7382](https://github.com/decidim/decidim/pull/7382) the entire admin structure has been migrated from menus being rendered in partials, to the existing menu structure. Before, this change adding a new menu item to an admin submenu required partial override.

As per  [#7545](https://github.com/decidim/decidim/pull/7545) the menu api has been enhanced to support removal of elements and reordering. All the menu items have an identifier that allow any developer to interact without overriding the entire menu structure. As a result of this change, the old ```menu.item``` function has been deprecated in favour of a more verbose version ```menu.add_item ```, of which first argument is the menu identifier.

Example on adding new elements to a menu:
```ruby
Decidim.menu :menu do |menu|
  menu.add_item :root,
                I18n.t("menu.home", scope: "decidim"),
                decidim.root_path,
                position: 1,
                active: :exclusive

  menu.add_item :pages,
                I18n.t("menu.help", scope: "decidim"),
                decidim.pages_path,
                position: 7,
                active: :inclusive
end
```

Example Customizing the elements of a menu:
```ruby
Decidim.menu :menu do |menu|
  menu.remove_item :pages
  menu.move :root, after: :pages
  # alternative
  menu.move :pages, before: :root
end
```


### Added

* New Menu Api - [#7545](https://github.com/decidim/decidim/pull/7545)

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.24-stable](https://github.com/decidim/decidim/blob/release/0.24-stable/CHANGELOG.md) for previous changes.
