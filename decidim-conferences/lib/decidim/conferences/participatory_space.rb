# frozen_string_literal: true

Decidim.register_participatory_space(:conferences) do |participatory_space|
  participatory_space.icon = "media/images/decidim_conferences.svg"
  participatory_space.model_class_name = "Decidim::Conference"
  participatory_space.stylesheet = "decidim/conferences/conferences"

  participatory_space.participatory_spaces do |organization|
    Decidim::Conferences::OrganizationConferences.new(organization).query
  end

  participatory_space.permissions_class_name = "Decidim::Conferences::Permissions"
  participatory_space.data_portable_entities = [
    "Decidim::Conferences::ConferenceRegistration",
    "Decidim::Conferences::ConferenceInvite"
  ]

  participatory_space.query_type = "Decidim::Conferences::ConferenceType"

  participatory_space.breadcrumb_cell = "decidim/conferences/conference_dropdown_metadata"

  participatory_space.register_resource(:conference) do |resource|
    resource.model_class_name = "Decidim::Conference"
    resource.card = "decidim/conferences/conference"
    resource.searchable = true
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Conferences::Engine
    context.layout = "layouts/decidim/conference"
    context.helper = "Decidim::Conferences::ConferenceHelper"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Conferences::AdminEngine
    context.layout = "layouts/decidim/admin/conference"
  end

  participatory_space.register_on_destroy_account do |user|
    Decidim::ConferenceUserRole.where(user:).destroy_all
    Decidim::ConferenceSpeaker.where(user:).destroy_all
  end

  participatory_space.seeds do
    require "decidim/conferences/seeds"

    Decidim::Conferences::Seeds.new.call
  end
end
