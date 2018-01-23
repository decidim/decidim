# frozen-string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalCategoryEvent < Decidim::Events::BaseEvent
        include Decidim::Events::EmailEvent
        include Decidim::Events::NotificationEvent

        def email_subject
          I18n.t(
            "decidim.proposals.events.update_proposal_category_event.email_subject",
            resource_title: resource_title
          )
        end

        def email_intro
          I18n.t(
            "decidim.proposals.events.update_proposal_category_event.email_intro",
            resource_title: resource_title,
            author_nickname: author.nickname,
            author_name: author.name
          )
        end

        def email_outro
          I18n.t(
            "decidim.proposals.events.update_proposal_category_event.email_outro"
          )
        end

        def notification_title
          I18n.t(
            "decidim.proposals.events.update_proposal_category_event.notification_title",
            resource_title: resource_title,
            resource_path: resource_path
          ).html_safe
        end

        private

        def author
          @author ||= Decidim::UserPresenter.new(resource.author)
        end
      end
    end
  end
end
