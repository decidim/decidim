# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "decidim/gem_manager"
require "json"
require "net/http"
require "open3"
require "rubygems"
require "uri"

module Decidim
  # Provides utilities for performing the releases.
  class ReleaseManager
    RUBYGEMS_VERSIONS_URL = "https://rubygems.org/api/v1/versions/decidim.json"

    # Resolves the remote where the tags will be pushed during the release.
    def self.git_remote
      @git_remote ||= `git remote -v | grep -e 'decidim/decidim\\([^ ]*\\) (push)' | sed 's/\\s.*//'`.strip
    end

    def self.git_remote_set?
      git_remote.present?
    end

    # Resolves the npm dist-tag used when publishing the packages. It can be
    # overridden with the NPM_TAG environment variable.
    def self.npm_tag(version = GemManager.version)
      override = ENV.fetch("NPM_TAG", nil)
      return override if override.present?

      gem_version = Gem::Version.new(version)

      return "next" if gem_version.prerelease?
      return "latest" if gem_version >= latest_stable_version

      "release-#{gem_version.segments.first(2).join(".")}"
    end

    # Builds the npm publish command for the given version. The `latest` tag is
    # omitted on purpose so that npm applies it as the default tag. This keeps
    # npm's own protection against moving the `latest` tag to an older version
    # if a newer stable version has been published in the meantime.
    def self.npm_publish_command(version = GemManager.version)
      tag = npm_tag(version)

      return "npm publish --access public" if tag == "latest"

      "npm publish --access public --tag #{tag}"
    end

    # Resolves the latest stable Decidim version published to RubyGems.
    def self.latest_stable_version
      versions = JSON.parse(Net::HTTP.get(URI(RUBYGEMS_VERSIONS_URL)))

      versions
        .reject { |release| release["prerelease"] }
        .map { |release| Gem::Version.new(release["number"]) }
        .max
    end
  end
end
