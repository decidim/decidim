# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        attribute :trustee_ids, Array[Integer]

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

        def election
          @election ||= context[:election]
        end
      end
    end
  end
end
