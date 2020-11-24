# frozen_string_literal: true

namespace :decidim_elections do
  desc "Add a new client to the bulletin board"

  IDENTIFICATION_PRIVATE_KEY_SIZE = 4096

  task :generate_identification_keys do
    identification_jwk_keypair = JWT::JWK.new(OpenSSL::PKey::RSA.new(IDENTIFICATION_PRIVATE_KEY_SIZE))

    puts "\nPRIVATE KEY:"
    puts "\n"
    puts Decidim::Elections::JwkUtils.private_export(identification_jwk_keypair).to_json
    puts "\n"
    puts "PUBLIC KEY:"
    puts "\n"
    puts identification_jwk_keypair.export.map { |k, v| "#{k}=#{v}" }.join("&")
    puts "\nAbove are the generated private and public keys.\n\nSee Decidim docs at docs/services/bulletin_board.md in order to set them up.\n\n"
  end
end
