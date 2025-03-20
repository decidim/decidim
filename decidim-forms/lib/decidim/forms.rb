# frozen_string_literal: true

require "decidim/forms/admin"
require "decidim/forms/api"
require "decidim/forms/engine"
require "decidim/forms/admin_engine"

module Decidim
  # This namespace holds the logic of the `Forms`.
  module Forms
    autoload :UserAnswersSerializer, "decidim/forms/user_answers_serializer"
    autoload :DownloadYourDataUserAnswersSerializer, "decidim/forms/download_your_data_user_answers_serializer"
  end

  module Exporters
    autoload :FormPDF, "decidim/exporters/form_pdf"
    autoload :FormPDFControllerHelper, "decidim/exporters/form_pdf_controller_helper"
  end
end
