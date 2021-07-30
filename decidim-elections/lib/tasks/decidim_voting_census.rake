# frozen_string_literal: true

namespace :decidim_votings_census do
  # Removes the census access code export files older than the configured expiry time.
  desc "Deletes the census access codes export file `Decidim::Votings::Census.census_access_codes_export_expiry_time` from now."
  task delete_census_access_codes_export: :environment do
    puts "DELETE CENSUS ACCESS CODES EXPORT: -------------- START"
    attachments = ActiveStorage::Attachment.joins(:blob).where(
      name: "access_codes_file",
      record_type: "Decidim::Votings::Census::Dataset"
    ).where(
      "active_storage_blobs.created_at < ?", Decidim::Votings::Census.census_access_codes_export_expiry_time.ago
    )
    attachments.each do |attachment|
      delete_census_access_codes_export_file attachment
    end
    puts "DELETE CENSUS ACCESS CODES EXPORT: --------------- END"
  end

  def delete_census_access_codes_export_file(attachment)
    puts "------"
    puts "!! deleting: #{attachment.filename}"
    attachment.purge
    puts "ok----"
  end
end
