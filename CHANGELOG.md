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

### Added

- **decidim-meetings**: Add functionality to enable/disable registration code [\#6698](https://github.com/decidim/decidim/pull/6698)
- **decidim-core**: Adding functionality to report users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-admin**: Adding possibility of unreporting users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)

### Changed

- **Authorization metadata is now encrypted in the database**

As per [\#6947](https://github.com/decidim/decidim/pull/6947), the JSON values for the authorizations' `metadata` and `verification_metadata` columns in the `decidim_authorizations` database table are now automatically encrypted because they can contain identifiable or sensitive personal information connected to a user account. Storing this data in plain text in the database would be a security risk.

You need to do changes to your code if you have been querying these tables in the past through the `Decidim::Authorization` model as follows:

```ruby
Decidim::Authorization.where(
  name: "your_authorization_handler"
).where("metadata ->> 'gender' = ?", "f").find_each do |authorization|
  puts "#{authorization.user.name} is a #{authorization.metadata["gender"]}"
end
```

The problem with this code is that the data in the `metadata ->> 'gender'` column is now encrypted, so your search would not match any records in the database. Instead, you can do the following:

```ruby
Decidim::Authorization.where(
  name: "your_authorization_handler"
).find_each do |authorization|
  next unless authorization.metadata["gender"] == "f"

  puts "#{authorization.user.name} is a #{authorization.metadata["gender"]}"
end
```

As you notice, when you are accessing the `metadata` or `verification_metadata` columns through the Active Record object, you can utilize the data in plain text. This is because the accessor method for these columns will automatically decrypt the data in the hash object.

This is less performant but it is more secure. Security weighs more.

### Fixed

### Removed

- **decidim-core**: Remove legacy 'show statistics' checkbox in Appearance. [\#6575](https://github.com/decidim/decidim/pull/6575)

## Previous versions

Please check [release/0.23-stable](https://github.com/decidim/decidim/blob/release/0.23-stable/CHANGELOG.md) for previous changes.
