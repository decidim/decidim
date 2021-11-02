# frozen_string_literal: true

namespace :decidim do
  namespace :common_passwords do
    desc "Update common passwords list"
    task :update do
      urls = %w(
        https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/xato-net-10-million-passwords-1000000.txt
        https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/darkweb2017-top10000.txt
        https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt
      )

      list = []
      urls.each do |url|
        URI.open(url) do |data|
          data.read.split.each do |line|
            list << line
          end
        end
      end

      list = list.select { |item| item.length >= ::PasswordValidator::MINIMUM_LENGTH }.uniq

      if list.length.positive?
        File.open(File.join(__dir__, "..", "..", "decidim-core", "lib", "decidim", "db", "dictionary.txt"), "w") do |file|
          list.each { |item| file.puts(item) }
        end
      end
    end
  end
end
