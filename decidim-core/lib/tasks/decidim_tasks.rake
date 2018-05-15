# frozen_string_literal: true

namespace :decidim do
  desc "Install migrations from Decidim to the app."
  task upgrade: ["railties:install:migrations"]

  task right_to_be_forgotten: :environment do
    begin
      puts "RightToBeForgotten: -------------------"
      path = ENV["FILE_PATH"].presence || "tmp/forgotten_users.csv" # Good file
      file_path = Rails.root.join(path)
      CSV.foreach(file_path, headers: false) do |row|
        # Each row, first element must be ID, others are useless
        user_id = row.first.presence || ""
        next unless user_id =~ /^\d+$/ # ID must be numeric only

        if (user = Decidim::User.find_by(id: user_id))
          if user.deleted?
            puts "  - [#{user_id}] User already deleted"
          else
            puts " !! [#{user_id}] DELETING USER"
            Decidim::DestroyAccount.call(user, Decidim::DeleteAccountForm.from_params({})) # Delete user!
          end
        else
          puts "  - [#{user_id}] User not found"
        end
      end
    rescue CSV::MalformedCSVError
      puts " ERROR: [Malformed CSV] #{path}"
    rescue Errno::ENOENT
      puts " ERROR: [File not found] #{path}"
    rescue StandardError => e
      puts " ERROR: [Unexpected error] #{e.message}"
    ensure
      puts "RightToBeForgotten: --------------- END"
    end
  end
end
