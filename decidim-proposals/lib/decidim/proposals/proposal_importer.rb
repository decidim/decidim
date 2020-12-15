# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalImporter < Decidim::Importers::Importer
      def import(_serialized, _user, _opts = {})
        raise "HELLO WORLD"
      end
    end
  end
end
