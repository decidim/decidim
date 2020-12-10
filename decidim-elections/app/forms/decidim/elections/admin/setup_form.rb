# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        include TranslatableAttributes

        attribute :trustee_ids, Array[Integer]

        validate :check_election_is_valid

        def map_model(model)
          @election = model
          @trustees = Decidim::Elections::Trustees::ByParticipatorySpace.new(election.component.participatory_space).to_a.sample(number_of_trustees).sort_by(&:id)

          self.trustee_ids = @trustees.pluck(:id)
        end

        def trustees
          @trustees = Decidim::Elections::Trustees::ByParticipatorySpace.new(election.component.participatory_space)

          self.trustee_ids = @trustees.pluck(:id)

          @trustees = Decidim::Elections::Trustees::ByParticipatorySpaceTrusteeIds.new(trustee_ids).to_a.sort_by(&:id)
          @trustees
        end

        def number_of_trustees
          Decidim::Elections.bulletin_board.number_of_trustees
        end

        def messages
          { published: I18n.t("admin.setup.requirements.published", scope: "decidim.elections"),
            time_before: I18n.t("admin.setup.requirements.time_before", scope: "decidim.elections"),
            minimum_questions: I18n.t("admin.setup.requirements.minimum_questions", scope: "decidim.elections"),
            minimum_answers: I18n.t("admin.setup.requirements.minimum_answers", scope: "decidim.elections"),
            max_selections: I18n.t("admin.setup.requirements.max_selections", scope: "decidim.elections"),
            trustees_quorum: I18n.t("admin.setup.requirements.trustees_quorum", scope: "decidim.elections", quorum: Decidim::Elections.bulletin_board.quorum) }
        end

        def election
          @election ||= context[:election]
        end

        def check_election_is_valid
          errors.add("published", I18n.t("admin.setup.errors.published", scope: "decidim.elections")) if election.published_at.blank?
          errors.add("time_before", I18n.t("admin.setup.errors.time_before", scope: "decidim.elections")) unless election.minimum_three_hours_before_start?
          errors.add("minimum_questions", I18n.t("admin.setup.errors.minimum_questions", scope: "decidim.elections")) if election.questions.empty?
          errors.add("minimum_answers", I18n.t("admin.setup.errors.minimum_answers", scope: "decidim.elections")) unless election.minimum_answers?
          errors.add("max_selections", I18n.t("admin.setup.errors.max_selections", scope: "decidim.elections")) unless election.valid_questions?
          errors.add("trustees_quorum", I18n.t("admin.setup.errors.trustees_quorum", scope: "decidim.elections")) unless trustees_satisfy_quorum
          check_trustees_public_keys
        end

        def trustees_satisfy_quorum
          return if Decidim::Elections.bulletin_board.quorum.blank?

          trustees.size >= Decidim::Elections.bulletin_board.quorum
        end

        def check_trustees_public_keys
          trustees.each do |trustee|
            if trustee.public_key.blank?
              errors.add("trustee_id_#{trustee.id}", "#{trustee.user.name} #{I18n.t("admin.setup.errors.trustee_public_key", scope: "decidim.elections")}")
            end
          end
        end
      end
    end
  end
end
