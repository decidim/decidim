# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A form to create/edit a ballot style
      class BallotStyleForm < Form
        attribute :code, String
        attribute :question_ids, Array[Integer]

        validates :code, presence: true

        def code
          super&.upcase
        end
      end
    end
  end
end
