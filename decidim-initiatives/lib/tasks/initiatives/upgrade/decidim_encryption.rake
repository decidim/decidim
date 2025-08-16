# frozen_string_literal: true

namespace :decidim_initiatives do
  namespace :upgrade do
    task encryption: :environment do
      Decidim::InitiativesVote.find_each do |vote|
        next if vote.encrypted_metadata.blank?

        encryptor = a.send(:encryptor)

        vote.encrypted_metadata = encryptor.encrypt(vote.decrypted_metadata)
        vote.save!
      end
    end
  end
end

Rake::Task["decidim:upgrade:encryption"].enhance do
  Rake::Task["decidim_initiatives:upgrade:encryption"].invoke
end
