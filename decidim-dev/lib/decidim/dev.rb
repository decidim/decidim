# frozen_string_literal: true

require "decidim/dev/railtie"

# The next 4 uncommented lines are used to register the Decidim::DummyResources namespace to the autoloader
# We cannot rely on Rails autoloading because some of the classes that are required within that namespace
# are needed before Rails is being available (e.g. FactoryBot)
# After 1 day of various attempts, this is the only way I found to make it work.
app_paths = %w(commands controllers events forms jobs mailers models presenters serializers)
app_paths.each do |path|
  ActiveSupport::Dependencies.autoload_paths += [File.absolute_path("#{__dir__}/../../app/#{path}")]
end

module Decidim
  # Decidim::Dev holds all the convenience logic and libraries to be able to
  # create external libraries that create test apps and test themselves against
  # them.
  module Dev
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
