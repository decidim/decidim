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

require "decidim/dev/api"

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
      uploaded_file(asset(filename), content_type)
    end

    # Public: Creates a safe uploaded file for tests.
    #
    # Creating instances of Rack::Test::UploadedFile directly from file paths
    # may lead to 0-byte files created in the storage under specific
    # configurations/kernels and specifically with Docker containers. This
    # method creates a safe uploaded file that does not have this problem.
    #
    # See:
    # https://github.com/rails/rails/issues/41991
    # https://github.com/docker/for-mac/issues/5570
    # https://github.com/docker/for-linux/issues/1015
    #
    # @param path [String] The path to the original file
    # @param content_type [String] The MIME type for the file
    # @param binary [Boolean] Boolean indicating whether the uploaded file's
    #   tempfile should be in binary mode
    # @return [Rack::Test::UploadedFile] A new uploaded test file instance
    def self.uploaded_file(path, content_type, binary: false)
      original_filename = File.basename(path)
      extension = File.extname(original_filename)

      tempfile = Tempfile.open([File.basename(original_filename, extension), extension])
      tempfile.binmode if binary
      tempfile.write(binary ? File.binread(path) : File.read(path))
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile, content_type, binary, original_filename:)
    ensure
      tempfile&.close!
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
