# frozen_string_literal: true

namespace :decidim_elections do
  desc "Add a new client to the bulletin board"

  IDENTIFICATION_PRIVATE_KEY_SIZE = 4096

  task :generate_identification_keys do
    identification_private_key = OpenSSL::PKey::RSA.new(IDENTIFICATION_PRIVATE_KEY_SIZE)

    puts identification_private_key.to_s
    puts "\n"
    puts identification_private_key.public_key.to_s
    puts "\nAbove are the generated private and public keys.\n\nSee Decidim docs at docs/services/bulletin_board.md in order to set them up.\n\n"
  end
end
