# frozen_string_literal: true

require "decidim/common_passwords"

namespace :decidim do
  namespace :common_passwords do
    desc "Update common passwords list"
    task :update do
      Decidim::CommonPasswords.update_passwords!
    end
  end
end
