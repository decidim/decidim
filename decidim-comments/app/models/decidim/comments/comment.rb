module Decidim
  module Comments
    class Comment
      attr_accessor :id, :body

      def initialize(args = {})
        @id = args[:id]
        @body = args[:body]
      end
    end
  end
end