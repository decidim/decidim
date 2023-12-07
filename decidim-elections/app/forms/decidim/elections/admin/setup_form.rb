# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        mimic :setup

        attribute :trustee_ids, Array[Integer]

        validate do
          validations.each do |message, t_args, valid|
            errors.add(message, I18n.t("steps.create_election.errors.#{message}", **t_args, scope: "decidim.elections.admin")) unless valid
          end

          if needs_census?
            census_validations.each do |message, t_args, valid|
              errors.add(message, I18n.t("steps.create_election.errors.#{message}", **t_args, scope: "decidim.elections.admin")) unless valid
            end
          end
        end

        def current_step; end

        def pending_action; end

        def trustee_ids
          choose_random_trustees
        end

        def trustees
          ids = trustee_ids
          @trustees ||= Decidim::Elections::Trustees::ByParticipatorySpaceTrusteeIds.new(ids).to_a.sort_by(&:id)
        end

        def validations
          @validations ||= [
            [:minimum_questions, { link: router.election_questions_path(election) }, election.questions.any?],
            [:minimum_answers, { link: router.election_questions_path(election) }, election.minimum_answers?],
            [:max_selections, { link: router.election_questions_path(election) }, election.valid_questions?],
            [:published, { link: router.publish_election_path(election) }, election.published_at.present?],
            [:component_published, { link: EngineRouter.admin_proxy(election.participatory_space).components_path(election.participatory_space) }, election.component.published?],
            [:time_before, { link: router.edit_election_path(election), hours: I18n.t("datetime.distance_in_words.x_hours", count: Decidim::Elections.setup_minimum_hours_before_start) }, election.minimum_hours_before_start?],
            [:trustees_number, { link: router.trustees_path, number: bulletin_board.number_of_trustees }, participatory_space_trustees_with_public_key.size >= bulletin_board.number_of_trustees]].freeze
        end

        def census_validations
          return [] unless needs_census?

          @census_validations ||= [
            [:census_uploaded, {}, census.present? && census.data.exists?],
            [:census_codes_generated, {}, census_codes_generated?],
            [:census_frozen, {}, census&.freeze?]
          ].freeze
        end

        def messages
          @messages ||= validations.to_h do |message, t_args, _valid|
            [message, { message: I18n.t("steps.create_election.requirements.#{message}", **t_args, scope: "decidim.elections.admin"), link: t_args[:link] }]
          end
        end

        def census_messages
          @census_messages ||= census_validations.to_h do |message, t_args, _valid|
            [message, I18n.t("steps.create_election.requirements.#{message}", **t_args, scope: "decidim.elections.admin")]
          end
        end

        def participatory_space_trustees
          @participatory_space_trustees ||= Decidim::Elections::Trustees::ByParticipatorySpace.new(election.component.participatory_space).to_a
        end

        def election
          @election ||= context[:election]
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end

        def needs_census?
          vote_flow.is_a?(Decidim::Votings::CensusVoteFlow)
        end

        def vote_flow
          @vote_flow ||= election.participatory_space.try(:vote_flow_for, election)
        end

        def census_codes_generated?
          return unless needs_census?

          census&.codes_generated? || census&.exporting_codes? || census&.freeze?
        end

        def census
          return unless needs_census?

          @census ||= election.component.participatory_space.dataset
        end

        def main_button?
          true
        end

        private

        def choose_random_trustees
          return @trustee_ids if @trustee_ids&.any? || defined?(@trustees)

          @trustees = if participatory_space_trustees_with_public_key.count >= bulletin_board.number_of_trustees
                        participatory_space_trustees_with_public_key.sample(bulletin_board.number_of_trustees)
                      else
                        []
                      end
          @trustee_ids = @trustees.pluck(:id)
        end

        def participatory_space_trustees_with_public_key
          @participatory_space_trustees_with_public_key ||= participatory_space_trustees.filter { |trustee| trustee.public_key.present? }
        end

        def router
          @router ||= EngineRouter.admin_proxy(election.component)
        end
      end
    end
  end
end
