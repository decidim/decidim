if !Rails.env.production? || ENV["SEED"]
  puts "Creating Decidim::System seeds..."

  Decidim::System::Admin.create!(
    email: "system@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456"
  )
end
