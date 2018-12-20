# frozen_string_literal: true

module Decidim
  module Amendable
    # a form object common for amendments
    class Form < Decidim::Form
      mimic :amend

      def amendment
        @amendment ||= Decidim::Amendment.find id
      end

      def amendable
        @amendable ||= amendment.amendable
      end

      def emendation
        @emendation ||= amendment.emendation
      end
    end
  end
end
