# frozen_string_literal: true

namespace :decidim_elections do
  IDENTIFICATION_PRIVATE_KEY_SIZE = 4096

  desc "Add a new client to the bulletin board"
  task :generate_identification_keys do
    identification_jwk_keypair = JWT::JWK.new(OpenSSL::PKey::RSA.new(IDENTIFICATION_PRIVATE_KEY_SIZE))

    puts "\nPRIVATE KEY:"
    puts "\n"
    puts Decidim::BulletinBoard::JwkUtils.private_export(identification_jwk_keypair).to_json
    puts "\n"
    puts "PUBLIC KEY:"
    puts "\n"
    puts identification_jwk_keypair.export.map { |k, v| "#{k}=#{v}" }.join("&")
    puts "\nAbove are the generated private and public keys.\n\nSee Decidim docs at docs/services/bulletin_board.md in order to set them up.\n\n"
  end

  desc "Scheduled tasks"
  task :scheduled_tasks do
    Decidim::Elections::ElectionsReadyToOpen.for.each do |election|
      puts "\nOpening Election ##{election.id}:"
      form = Decidim::Elections::Admin::BallotBoxForm.new.with_context(election: election, current_user: nil)
      Decidim::Elections::Admin::OpenBallotBox.call(form) do
        on(:ok) do
          puts "\n✓ Ballot Box opened. New bulletin board status: #{election.bb_status}\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Ballot Box not opened. Message: #{message}\n"
        end
      end
      puts "\n"
    end

    Decidim::Elections::ElectionsFinishedToClose.for.each do |election|
      puts "\nClosing Election ##{election.id}:"
      form = Decidim::Elections::Admin::BallotBoxForm.new.with_context(election: election, current_user: nil)
      Decidim::Elections::Admin::CloseBallotBox.call(form) do
        on(:ok) do
          puts "\n✓ Ballot Box closed. New bulletin board status: #{election.bb_status}\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Ballot Box not closed. Message: #{message}\n"
        end
      end
      puts "\n"
    end

    Decidim::Elections::Votes::PendingVotes.for.each do |vote|
      puts "\nChecking status for Vote #{vote.id}:"
      Decidim::Elections::Voter::UpdateVoteStatus.call(vote) do
        on(:ok) do
          puts "\n✓ Vote status updated\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Vote status failed. Message: #{message}\n"
        end
      end
    end
  end
end
