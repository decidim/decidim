# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders a possible matrix answer of a question (readonly)
    class MatrixReadonlyCell < Decidim::ViewModel
      def answer_options
        model.question.answer_options.map { |option| translated_attribute(option.body) }.join(" / ")
      end
    end
  end
end
