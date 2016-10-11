if !Rails.env.production? || ENV["SEED"]
  puts "Creating Decidim::Core seeds..."

  staging_organization = Decidim::Organization.create!(
    name: "Decidim Staging",
    host: ENV["DECIDIM_HOST"] || "localhost"
  )

  Decidim::User.create!(
    name: "Organization Admin",
    email: "admin@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: staging_organization,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    roles: ["admin"]
  )

  Decidim::User.create!(
    name: "Responsible Citizen",
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: staging_organization
  )

  Decidim::ParticipatoryProcess.create!(
    title: {
      en: 'Urbanistic plan for Newtown neighbourhood',
      es: 'Plan urbanístico para el barrio de Villanueva',
      ca: 'Pla urbanístic pel barri de Vilanova'
    },
    slug: 'urbanistic-plan-for-newtown-neighbourhood',
    subtitle: {
      en: 'Go for it!',
      es: 'Vamos!',
      ca: 'Som-hi!'
    },
    hashtag: '#urbaNewtown',
    short_description: {
      en: 'Short description',
      es: 'Descripción corta',
      ca: 'Descripció curta'
    },
    description: {
      en: 'Description',
      es: 'Descripción',
      ca: 'Descripció'
    },
    organization: staging_organization
  )
end
