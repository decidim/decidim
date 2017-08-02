# frozen_string_literal: true

if !Rails.env.production? || ENV["SEED"]
  Decidim::System::Admin.find_or_initialize_by(email: "system@example.org").update!(
    password: "decidim123456",
    password_confirmation: "decidim123456"
  )

  Decidim::Organization.find_each do |organization|
    Decidim::System::CreateDefaultPages.call(organization)
  end
end
