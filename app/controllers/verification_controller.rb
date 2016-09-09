class VerificationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:linkedin]
  def linkedin
    render text: params.permit!.to_h, status: :ok
  end
end
