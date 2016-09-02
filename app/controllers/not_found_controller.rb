class NotFoundController < ApplicationController
  def any
    logger.not_found(request.fullpath)
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end
end