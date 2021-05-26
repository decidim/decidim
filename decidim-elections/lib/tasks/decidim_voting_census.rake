# frozen_string_literal: true

namespace :decidim_votings_census do
  # Removes the census access code export files older than the configured expiry time.
  desc "Deletes the census access codes export file `Decidim::Votings::Census.census_access_codes_export_expiry_time` from now."
  task delete_census_access_codes_export: :environment do
    puts "DELETE CENSUS ACCESS CODES EXPORT: -------------- START"
    uploader = Decidim::Votings::Census::VotingCensusUploader.new
    case uploader.provider
    when "file" # file system
      puts "Deleting files from filesystem..."
      delete_census_access_codes_export_files_from_fs(uploader)
    when "aws"
      puts "Deleting files from aws..."
      delete_census_access_codes_export_files_from_aws(uploader)
    else
      raise "Carrierwave fog_provider not supported: #{uploader.fog_provider}"
    end
    puts "DELETE CENSUS ACCESS CODES EXPORT: --------------- END"
  end

  # Removes the census access code files older than the configured expiry time from the file system.
  def delete_census_access_codes_export_files_from_fs(uploader)
    path = uploader.store_dir
    Dir.glob(Rails.root.join(path, "*")).each do |filename|
      next unless File.mtime(filename) < Decidim::Votings::Census.census_access_codes_export_expiry_time.ago

      puts "------"
      puts "!! deleting: #{filename}"
      File.delete(filename)
      puts "ok----"
    end
  end

  # Removes the census access code files older than the configured expiry time from AWS.
  def delete_census_access_codes_export_files_from_aws(uploader)
    files = get_census_files_from_aws(uploader.store_path)
    files.each do |file|
      next unless file.last_modified < Decidim::Votings::Census.census_access_codes_export_expiry_time.ago

      puts "------"
      puts "!! deleting: #{file.key}"
      file.delete
      puts "ok----"
    end
  end

  # Retrieves the list of files in the voting census dir.
  #
  # Return [Fog::AWS::Storage::File]
  def get_census_files_from_aws(census_path)
    fog_credentials = CarrierWave::Uploader::Base.fog_credentials
    s3 = Fog::Storage.new(fog_credentials)
    census_dir = s3.directories.get(CarrierWave::Uploader::Base.fog_directory, prefix: census_path)
    census_dir.files
  end
end
