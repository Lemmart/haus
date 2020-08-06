module ApartmentHelper
  #########################
  ##### Filtering  & ######
  #########################

  def sort(tag)
    case tag
    when /^price$/i
      return @apartments.order('price').order('name')
    when /^sq_ft$/i
      return @apartments.order('sq_ft').order('name')
    when /^price$/i
      return @apartments.order('price').order('name')
    else 
      return @apartments.order('name').order('price')
    end
  end

  def filter(tag = "empty")
    case tag
    # apply filters saved in session if none are given
    when /^empty$/i, /^Clear Filters$/i
      session[:name_filter] = ""
      session[:price_filter] = ""
      return Apartment.all.order('name').order('price')
    when /^\$([0-9]*)$/i
      session[:price_filter] = $1
      if session[:name_filter].blank?
        return Apartment.all.where("price < #{session[:price_filter]}").order('name').order('price')
      else
        return Apartment.all.where("name = '#{session[:name_filter]}' AND price < #{session[:price_filter]}").order('name').order('price')
      end
    when /^([a-z ]*)$/i
      session[:name_filter] = $1
      if session[:price_filter].blank?
        return Apartment.all.where(:name => session[:name_filter]).order('name').order('price')
      else
        return Apartment.all.where("name = '#{session[:name_filter]}' AND price < #{session[:price_filter]}").order('name').order('price')
      end
    else
      session[:name_filter] = ""
      session[:price_filter] = ""
      return Apartment.all.order('name').order('price')
    end
  end

  #########################
  ### Apartment Creation ##
  ######### Below #########
  #########################

  def create_apt_with_default_params(unit_num, style, name, price, bed_bath, sq_ft, availability, link)
    begin
      Apartment.create(
        name: name,
        style: style,
        price: price,
        sq_ft: sq_ft,
        unit_num: unit_num,
        bed_bath: bed_bath,
        availability: availability,
        link: link
        )
    rescue Exception
    end
  end

  def get_belvedere(url)
    require 'open-uri'
    page = Nokogiri::HTML(open(url))
    apt_types = page.css('h3').text.gsub!('*','').split(/Floor Plan : /).drop(1)
    # Form is: "#apt_numSq_ft$monthly_price$depositDetails Amenity1 Amenity2 move-in_date"
    raw_listings = page.css('table').children
    idx = 0
    listings = []
    raw_listings.each do |apt|
      if idx % 3 == 2
        listings.append(apt.text.squish)
      end
      idx += 1
    end
    # this loop likely needs work if more than 1 listing per type of apartment is shown! (probably iterate through!)
    apt_ct = 0
    listings.each do |listing|
      matches = listing.match(/([0-9]{3})([0-9]{3})\$(.*)\$(.*)Details.* (.*)$/).captures
      unit_num = matches[0]
      sq_ft = matches[1]
      price = matches[2].gsub('$','').gsub(',','')
      available = matches[-1]
      style = apt_types[apt_ct].match(/(.*) - /).captures[0]
      beds_and_baths = apt_types[apt_ct].match(/([0-9]) Bedroom, ([0-9]) Bathroom/).captures
      bed_bath = "#{beds_and_baths[0]} bed / #{beds_and_baths[1]} bath"
      apt_ct += 1
      create_apt_with_default_params(unit_num, style, 'Belvedere', price, bed_bath, sq_ft, available, url)
    end
  end

  def get_lex_and_leo(url)
    require 'humanize'

    apts = get_apts(url)
    dates_available = Nokogiri::HTML(open(url)).at('table').to_s.strip().scan(/data-available=\".*\"/)
    apt_ct = 0
    apts.each do |listing|
      date = dates_available[apt_ct].gsub(/^.*=/,'')[/[0-9]+\/[0-9]+\/[0-9]+/].split('/')
      date[-1] = "20" + date[-1]
      date = [date[-1].to_i,date[0].to_i,date[1].to_i]
      if Date.valid_date?(date[0],date[1],date[2]) && Date.parse(date.join("/")) < Date.today
        date = "Available since: " + Date.parse(date.join("/")).strftime('%m/%d/%Y')
      else
        date = Date.parse(date.join("/")).strftime('%m/%d/%Y')
      end
      unit = listing[0].split(' | ')[0].strip
      # PENTHOUSE -> 12th floor
      unit_num = unit =~ /PH([0-9]*)/ ? "12#{$1}" : unit
      price = listing[3].gsub('$','').gsub(',','')
      beds_and_baths = listing[4].split('/')
      bed_bath = beds_and_baths[0] + " bed / " + beds_and_baths[1] + " bath"
      listing[1] == "Studio" ? style = "Studio" : style = "#{listing[1].match(/([0-9]) Bed.*/i).captures[0].humanize.capitalize} Bedroom"
      apt_ct += 1
      create_apt_with_default_params(unit_num, style, "Lex and Leo", price, bed_bath, listing[5], date, url)
    end
  end

  def get_claridge_house(url)
    listings = Nokogiri::HTML(open(url)).css('div.listings').children
      listings.each do |listing|
        unit_num = listing.to_s.scan(/[0-9][0-9]*[A-Z]/i)[0]
        if !listing.blank? && !unit_num[0].blank?
          table_text = Nokogiri::HTML(open("#{url}/#{unit_num}")).css('tr > td').text
          date = Date.parse(table_text.match(/Available On([a-z]* [0-9]*, [0-9]*)Contact.*/i).captures[0])
          date = Date.today > date ? date = "Available since: " + date.strftime('%m/%d/%Y') : date.strftime('%m/%d/%Y')
          style = table_text.match(/Size([a-z ]*)Price.*/i).captures[0]
          price = table_text.match(/Price\$(.*)\/month.*/i).captures[0]
          case style
          when /Efficiency/i
            bed_bath = '0 bed / ? bath'
          when /one bedroom/i
            bed_bath = '1 bed / ? bath'
          when /two bedroom/i
            bed_bath = '2 bed / ? bath'
          else
            bed_bath = '? bed / ? bath'
          end
          create_apt_with_default_params(unit_num, style, "Claridge House", price, bed_bath, "", date, url)
        end
      end
  end

  def get_apts(url)
    # https://readysteadycode.com/howto-parse-html-tables-with-nokogiri
    require 'open-uri'
    tries = 0
    begin
      page = Nokogiri::HTML(open(url))
    rescue OpenURI::HTTPRedirect => redirect
      url = redirect.uri # assigned from the "Location" response header
      retry if (tries -= 1) > 0
      raise
    end
    table = page.at('table')
    apts = []
    table.search('tr').each do |tr|
      cells = tr.search('th','td')
      if cells[0].name != 'th'
        listing = []
        cells.each do |cell|
          listing.append(cell.text.strip)
        end
        apts.append(listing)
      end
    end
    return apts
  end

  def parse_and_create_apartments(url, name)
    require 'humanize'
    if name =~ /Lex and Leo/
      get_lex_and_leo(url)
    elsif name =~ /Lurgan/
      apts = get_apts(url)
      apts.each do |listing|
        num_beds = listing[3].match(/([0-9]) bed.*/i).captures[0]
        num_beds == "0" ? style = "Studio" : style = "#{num_beds.humanize.capitalize} Bedroom"
        create_apt_with_default_params(listing[1], style, listing[0], listing[2].gsub('$','').gsub(',',''), listing[3], listing[4].split(' ')[0], listing[6], url)
      end
    elsif name =~ /Belvedere/
      get_belvedere(url)
    elsif name =~ /Claridge House/
      get_claridge_house(url)
    # elsif name =~ //
    end
  end
end
