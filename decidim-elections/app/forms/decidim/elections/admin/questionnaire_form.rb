# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionnaireForm < Decidim::Form
        attribute :questions, Array[QuestionForm], default: []
      end
    end
  end
end
