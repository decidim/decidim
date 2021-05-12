# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Notes

#### Improved menu api
As per [\#7368](https://github.com/decidim/decidim/pull/7368), [\#7382](https://github.com/decidim/decidim/pull/7382) the entire admin structure has been migrated from menus being rendered in partials, to the existing menu structure. Before, this change adding a new menu item to an admin submenu required partial override.

As per [\#7545](https://github.com/decidim/decidim/pull/7545) the menu api has been enhanced to support removal of elements and reordering. All the menu items have an identifier that allow any developer to interact without overriding the entire menu structure. As a result of this change, the old ```menu.item``` function has been deprecated in favour of a more verbose version ```menu.add_item ```, of which first argument is the menu identifier.

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
  # Completely remove a menu item
  menu.remove_item :my_item

  # Change the items order
  menu.move :root, after: :pages
  # alternative
  menu.move :pages, before: :root
end
```

#### New Job queues
#### Meetings merge minutes and close actions

With changes introduced in [\#7968](https://github.com/decidim/decidim/pull/7968) the `Decidim::Meetings::Minutes` model and related table are removed and the attributes of the previously existing minutes are migrated to `Decidim::Meetings::Meeting` model in the `minutes_description`, `video_url`, `audio_url` and `minutes_visible` columns.

If there is previous activity of creation or edition of minutes, `Decidim::ActionLog` instances and an associated `PaperTrail::Version` instance for each one will have been created pointing to these elements in their polymorphic associations. To avoid errors, the migration includes changing those associations to point to the meeting and changing the action to `close` in the action log items. This change is not reversible (the removal of meetings does, the minutes table is recreated and the instances are generated when there is data in the `down` method)

#### New Job queues

PR [\#7986](https://github.com/decidim/decidim/pull/7986) splits some jobs from the `:default` queue to two new queues:

- `:exports`
- `:translations`

If your application uses Sidekiq and you set a manual configuration file, you'll need to update it to add these two new queues. Otherwise these queues [will never run](https://github.com/mperham/sidekiq/issues/4897).

### Added

### Changed

* Meetings merge minutes and close actions - [\#7968](https://github.com/decidim/decidim/pull/7968)

### Fixed

### Removed

## Previous versions

Please check [release/0.24-stable](https://github.com/decidim/decidim/blob/release/0.24-stable/CHANGELOG.md) for previous changes.
