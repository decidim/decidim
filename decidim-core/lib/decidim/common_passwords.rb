# frozen_string_literal: true

module Decidim
  class CommonPasswords
    include Singleton

    attr_reader :passwords

    URLS = %w(
      https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/xato-net-10-million-passwords-1000000.txt
      https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/darkweb2017-top10000.txt
      https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt
    ).freeze

    def initialize
      file_path = File.join(__dir__, "db", "password-list.txt")
      update_passwords! unless File.exist?(file_path)

      File.open(file_path, "r") do |file|
        @passwords = file.read.split
      end
    end

    def update_passwords!
      File.open(File.join(__dir__, "db", "password-list.txt"), "w") do |file|
        common_password_list.each { |item| file.puts(item) }
      end
    end

    private

    def common_password_list
      @common_password_list ||= begin
        list = []
        URLS.each do |url|
          URI.open(url) do |data|
            data.read.split.each do |line|
              list << line if line.length >= min_length
            end
          end
        end

        list.uniq
      end
    end

    def min_length
      return ::PasswordValidator::MINIMUM_LENGTH if defined?(::PasswordValidator)

      10
    end
  end
end
