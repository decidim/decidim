# frozen_string_literal: true

namespace :decidim do
  # RightToBeForgotten ------
  #
  # Load a single CSV file with user_ids list, and deletes all
  #   User records that exists and are not deleted in DB
  #
  # cmd: $ RAILS_ENV=<environment> bundle exec rails decidim:right_to_be_forgotten [FILE_PATH=<relative path to CSV file>]
  #
  # CSV file must be located within project root path
  #
  desc "Deletes User records by ID using a CSV file"
  task right_to_be_forgotten: :environment do
    log = ActiveSupport::Logger.new(Rails.root.join("log/right_to_be_forgotten.log"))
    begin
      path = ENV["FILE_PATH"].presence || "tmp/forgotten_users.csv" # Good file
      file_path = Rails.root.join(path)
      csv_data = CSV.read(file_path, headers: false)
      users_count = csv_data.size
      puts "RightToBeForgotten: ------------------- #{Time.current}"
      log.info "RightToBeForgotten: ------------------- #{Time.current}"
      csv_data.each.with_index(1) do |row, index|
        # Each row, first element must be ID, others are useless
        user_id = row.first.presence || ""
        next unless user_id =~ /^\d+$/ # ID must be numeric only

        if (user = Decidim::User.find_by(id: user_id))
          if user.deleted?
            puts " #{index}/#{users_count} - [#{user_id}] User already deleted"
            log.info " #{index}/#{users_count} - [#{user_id}] User already deleted"
          else
            puts " #{index}/#{users_count} !! [#{user_id}] DELETING USER"
            log.info " #{index}/#{users_count} !! [#{user_id}] DELETING USER"
            Decidim::DestroyAccount.call(user, Decidim::DeleteAccountForm.from_params({})) # Delete user!
          end
        else
          puts " #{index}/#{users_count} - [#{user_id}] User not found"
          log.info " #{index}/#{users_count} - [#{user_id}] User not found"
        end
      end
    rescue CSV::MalformedCSVError
      puts " ERROR: [Malformed CSV] #{path}"
      log.info " ERROR: [Malformed CSV] #{path}"
    rescue Errno::ENOENT
      puts " ERROR: [File not found] #{path}"
      log.info " ERROR: [File not found] #{path}"
    rescue StandardError => e
      puts " ERROR: [Unexpected error] #{e.message}"
      log.info " ERROR: [Unexpected error] #{e.message}"
    ensure
      puts "RightToBeForgotten: Log file created at log/right_to_be_forgotten.log"
      puts "RightToBeForgotten: --------------- END #{Time.current}"
      log.info "RightToBeForgotten: --------------- END #{Time.current}"
    end
  end

  desc "Check and notify users to update their newsletter notifications settings"
  task check_users_newsletter_opt_in: :environment do
    print %(
> This will send an email to all the users that have marked the newsletter by default. This should only be run if you were using Decidim before v0.11
  If you have any doubts regarding this feature, please check the releases notes for this version  https://github.com/decidim/decidim/releases/tag/v0.12
  Are you sure you want to do that? [y/N]: )
    input = $stdin.gets.chomp
    if input.casecmp("y").zero?
      puts %(  Continue...)
      Decidim::User.where("newsletter_notifications_at < ?", Time.zone.parse("2018-05-25 00:00 +02:00")).find_each(&:newsletter_opt_in_notify)
    else
      puts %(  Execution cancelled...)
    end
  end

  desc "Deletes all download your data files previous to `Decidim.download_your_data_expiry_time` from now."
  task delete_download_your_data_files: :environment do
    puts "DELETE DOWNLOAD YOUR DATA FILES: -------------- START"
    attachments = ActiveStorage::Attachment.joins(:blob).where(
      name: "download_your_data_file",
      record_type: "Decidim::UserBaseEntity"
    ).where(
      "active_storage_blobs.created_at < ?", Decidim.download_your_data_expiry_time.ago
    )
    attachments.each do |attachment|
      delete_download_your_data_file attachment
    end
    puts "DELETE DOWNLOAD YOUR DATA FILES: --------------- END"
  end

  def delete_download_your_data_file(attachment)
    puts "------"
    puts "!! deleting: #{attachment.filename}"
    attachment.purge
    puts "ok----"
  end
end
