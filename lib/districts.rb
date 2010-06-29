class Districts
  
  require 'open-uri'
  require 'uri'
  require 'ostruct'
  
  LANDMARKS = {'Carnegie Hall' => '881 7th Avenue, New York, NY 10019', 
    'Yankee Stadium' => '1 East 161st Street, Bronx, NY 10451',
    'Brooklyn Botanic Garden' => '1000 Washington Avenue, Brooklyn, NY 11225',
    'Astroland Amusement Park' => '834 Surf Avenue, Brooklyn, NY',
    'Shea Stadium' => '12301 Roosevelt Avenue, Corona, NY 11368'
    }
  
  def self.geocode(address)
    url = "http://tinygeocoder.com/create-api.php?q=#{URI.escape(address)}"
    response = open(url).read
    lat, lng = response.split(',')
  end
  
  def self.fetch_house_district(lat, lng)
    url = "http://projects.nytimes.com/districts/lookup.json?lat=#{lat}&lng=#{lng}"
    response = open(url).read
    d = JSON.parse(response)['results'].detect { |d| d['level'] == 'U.S. House'}
    district = OpenStruct.new(d)
  end
  
  def self.fetch_current_member(district)
    url = "http://politics.nytimes.com/congress/svc/politics/v3/us/legislative/congress/members/house/NY/#{district}/current.json"
    response = open(url).read
    member = JSON.parse(response)['results'].first
    member["bioguide"] = member["id"] # OpenStruct doesn't call method_missing for id, so override
    OpenStruct.new(member)
  end
  
  def self.landmarks
    landmarks = []
    Districts::LANDMARKS.each_pair do |name, address|
      l = OpenStruct.new
      l.name = name
      l.address = address
      lat, lng = Districts.geocode(address)
      district = Districts.fetch_house_district(lat, lng)
      member = Districts.fetch_current_member(district.district)
      l.member = member.name
      l.tt_url = member.times_topics_url
      l.party = member.party
      l.bioguide = member.bioguide
      landmarks << l
    end
    landmarks
  end
end