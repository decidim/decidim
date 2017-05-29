# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  Decidim::System::Admin.create!(
    email: "system@example.org",
    password: "decidim123456",
    password_confirmation: "decidim123456"
  )

  Decidim::Organization.all.each do |organization|
    Decidim::System::CreateDefaultPages.call(organization)
  end
end
