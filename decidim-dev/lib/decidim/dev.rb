# frozen_string_literal: true

require "decidim/dev/railtie"

require "decidim/dev/admin"
require "decidim/dev/engine"
require "decidim/dev/admin_engine"
require "decidim/dev/auth_engine"
# We shall not load the component here, as it will complain there is no method register_component
# for Decidim module. To fix that we need to require 'decidim/core', which will cause a major
# performance setback, as this file is usually the first request in "spec_helpers".
# We load dev component by requiring it later in the stack within lib/decidim/dev/test/base_spec_helper,
# right after decidim/core is required
# This comment and the below line is added to preserve consistency across all modules supplied.
# Also, to avoid further headaches :)
# require "decidim/dev/component"

module Decidim
  # Decidim::Dev holds all the convenience logic and libraries to be able to
  # create external libraries that create test apps and test themselves against
  # them.
  module Dev
    include ActiveSupport::Configurable
    autoload :DummyTranslator, "decidim/dev/dummy_translator"

    # Public: Finds an asset.
    #
    # Returns a String with the path for a particular asset.
    def self.asset(name)
      File.expand_path(File.join(__dir__, "dev", "assets", name))
    end

    # Public: Returns a file for testing, just like file fields expect it
    def self.test_file(filename, content_type)
      Rack::Test::UploadedFile.new(asset(filename), content_type)
    end

    # Public: add rake tasks
    def self.install_tasks
      Dir[File.join(__dir__, "../tasks/*.rake")].each do |file|
        load file
      end
    end

    # Public: Sets the dummy application path for testing.
    #
    # path - A string value defining the path.
    def self.dummy_app_path=(path)
      @dummy_app_path = path
    end

    # Public: Get the dummy application path and raises an error if it is not set.
    def self.dummy_app_path
      unless @dummy_app_path
        raise StandardError, "Please, add Decidim::Dev::dummy_app_path = File.expand_path(File.join(\"..\", \"spec\", \"decidim_dummy_app\")) to\n
          your spec helper with the path to the generated dummy app"
      end
      @dummy_app_path
    end
  end
end
