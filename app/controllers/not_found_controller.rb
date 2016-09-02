class NotFoundController < ApplicationController
  def any
    Logger.new('log/not_found.log').info(request.fullpath)
    render file: 'public/404.html', status: :not_found, layout: false
  end
end