class GetEmailsAvailableJob < ApplicationJob
  queue_as :pipl_api

  def perform(*args)
    # Do something later
  end
end
