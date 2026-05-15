# frozen_string_literal: true

module Decidim
  module Forms
    # This cell renders a possible matrix response of a question (readonly)
    class MatrixReadonlyCell < Decidim::ViewModel
      def response_options
        model.question.response_options.map { |option| translated_attribute(option.body) }.join(" / ")
      end
    end
  end
end
