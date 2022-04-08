# frozen_string_literal: true

module Decidim
  # A special Spring watcher for Decidim to ignore specific paths from the
  # watching causing excessive use of inodes, issues with CPU usage and with
  # startup/stop. This should be loaded at the application's config/spring.rb
  # file.
  module SpringWatcher
    def start
      super
      listener.ignore(/^(node_modules|storage|tmp)/)
    end
  end
end

Spring::Watcher::Listen.prepend Decidim::SpringWatcher
