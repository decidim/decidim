ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last
require "test/base_spec_helper"
require 'pundit/matchers'
