# frozen_string_literal: true
if !Rails.env.production? || ENV["SEED"]
  # staging_organization = Decidim::Organization.order(id: :asc).first

  # participatory_process = Decidim::ParticipatoryProcess.order(id: :asc).first

  # commentator = Decidim::User.create!(
  #   name: "Commentator",
  #   email: "commentator@decidim.org",
  #   password: "decidim123456",
  #   password_confirmation: "decidim123456",
  #   confirmed_at: Time.current,
  #   locale: I18n.default_locale,
  #   organization: staging_organization,
  #   tos_agreement: true
  # )

  # 3.times do 
  #   Decidim::Comments::Comment.create!(
  #     author: commentator,
  #     commentable: participatory_process,
  #     body: Faker::Lorem.paragraph
  #   )
  # end
end
