# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the participatory text proposal card for an instance of a Proposal
    # the default size is the Medium Card (:m)
    class ParticipatoryTextProposalCell < Decidim::ViewModel
      include ProposalCellsHelper
      include Cell::ViewModel::Partial
      include Messaging::ConversationHelper
      include Decidim::SanitizeHelper

      delegate :current_organization, to: :controller

      def show
        render
      end

      private

      def title
        case model.participatory_text_level
        when "section"
          "<h5><strong class='text-uppercase'>#{present(model).title}</strong></h5>"
        else
          "<h6><strong>#{present(model).title}</strong></h6>"
        end
      end

      def body
        return unless model.participatory_text_level == "article"
        decidim_sanitize(simple_format(present(model).body(links: true)))
      end

      def current_user
        context[:current_user]
      end

      def resource_path
        resource_locator(model).path
      end

      def amend_resource_path
        decidim.new_amend_path(amendable_gid: model.to_sgid.to_s)
      end

      def resource_comments_path
        resource_locator(model).path(anchor: "comments")
      end

      def resource_amendments_path
        resource_locator(model).path(anchor: "amendments")
      end

      def current_participatory_space
        model.component.participatory_space
      end

      def component_name
        translated_attribute current_component.name
      end

      def component_type_name
        model.class.model_name.human
      end

      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end
    end
  end
end
