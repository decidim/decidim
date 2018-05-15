# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, name, format)
      objects = [
        Decidim::Budgets::Order,
        Decidim::Comments::Comment,
        Decidim::Consultations::Vote,
        Decidim::Debates::Debate,
        Decidim::Follow,
        Decidim::Identity,
        Decidim::Meetings::Registration,
        Decidim::Messaging::Conversation,
        Decidim::Notification,
        Decidim::ParticipatorySpacePrivateUser,
        Decidim::Proposals::Proposal,
        Decidim::Proposals::ProposalVote,
        Decidim::Proposals::ProposalEndorsement,
        Decidim::Report,
        Decidim::User,
        Decidim::UserGroup
      ]

      export_data = []
      objects.each do |object|
        export_data << [object.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter(format).new(object.user_collection(user), object.export_serializer).export]
      end

      ExportMailer.data_portability_export(user, name, export_data).deliver_now
    end
  end
end
