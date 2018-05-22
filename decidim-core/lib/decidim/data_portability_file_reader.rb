# frozen_string_literal: true

module Decidim
  class DataPortabilityFileReader
    def initialize(user, token = nil)
      @user = user
      @organization = user.organization
      @token = token
    end

    def file_name
      name = ""
      name += @user.nickname
      name += "-"
      name += @organization.name.parameterize
      name += "-"
      name += token
      name + ".zip"
    end

    def file_path
      directory_name = "tmp/data-portability"
      Dir.mkdir(directory_name) unless File.exist?(directory_name)
      Rails.root.join("#{directory_name}/#{file_name}")
    end

    def valid_token?
      token.present? && token.length == 10
    end

    def token
      @token ||= generate_new_token
    end

    private

    def generate_new_token
      Digest::SHA256.hexdigest(Time.current.to_s)[0..9]
    end
  end
end
