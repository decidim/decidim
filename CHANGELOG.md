# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)

### Changed

- **Bump Ruby to v2.7**

We've bumped the minimum Ruby version to 2.7.1, thanks to 2 PRs:

- [\#6320](https://github.com/decidim/decidim/pull/6320)
- [\#6522](https://github.com/decidim/decidim/pull/6522)

- **Comments no longer use react**

As per [\#6498](https://github.com/decidim/decidim/pull/6498), the comments component is no longer implemented with the react component. In case you had customized the react component, it will still work as you would expect as the GraphQL API has not disappeared anywhere. You should, however, gradually migrate to the "new way" (Trailblazer cells) in order to ensure compatibility with future versions too.

- **Consultations module deprecation**

As the new `Votings` module is being developed and will eventually replace the `Consultations` module, the latter enters the deprecation phase.

### Added

- **decidim-meetings**: Add functionality to enable/disable registration code [\#6698](https://github.com/decidim/decidim/pull/6698)
- **decidim-core**: Adding functionality to report users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-admin**: Adding possibility of unreporting users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)
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

PR [\#7986](https://github.com/decidim/decidim/pull/7986) splits some jobs from the `:default` queue to two new queues:

- `:exports`
- `:translations`

If your application uses Sidekiq and you set a manual configuration file, you'll need to update it to add these two new queues. Otherwise these queues [will never run](https://github.com/mperham/sidekiq/issues/4897).

### Added

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.24-stable](https://github.com/decidim/decidim/blob/release/0.24-stable/CHANGELOG.md) for previous changes.
