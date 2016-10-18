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
    roles: ["admin"],
    tos_agreement: true
  )

  Decidim::User.create!(
    name: "Responsible Citizen",
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    organization: staging_organization,
    tos_agreement: true
  )

  participatory_process1 = Decidim::ParticipatoryProcess.create!(
    title: {
      en: "Urbanistic plan for Newtown neighbourhood",
      es: "Plan urbanístico para el barrio de Villanueva",
      ca: "Pla urbanístic pel barri de Vilanova"
    },
    slug: "urbanistic-plan-for-newtown-neighbourhood",
    subtitle: {
      en: "Go for it!",
      es: "Vamos!",
      ca: "Som-hi!"
    },
    hashtag: "#urbaNewtown",
    short_description: {
      en: "<p>Short description</p>",
      es: "<p>Descripción corta</p>",
      ca: "<p>Descripció curta</p>"
    },
    description: {
      en: "<p>Description</p>",
      es: "<p>Descripción</p>",
      ca: "<p>Descripció</p>"
    },
    hero_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city.jpeg")),
    banner_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city2.jpeg")),
    promoted: true,
    organization: staging_organization
  )

  Decidim::ParticipatoryProcess.create!(
    title: {
      en: "Open a new library in the center",
      es: "Abrir una nueva biblioteca en el centro",
      ca: "Obrir una nova biblioteca al centre"
    },
    slug: "open-a-new-library-in-the-center",
    subtitle: {
      en: "Easier access to culture for everybody",
      es: "Un acceso más fácil a la cultura para todos",
      ca: "Un accés més fàcil a la cultura per a tothom"
    },
    hashtag: "#libraryDowntown",
    short_description: {
      en: "<p>Short description</p>",
      es: "<p>Descripción corta</p>",
      ca: "<p>Descripció curta</p>"
    },
    description: {
      en: "<p>Description</p>",
      es: "<p>Descripción</p>",
      ca: "<p>Descripció</p>"
    },
    hero_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city2.jpeg")),
    banner_image: File.new(File.join(File.dirname(__FILE__), "seeds", "city3.jpeg")),
    organization: staging_organization
  )

  Decidim::ParticipatoryProcessStep.create!(
    title: {
      en: "Information",
      es: "Información",
      ca: "Informació"
    },
    short_description: {
      en: "<p>Short description</p>",
      es: "<p>Descripción corta</p>",
      ca: "<p>Descripció curta</p>"
    },
    description: {
      en: "<p>Description</p>",
      es: "<p>Descripción</p>",
      ca: "<p>Descripció</p>"
    },
    start_date: 1.month.ago.at_midnight,
    end_date: 2.months.from_now.at_midnight,
    participatory_process: participatory_process1
  )
end
