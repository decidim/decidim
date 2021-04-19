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

  desc "Check and notify users to update her newsletter notifications settings"
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

  desc "Deletes all data portability files previous to `Decidim.data_portability_expiry_time` from now."
  task delete_data_portability_files: :environment do
    puts "DELETE DATA PORTABILITY FILES: -------------- START"
    uploader = Decidim::DataPortabilityUploader.new
    case uploader.provider
    when "file" # file system
      puts "Deleting files from filesystem..."
      delete_data_portability_files_from_fs(uploader)
    when "aws"
      puts "Deleting files from aws..."
      delete_data_portability_files_from_aws(uploader)
    else
      raise "Carrierwave fog_provider not supported: #{uploader.fog_provider}"
    end
    puts "DELETE DATA PORTABILITY FILES: --------------- END"
  end

  def delete_data_portability_files_from_fs(uploader)
    path = uploader.store_dir
    Dir.glob(Rails.root.join(path, "*")).each do |filename|
      next unless File.mtime(filename) < Decidim.data_portability_expiry_time.ago

      puts "------"
      puts "!! deleting: #{filename}"
      File.delete(filename)
      puts "ok----"
    end
  end

  # Removes data portability files older than the configured expiry time.
  #
  # ==== Struct of AWS's File objects:
  #
  # <Fog::AWS::Storage::File
  #   key="uploads/decidim/user/avatar/1056/IMG_20171104_210039_247.jpg",
  #   cache_control=nil,
  #   content_disposition=nil,
  #   content_encoding=nil,
  #   content_length=113294,
  #   content_md5=nil,
  #   content_type=nil,
  #   etag="e5f3c6a85a18d2557ed11c034efb3007",
  #   expires=nil,
  #   last_modified=2018-12-20 15:29:59 UTC,
  #   metadata={},
  #   owner={:display_name=>nil, :id=>"7dad77eea8cfbc10f588314706a02175a97fad81abccfd5747e87a340cc26a34"},
  #   storage_class="STANDARD",
  #   encryption=nil,
  #   encryption_key=nil,
  #   version=nil,
  #   kms_key_id=nil
  # >
  def delete_data_portability_files_from_aws(uploader)
    files = get_data_portability_files_from_aws(uploader.store_path)
    files.each do |file|
      next unless file.last_modified < Decidim.data_portability_expiry_time.ago

      puts "------"
      puts "!! deleting: #{file.key}"
      file.delete
      puts "ok----"
    end
  end

  # Retrieves the list of files in the data portability dir.
  #
  # This method has a high cost as it performs a couple of requests to aws.
  #
  # Return [Fog::AWS::Storage::File]
  def get_data_portability_files_from_aws(data_portability_path)
    fog_credentials = CarrierWave::Uploader::Base.fog_credentials
    s3 = Fog::Storage.new(fog_credentials)
    data_portability_dir = s3.directories.get(CarrierWave::Uploader::Base.fog_directory, prefix: data_portability_path)
    data_portability_dir.files
  end
end
