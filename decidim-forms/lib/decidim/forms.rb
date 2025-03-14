# frozen_string_literal: true

require "decidim/forms/admin"
require "decidim/forms/api"
require "decidim/forms/engine"
require "decidim/forms/admin_engine"

module Decidim
  # This namespace holds the logic of the `Forms`.
  module Forms
    autoload :UserResponsesSerializer, "decidim/forms/user_responses_serializer"
    autoload :DownloadYourDataUserResponsesSerializer, "decidim/forms/download_your_data_user_responses_serializer"
  end

  module Exporters
    autoload :FormPDF, "decidim/exporters/form_pdf"
  end
end
