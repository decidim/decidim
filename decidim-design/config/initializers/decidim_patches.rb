# frozen_string_literal: true

Rails.application.config.middleware.delete Decidim::CurrentOrganization
