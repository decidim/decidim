# frozen_string_literal: true

require "decidim/forms/admin"
require "decidim/forms/engine"
require "decidim/forms/admin_engine"
require "decidim/forms/api"

module Decidim
  # This namespace holds the logic of the `Forms`.
  module Forms
    autoload :UserAnswersSerializer, "decidim/forms/user_answers_serializer"
    autoload :DataPortabilityUserAnswersSerializer, "decidim/forms/data_portability_user_answers_serializer"
  end

  module Exporters
    autoload :FormPDF, "decidim/exporters/form_pdf"
    autoload :FormPDFControllerHelper, "decidim/exporters/form_pdf_controller_helper"
  end
end
