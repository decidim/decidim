if !Rails.env.production? || ENV["SEED"]
  puts "Creating Decidim::Core seeds..."

  staging_organization = Decidim::Organization.create!(
    name: "Decidim Staging",
    host: ENV["DECIDIM_HOST"] || "localhost"
  )

  Decidim::User.create!(
    email: "admin@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: staging_organization,
    roles: ["admin"]
  )

  Decidim::User.create!(
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: staging_organization
  )
end
