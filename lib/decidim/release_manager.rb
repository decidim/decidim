# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "open3"

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
  end
end
