class VerificationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:linkedin]
  def linkedin
    render text: 'ok', status: :ok
  end
end
