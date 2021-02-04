# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  print "Creating seeds for decidim-system...\n" unless Rails.env.test?

  password = ENV["DECIDIM_SYSTEM_USER_PASSWORD"] || "decidim123456"

  Decidim::System::Admin.find_or_initialize_by(email: "system@example.org").update!(
    password: password,
    password_confirmation: password
  )

  Decidim::Organization.find_each do |organization|
    Decidim::System::CreateDefaultPages.call(organization)
    Decidim::System::PopulateHelp.call(organization)
  end
end
