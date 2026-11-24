# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "decidim/gem_manager"
require "open3"
require "rubygems"

module Decidim
  # Provides utilities for performing the releases.
  class ReleaseManager
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

      "latest"
    end
  end
end
