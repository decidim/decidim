# Decidim::MaintainersToolbox

Release related tools for the Decidim project.

Tools for releasing, backporting, changelog generating, and working with GitHub

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

This gem is meant to be used outside of bundler/Gemfile so we do not need to bump the version every time we release a new one to each of the releases branch.

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

This gem allows preparing and working with Decidim releases. Is it meant to be used by maintainers of the project. In the near future most of these tools will be used by `decidim-bot`.

The main scripts are `backporter`, `backports_checker`, `changelog_generator` and `releaser`.

### backporter

See [Backports documentation](https://docs.decidim.org/en/develop/develop/backports)

### backports_checker

See [Backports documentation](https://docs.decidim.org/en/develop/develop/backports)

### changelog_generator

Used for generating the changelog with all the Pull Requests that goes to the current release. To be used automatically by the `releaser` script.

### releaser

See [Releasing new versions documentation](https://docs.decidim.org/en/develop/develop/maintainers/releases)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/decidim/decidim.
