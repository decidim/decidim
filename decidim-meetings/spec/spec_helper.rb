# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

require "decidim/forms/test"
require "decidim/comments/test"
require "decidim/meetings/test/translated_event"
require "decidim/meetings/test/notifications_handling"
