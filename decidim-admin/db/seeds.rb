# frozen_string_literal: true

# TODO: This is not necessary I think
# if !Rails.env.production? || ENV["SEED"]
#   staging_organization = Decidim::Organization.order(id: :asc).first

#   process_admin = Decidim::User.create!(
#     name: "Process Admin",
#     email: "process_admin@example.org",
#     password: "decidim123456",
#     password_confirmation: "decidim123456",
#     confirmed_at: Time.current,
#     locale: I18n.default_locale,
#     organization: staging_organization,
#     tos_agreement: true,
#     comments_notifications: true,
#     replies_notifications: true
#   )

#   Decidim::ParticipatoryProcessUserRole.create!(
#     user: process_admin,
#     participatory_process: Decidim::ParticipatoryProcess.order(id: :asc).first,
#     role: "admin"
#   )
# end
