# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        include TranslatableAttributes
        attribute :trustee_ids, Array[Integer]

        validate :check_election_is_valid

        def map_model(model)
          @election = model
          @trustees = Decidim::Elections::Trustee.includes([:user]).joins(:trustees_participatory_spaces).merge(Decidim::Elections::TrusteesParticipatorySpace
                                                                                                         .where(participatory_space: election.component.participatory_space,
                                                                                                                considered: true)).to_a.sample(2).sort_by(&:id)
          self.trustee_ids = @trustees.pluck(:id)
        end

        def trustees
          @trustees ||= Decidim::Elections::Trustee.includes([:user]).joins(:trustees_participatory_spaces).merge(Decidim::Elections::TrusteesParticipatorySpace
                                                                                                           .where(id: trustee_ids,
                                                                                                                  participatory_space: election.component.participatory_space,
                                                                                                                  considered: true)).to_a.sort_by(&:id)
        end

        def messages
          { published: "The election is <strong>published</strong>",
            time_before: "The setup is being done <strong>at least 3 hours</strong> before the election starts",
            start_time: "The <strong>start time</strong> is setted up <strong>before the end time</strong>",
            minimum_questions: "The election has <strong>at least 1 question</strong>",
            minimum_answers: "Each question has <strong>at least 2 answers</strong>",
            max_selections: "All the questions have a correct value for <strong>maximum of answers</strong>",
            trustees_quorum: "The size of this list of trustees is correct and it will be needed <strong>at least 2 trustees</strong> to perform the tally process." }
        end

        def election
          @election ||= context[:election]
        end

        def check_election_is_valid
          errors.add("minimum_answers", "All the questions must have <strong>at least 2 answers</strong>") unless election.minimum_answers?
          # errors.add("trustees_quorum", "The <strong>number of trustees</strong> is not correct") unless trustees.size >= 2
        end
      end
    end
  end
end
