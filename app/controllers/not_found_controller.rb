class NotFoundController < ApplicationController
  def any
    Logger.new('log/not_found.log').info(request.fullpath)
    head :not_found
  end
end