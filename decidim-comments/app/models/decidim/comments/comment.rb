module Decidim
  module Comments
    class Comment
      attr_accessor :id, :body, :createdAt, :author

      def initialize(args = {})
        @id = args[:id]
        @body = args[:body]
        @createdAt = args[:createdAt]
        @author = Class.new do
          attr_accessor :name

          def initialize(args = {})
            @name = args[:name]
          end
        end.new(args[:author])
      end
    end
  end
end