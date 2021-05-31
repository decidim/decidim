# frozen_string_literal: true

# This class is necessary because Sprockets dependency can't be removed from Decidim
# until some dependencies upgrade and remove it.
#
# List of gems using Sprockets:
#   - graphiql-rails: PR to remove it from oct 2019 - https://github.com/rmosolgo/graphiql-rails/pull/76
module Decidim
  class AssetsToSilenceSprocketsDependency
    def precompile
      []
    end

    def precompile=(value); end
  end
end

Rails.application.config.assets = Decidim::AssetsToSilenceSprocketsDependency.new
