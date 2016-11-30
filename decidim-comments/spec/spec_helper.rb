ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last
require "decidim/test/base_spec_helper"
require_relative "../../decidim-api/spec/support/type_helpers"