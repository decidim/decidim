# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Upgrade the encryption environment"
    task encryption: :environment do
      # Authorization is using the RecordEncryptor which automatically descrypts or encrypts before using.
      # A simple save will retrigger the encryption using SHA256
      Decidim::Authorization.find_each(&:save)
    end
  end
end
