# frozen_string_literal: true
if !Rails.env.production? || ENV["SEED"]
  puts "Creating Decidim::System seeds..."

  Decidim::System::Admin.create!(
    email: "system@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456"
  )

  Decidim::Organization.all.each do |organization|
    Decidim::System::CreateDefaultPages.call(organization)
  end
end
