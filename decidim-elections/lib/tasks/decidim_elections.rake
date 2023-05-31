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
  task :scheduled_tasks, [] => :environment do
    Decidim::Elections::ElectionsReadyToStart.for.each do |election|
      puts "\nStarting vote period for election ##{election.id}:"
      form = Decidim::Elections::Admin::VotePeriodForm.new.with_context(election:, current_user: nil)
      Decidim::Elections::Admin::StartVote.call(form) do
        on(:ok) do
          puts "\n✓ Voting period start requested.\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Voting period not started. Message: #{message}\n"
        end
      end
      puts "\n"
    end

    Decidim::Elections::ElectionsFinishedToEnd.for.each do |election|
      puts "\nEnding vote period for election ##{election.id}:"
      form = Decidim::Elections::Admin::VotePeriodForm.new.with_context(election:, current_user: nil)
      Decidim::Elections::Admin::EndVote.call(form) do
        on(:ok) do
          puts "\n✓ Voting period end requested.\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Voting period not ended. Message: #{message}\n"
        end
      end
      puts "\n"
    end

    Decidim::Elections::Votes::PendingVotes.for.each do |vote|
      puts "\nChecking status for Vote ##{vote.id}:"
      Decidim::Elections::Voter::UpdateVoteStatus.call(vote) do
        on(:ok) do
          puts "\n✓ Vote status updated\n"
        end

        on(:invalid) do |message|
          puts "\n✗ Vote status failed. Message: #{message}\n"
        end
      end
      puts "\n"
    end

    Decidim::Elections::Admin::PendingActions.for.each do |action|
      puts "\nChecking status for action '#{action.action}' for election ##{action.election.id}:"
      Decidim::Elections::Admin::UpdateActionStatus.call(action) do
        on(:ok) do
          puts "\n✓ Action status updated\n"
        end
        on(:invalid) do |message|
          puts "\n✗ Update status failed. Message: #{message}\n"
        end
      end
      puts "\n"
    end
  end
end
