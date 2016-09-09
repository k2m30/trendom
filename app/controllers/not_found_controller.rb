class NotFoundController < ApplicationController
  skip_before_action :verify_authenticity_token
  def any
    logger.not_found(request.fullpath)
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end
end