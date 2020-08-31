# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Question in the Decidim::Elections component. It stores a
    # title, description and a maximum number of selection that voters can choose.
    class Question < ApplicationRecord
      include Decidim::Resourceable
      include Traceable
      include Loggable

      delegate :component, to: :election

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election", inverse_of: :questions
      has_many :answers, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Answer", inverse_of: :question, dependent: :destroy

      default_scope { order(weight: :asc, id: :asc) }
    end
  end
end
