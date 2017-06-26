# frozen_string_literal: true

module Decidim
  # Decidim::Dev holds all the convenience logic and libraries to be able to
  # create external libraries that create test apps and test themselves against
  # them.
  module Dev
    # Public: Finds an asset.
    #
    # Returns a String with the path for a particular asset.
    def self.asset(name)
      File.expand_path(File.join(__dir__, "dev", "assets", name))
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
