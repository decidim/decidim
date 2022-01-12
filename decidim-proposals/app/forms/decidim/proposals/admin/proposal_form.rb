# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Decidim::Proposals::Admin::ProposalBaseForm
        include Decidim::HasUploadValidations

        translatable_attribute :title, String do |field, _locale|
          validates field, length: { in: 15..150 }, if: proc { |resource| resource.send(field).present? }
        end
        translatable_attribute :body, String

        validates :title, :body, translatable_presence: true

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          super(model)
          presenter = ProposalPresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.body = presenter.body(all_locales: body.is_a?(Hash))
          self.attachment = if model.documents.first.present?
                              { file: model.documents.first.file, title: translated_attribute(model.documents.first.title) }
                            else
                              {}
                            end
        end
      end
    end
  end
end
