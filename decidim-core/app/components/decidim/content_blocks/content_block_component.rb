module Decidim
  module ContentBlocks
    class ContentBlockComponent < Decidim::BaseComponent

      def initialize(content_block)
        @model = content_block
      end

      private
      attr_reader :model

      delegate :settings, :images_container, to: :model

      def block_id
        [
          self.class.name.demodulize.underscore.dasherize,
          model.id
        ].join("-")
      end
    end
  end
end
