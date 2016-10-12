require 'typhoeus'
require 'pp'
require 'json'

class Rapportive
  def initialize
    oauth
  end

  def find_user(email)
    url = "https://api.linkedin.com/v1/people/email=#{email}:(id,email-address,positions,first-name,last-name,twitter-accounts,im-accounts,phone-numbers,member-url-resources,picture-urls::(original),site-standard-profile-request,public-profile-url)"
    response = get_info(url)

    case response.code
      when 401
        Rails.logger.info 'Oauth expired, retry'
        o = get_new_oauth
        Rails.cache.write(:oauth, o)
        response = get_info(url)
      when 200
      else
        p 'Something is wrong'
        pp response.code
    end

    Rails.logger.info response.body
    JSON.parse response.body
  end

  def oauth
    Rails.cache.fetch(:oauth) do
      get_new_oauth
    end
  end

  def get_new_oauth
    url = 'https://www.linkedin.com/uas/js/authuserspace?v=0.0.2000-RC8.58572-1429&api_key=4XZcfCb3djUl-DHJSFYd1l0ULtgSPl9sXXNGbTKT2e003WAeT6c2AqayNTIN5T1s&credentialsCookie=true'
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:49.0) Gecko/20100101 Firefox/49.0',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'br',
        'Referer': 'https://mail.google.com/mail/u/0/',
        'Cookie': 'li_at=AQEDARiOqpkD2M5VAAABV63aw5UAAAFXrkiglVEAl2jiHEVGPEZDQ2EOJ9twqoi1few4hEauCAT7p9d733JANM8nb7jMU322uOlbrR9IxzTd13mkJ-Qlt_RlapjA9-JbVRJIwAOuqoRsgcUpYx355Ym1;',
        'Connection': 'keep-alive',
        'Host': 'www.linkedin.com'
    }

    response = Typhoeus.get(url, headers: headers, verbose: false)

    body = response.body
    match = body.match(/l.oauth_token = "(?<oauth>[^"]{36,})"/)

    raise 'Oauth not found in response' if match.nil?

    match[:oauth]
  end

  def get_info(url)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:49.0) Gecko/20100101 Firefox/49.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'br',
        'X-HTTP-Method-Override': 'GET',
        'X-Requested-With': 'IN.XDCall',
        'x-li-format': 'json',
        'X-Cross-Domain-Origin': 'https://mail.google.com',
        'Content-Type': 'application/json',
        'oauth_token': oauth,
        'Referer': 'https://api.linkedin.com/uas/js/xdrpc.html?v=0.0.2000-RC8.58572-1429',
        'Connection': 'keep-alive',
        'Host': 'api.linkedin.com'
    }
    response = Typhoeus.get(url, headers: headers, verbose: false)
    response
  end
end


# %w(id first-name last-name location distance num-connections skills educations school-name)
# default_selectors_search_profile = [{'people': %w(id first-name last-name educations school-name public-profile-url location headline last-modified-timestamp date-of-birth member-url-resources email-address)}]
