# frozen_string_literal: true

require "webpush"

namespace :decidim do
  namespace :pwa do
    desc "Generates VAPID keys for push notifications"
    task :generate_vapid_keys do
      vapid_key = Webpush.generate_key

      puts("VAPID keys correctly generated.")
      puts("*******************************")
      puts("VAPID private key is #{vapid_key.private_key}")
      puts("VAPID public key is #{vapid_key.public_key}")
    end
  end
end
