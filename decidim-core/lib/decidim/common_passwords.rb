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
      raise FileNotFoundError unless File.exist?(self.class.common_passwords_path)

      File.open(self.class.common_passwords_path, "r") do |file|
        @passwords = file.read.split
      end
    end

    def self.update_passwords!
      File.open(common_passwords_path, "w") do |file|
        common_password_list.each { |item| file.puts(item) }
      end
    end

    def self.common_password_list
      @common_password_list ||= begin
        list = []
        URLS.each do |url|
          URI.parse(url).open do |data|
            data.read.split.each do |line|
              list << line if line.length >= min_length
            end
          end
        end

        list.uniq
      end
    end

    def self.min_length
      return ::PasswordValidator::MINIMUM_LENGTH if defined?(::PasswordValidator)

      10
    end

    def self.common_passwords_path
      File.join(__dir__, "db", "common-passwords.txt")
    end

    class FileNotFoundError < StandardError; end
  end
end
