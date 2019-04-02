# frozen_string_literal: true

module Decidim
  module Admin
    class NewsletterRecipients < Rectify::Query
      def initialize(newsletter, form)
        @newsletter = newsletter
        @form = form
      end

      def query
        recipients = Decidim::User.where(organization: @newsletter.organization)
                            .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)
                            .not_deleted

        if @form.send_to_followers
          recipients = recipients.where(id: user_id_of_followers)
        end

        if @form.send_to_participants
          recipients = recipients.where(id: participant_ids)
        end

        if @form.scope_ids.present?
          recipients = recipients.interested_in_scopes(@form.scope_ids)
        end

        recipients
      end

      private

      def spaces
        return unless @form.participatory_space_types.present?

        @form.participatory_space_types.map do |type|
          next if type.ids.blank?
          object_class = "Decidim::#{type.manifest_name.classify}"
          if type.ids.include?("all")
            object_class.constantize.where(organization: @organization)
          else
            object_class.constantize.where(id: type.ids.reject(&:blank?))
          end
        end.flatten.compact
      end

      def user_id_of_followers
        return if spaces.blank?
        return unless @form.send_to_followers
        Decidim::Follow.user_follower_ids_for_participatory_spaces(spaces)
      end

      def participant_ids
        ## PENDING TO IMPROVE THIS (ExTREURE cada funcionalitat al seu component concret)
        return if spaces.blank?
        return unless @form.send_to_participants

        participant_ids = []
        spaces.each do |space|
          components = Decidim::Component.where(id: space.component_ids)
          available_components = %w(proposals debates budgets surveys).freeze
          # Just published components
          components.published.each do |component|
            # raise if component.manifest_name == "proposals"
            next unless available_components.include?(component.manifest_name)

            case component.manifest_name
            when "proposals"
              proposals = retrieve_proposals(component).uniq
              ## COAUTHORS
              # coauthors_recipients = proposals.map { |p| p.notifiable_identities}.flatten.compact.uniq
              coauthors_recipients_ids = proposals.map{ |p| p.notifiable_identities.pluck(:id)}.flatten.compact.uniq

              ## VOTS
              proposals_votes = retrieve_votes( proposals )
              # participants_has_voted = proposals_votes.map { |v| v.author}.flatten.compact.uniq
              participants_has_voted_ids = proposals_votes.map { |v| v.decidim_author_id}.flatten.compact.uniq

              ## ENDORSMENTS
              proposals_endorsements = retrieve_endorsements(proposals)
              # endorsements_participants = proposals_endorsements.map { |e| e.author}.flatten.compact.uniq
              endorsements_participants_ids = proposals_endorsements.map { |e| e.decidim_author_id}.flatten.compact.uniq

              # total_participants = endorsements_participants + participants_has_voted + coauthors_recipients
              total_participants_ids = endorsements_participants_ids + participants_has_voted_ids + coauthors_recipients_ids
              # total_participants.uniq
              participant_ids << total_participants_ids.uniq
            when "debates"
              debates = Decidim::Debates::Debate.where(component: component).joins(:component)
                                                .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                                .where.not(author: nil)
              # debates_participants = debates.map { |d| d.author}.flatten.compact.uniq
              debates_participants_ids = debates.pluck(:decidim_author_id).flatten.compact.uniq

              participant_ids << debates_participants_ids
            when "budgets"
              budgets_votes = Decidim::Budgets::Order.where(component: component).joins(:component)
                                               .finished
              # budgets_participants = budgets_votes.map { |b| b.user}.flatten.compact.uniq
              budgets_participants_ids = budgets_votes.pluck(:decidim_user_id).flatten.compact.uniq

              participant_ids << budgets_participants_ids
              #Vote PROJECT
            when "surveys"
              #Answer survey
              surveys = Decidim::Surveys::Survey.joins(:component, :questionnaire).where(component: component)
              questionnaires = Decidim::Forms::Questionnaire.includes(:questionnaire_for)
                                                            .where(questionnaire_for_type: Decidim::Surveys::Survey.name, questionnaire_for_id: surveys.pluck(:id))

              answers = Decidim::Forms::Answer.joins(:questionnaire)
                                              .where(questionnaire: questionnaires)

              # answers_participants = answers.map { |b| b.user}.flatten.compact.uniq
              answers_participants_ids = answers.pluck(:decidim_user_id).flatten.compact.uniq
              participant_ids << answers_participants_ids
            end
          end

          # SPACE Comments
          user_ids = Decidim::User.where(organization: space.organization).pluck(:id)
          comments = Decidim::Comments::Comment.includes(:root_commentable).not_hidden
                                    .where("decidim_comments_comments.decidim_author_id IN (?)", user_ids)
                                    .where("decidim_comments_comments.decidim_author_type IN (?)", "Decidim::UserBaseEntity")

          # comments_participants = comments.map { |d| d.author}.flatten.compact.uniq
          comments_participants_ids = comments.map { |d| d.author }.flatten.compact.uniq
          participant_ids << comments_participants_ids.pluck(:id)
        end
        participant_ids.flatten.compact.uniq
      end

      def retrieve_proposals(component)
        Decidim::Proposals::Proposal.where(component: component).joins(:coauthorships)
                                                   .includes(:votes, :endorsements)
                                                   .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                                   .not_hidden
                                                   .published
                                                   .except_withdrawn

      end

      def retrieve_votes( proposals )
        Decidim::Proposals::ProposalVote.joins(:proposal).where(proposal: proposals).joins(:author)
      end

      def retrieve_endorsements(proposals)
        Decidim::Proposals::ProposalEndorsement.joins(:proposal).where(proposal: proposals)
                                               .where(decidim_author_type: "Decidim::UserBaseEntity")

      end
    end
  end
end
