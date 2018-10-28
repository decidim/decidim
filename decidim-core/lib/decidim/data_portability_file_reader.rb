# frozen_string_literal: true

module Decidim
  # This class generates the information needed to be read by DataPortability.
  # It creates the file_name, file_path, check that the token is valid and generates the token if no exists. Originally
  # meant for DataPortability functionality and adding user images to this file, but other usage can be found.
  class DataPortabilityFileReader
    # Public: Initialize the reader with a user, and token
    #
    # user     - The user of data portability to be zipped.
    # token    - The token to be send by email, and return to controller.
    def initialize(user, token = nil)
      @user = user
      @organization = user.organization
      @token = token
    end

    # Returns a String with the filename of the file to be read or generate.
    def file_name
      name = ""
      name += @user.nickname
      name += "-"
      name += @organization.name.parameterize
      name += "-"
      name += token
      name + ".zip"
    end

    # Returns a String with the absolute file_path to be read or generate.
    def file_path
      directory_name = Rails.root.join(Decidim::DataPortabilityUploader.new.store_dir)
      FileUtils.mkdir_p(directory_name) unless File.exist?(directory_name)
      directory_name + file_name
    end

    def file_path_reader
      Decidim::DataPortabilityUploader.new.retrieve_from_store!(file_name)
    end

    # Check if token is present and length equal 10
    def valid_token?
      token.present? && token.length == 10
    end

    # Returns a the token or generate a new one
    def token
      @token ||= generate_new_token
    end

    private

    def generate_new_token
      SecureRandom.base58(10)
    end
  end
end
