require_relative 'pipl_db'
require 'trendom_db'
require_relative 'user_request'
require 'email_verifier'
require 'google_custom_search_api'

#TODO add more domains from file
TWO_PART_DOMAINS = %w(ac.at ac.il ac.uk apc.org asn.au att.com att.net boi.ie bp.com cmu.edu co.com co.gg co.il co.im co.in co.je co.jp co.nz co.th co.uk co.ukc co.za co.zw com.ar com.au com.bh com.br com.cn com.cy com.gt com.hk com.mk com.mt com.mx com.ng com.pk com.pt com.qa com.sg com.tr com.ua dcu.ie dsv.com edu.ge edu.in edu.tr eu.com ey.com gb.com ge.com gm.com gov.au gov.im gov.uk gt.com gwu.edu hhs.se hse.fi ibm.com ie.edu in.gov in.ua ing.com jnj.com ko.com kth.se kwe.com lls.com ltd.uk me.uk mit.edu mod.uk mps.it msn.com net.au net.il net.lb net.nz net.tr net.uk nhs.uk nyc.gov org.pl org.qa org.uk pkf.com plc.uk pwc.com rlb.com rr.com sas.com tac.com tcd.ie to.it uk.com uk.net unc.edu ups.com us.com utc.com yr.com)

#TODO add masks like yhahoo.com.rb etc
TRUSTED_DOMAINS = %w(gmail.com hotmail.com yahoo.com aol.com comcast.net yahoo.co.in msn.com sbcglobal.net rediffmail.com yahoo.fr yahoo.co.uk live.com yahoo.com.br hotmail.co.uk verizon.net hotmail.fr ymail.com cox.net bellsouth.net libero.it att.net yahoo.es btinternet.com mail.ru googlemail.com earthlink.net mac.com yahoo.in yahoo.ca hotmail.it charter.net yahoo.com.ar ig.com.br me.com wanadoo.fr 163.com yahoo.it optonline.net uol.com.br rogers.com yahoo.com.mx shaw.ca orange.fr rocketmail.com free.fr gmx.de web.de terra.com.br hotmail.es sympatico.ca bigpond.com yahoo.co.id alice.it bol.com.br live.co.uk live.fr)

class Profile < ApplicationRecord
  has_and_belongs_to_many :users
  serialize :notes, Hash
  validates_uniqueness_of :linkedin_id, :twitter_id, :facebook_id, allow_nil: true

  def apply_template(email_template_id)
    first, last = split_name
    email_template = EmailTemplate.find(email_template_id)
    email_template.text.gsub('{First Name}', first).gsub('{Last Name}', last).gsub('{Company}', extract_company).gsub('{Position}', extract_position)
  end

  def set_primary_email(main_email)
    return unless emails.include?(main_email)
    a = emails
    a.delete(main_email)
    a.insert(0, main_email)
    self.update(emails: a)
  end

  def split_name
    name.split(' ')
  end

  def extract_company
    position.split(' at ').last || ''
  end

  def extract_position
    position.split(' at ').first || ''
  end

  def get_emails
    unless emails.empty?
      logger.info("#{emails}, already have")
      return emails
    end

    get_emails_from_trendom
    unless emails.empty?
      logger.info("#{emails}, found in TrendomDB")
      return emails
    end

    get_emails_from_google
    unless emails.empty?
      logger.info("#{emails}, found in Google")
      return emails
    end

    get_emails_from_pipl
    logger.info("#{emails}, found in Pipl")

    return emails
  end

  def get_emails_from_trendom(update = true)
    return [] if linkedin_id.nil?

    email = TrendomLinkedinDb.new(linkedin_id).get_email

    return [] if email.nil?

    #TODO add check of untrysted emails
    # name, domain = email.split('@')
    # return [] if name.nil? or domain.nil?
    #
    # unless trusted?(domain)
    #   checker = EmailChecker.new([domain], [name])
    #   email = checker.check_email(email)
    # end

    if email
      update(emails: [email], emails_available: 1) if update
      [email]
    else
      []
    end
  end

  def get_emails_from_pipl(update = true)
    account_id = nil
    account_id = "#{linkedin_id}@linkedin" unless linkedin_id.nil?
    account_id = "#{facebook_id}@facebook" unless facebook_id.nil?
    account_id = "#{twitter_id}@twitter" unless twitter_id.nil?
    return [] if account_id.nil?

    first, last = split_name
    person = PiplDb.find(first: first, last: last, account_id: account_id)
    return [] if person.nil?

    notes = person.to_hash
    notes.delete(:search_pointer)
    notes.delete(:emails)
    emails = person.emails.map(&:address)
    update(notes: notes, emails: emails, emails_available: emails.size) if update
    emails
  end

  def get_emails_from_google(update = true)
    domain_options = []
    email_options = []

    begin
      company = extract_company[/.[a-zA-Z\.\- &]+/]
      return [] if company.nil?

      rejected_list = %w(linkedin twitter wikipedia apple facebook)
      query = "#{company} contacts"
      serp = GoogleCustomSearchApi.search(query, page: 1, googlehost: get_googlehost)
      raw_domain_options = serp['items'].map { |i| i['displayLink'] }.reject { |i| rejected_list.any? { |a| i.include? a } }

      raw_domain_options.each do |domain|
        if two_part_domain? domain
          domain_options << domain[/[^\.]+\.[^\.]+\.[a-z]+$/]
        else
          domain_options << domain[/[^\.]+\.[a-z]+$/]
        end
      end

      domain_options.uniq!

      first, last = split_name
      email_options = %W(#{first}.#{last} #{first[0]}#{last} #{first} #{last}).map(&:downcase)


      checker = EmailChecker.new(domain_options, email_options)
      email = checker.find_right_email

      if email
        update(emails: [email], emails_available: 1) if update
        [email]
      else
        []
      end
    rescue => e
      logger.error "#{name}, #{position}, #{domain_options}, #{email_options}, #{e.message}"
      return []
    end

  end

  #TODO add advanced algorithm
  def get_googlehost
    location.include?('United Kingdom') ? 'google.co.uk' : 'google.com'
  end

  def self.get_emails_available(params)
    hash = {}
    request = UserRequest.new(params)
    ids = request.ids
    case request.source
      when :linkedin
        profiles = Profile.where(linkedin_id: ids)
        hash = profiles.pluck(:linkedin_id, :emails_available).to_h
        (ids - profiles.pluck(:linkedin_id)).each do |id|
          p = request[id]
          profile = Profile.create(linkedin_id: p.id, linkedin_url: "https://www.linkedin.com/profile/view?id=#{p.public_id}".freeze,
                                   name: p.name, position: p.position, location: p.location, photo: p.photo)
          profile.get_emails_from_google
          hash[p.id] = profile.emails_available
        end
      when :facebook

    end
    hash
  end

  def two_part_domain?(domain)
    TWO_PART_DOMAINS.any? { |tp| domain[/#{tp}$/] }
  end

  def trusted?(domain)
    TRUSTED_DOMAINS.include?(domain)
  end
end