# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing meetings in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Meetings::Meeting/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class MeetingRenderer < ResourceRenderer
      def regex
        %r{gid://([\w-]*/Decidim::Meetings::Meeting/(\d+))}i
      end
    end
  end
end
