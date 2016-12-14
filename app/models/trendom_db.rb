require 'typhoeus'

#TODO https://modx.pro/hosting/570-nginx-protection-class-ip-restriction-frequent-requests/

class TrendomLinkedinDb
  def initialize(linkedin_id)
    @linkedin_id = linkedin_id
  end

  def get_email
    request = Typhoeus::Request.new("http://162.243.172.95:2243/linkedin/email/#{@linkedin_id}", timeout: 2)
    request.on_complete do |response|
      if response.response_code == 200
        return response.body
      else
        return nil
      end
    end
    request.run
  end
end