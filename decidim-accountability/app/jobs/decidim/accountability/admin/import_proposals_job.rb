# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ImportProposalsJob < ApplicationJob
        queue_as :default

        def perform(proposals, component, user)
          proposals.map do |id|
            original_proposal = Decidim::Proposals::Proposal.find_by(id:)

            new_result = create_result_from_proposal!(original_proposal, statuses(component).first, component, user)
            new_result.link_resources([original_proposal], "included_proposals")

            copy_attachments(original_proposal, new_result)
          end.compact
          Decidim::Accountability::ImportProposalsMailer.import(user, component, proposals.count).deliver_now
        end

        private

        def create_result_from_proposal!(proposal, status, component, user)
          params = {
            title: proposal.title,
            description: proposal.body,
            taxonomies: proposal.taxonomies,
            component:,
            status:,
            progress: status&.progress || 0,
            address: proposal.address,
            latitude: proposal.latitude,
            longitude: proposal.longitude
          }
          @result = Decidim.traceability.create!(
            Result,
            user,
            params,
            visibility: "all"
          )
        end

        def copy_attachments(proposal, result)
          proposal.attachments.each do |attachment|
            new_attachment = Decidim::Attachment.new(
              {
                # Attached to needs to be always defined before the file is set
                attached_to: result
              }.merge(
                attachment.attributes.slice("content_type", "description", "file_size", "title", "weight")
              )
            )

            if attachment.file.attached?
              new_attachment.file = attachment.file.blob
            else
              new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file)
            end

            new_attachment.save!
          end
        end

        def statuses(component)
          Decidim::Accountability::Status.where(component:).order(:progress)
        end
      end
    end
  end
end
