# frozen_string_literal: true

require "webpush"

namespace :decidim do
  namespace :pwa do
    desc "Generates VAPID keys for push notifications"
    task :generate_vapid_keys do
      vapid_key = Webpush.generate_key

      puts("VAPID keys correctly generated.")
      puts("*******************************")
      puts("You have to set the following env vars:\n\n")
      puts("VAPID_PUBLIC_KEY=#{vapid_key.public_key}")
      puts("VAPID_PRIVATE_KEY=#{vapid_key.private_key}")
    end
  end
end
