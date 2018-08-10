# frozen_string_literal: true

module Decidim
  class MessageCell < Decidim::ViewModel
    delegate :current_user, to: :controller

    def show
      render :show
    end

    def message
      @message ||= model
    end

    def sender
      @sender ||= Decidim::UserPresenter.new(message.sender)
    end

    def own_message?
      message.sender == current_user
    end
  end
end
