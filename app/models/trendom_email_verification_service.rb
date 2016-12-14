class TrendomEmailVerificationService
  def initialize(emails_hash)
    @emails_hash = emails_hash.to_json
  end

  def call
    begin
      response = Typhoeus.post('http://162.243.172.95:2244/verification/linkedin', headers: {'Content-Type': 'application/json'}, body: @emails_hash)
      if response.response_code == 200
        response.body
      else
        nil
      end
    end
  rescue => e
    logger.fatal(e.message)
    logger.fatal(@emails_hash)
  end
end