module ApartmentHelper
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

  def get_apts(url)
    # https://readysteadycode.com/howto-parse-html-tables-with-nokogiri
    require 'open-uri'
    page = Nokogiri::HTML(open(url))
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
    require 'date'
    if name =~ /Lex and Leo/
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
        apt_ct += 1
        create_apt_with_default_params(listing[0].split(' | ')[0].strip, listing[1], listing[2], listing[3], listing[4], listing[5], date, url)
      end
      # puts ">>>>>>>>>>>>>>>"
      # page = Nokogiri::HTML(open(url))
      # table = page.at('table#availability').at('tbody')
      # puts table.at('tr').search('td').at('td.date').inspect
      # puts "<<<<<<<<<<<<<<<"
    elsif name =~ /Lurgan/
      apts = get_apts(url)
      apts.each do |listing|
        create_apt_with_default_params(listing[1], "", listing[0], listing[2], listing[3], listing[4].split(' ')[0], listing[6], url)
      end
    elsif name =~ /Belvedere/
      apts = get_apts(url)
      apts.each do |listing|
        bed = listing[1].to_s + "bed"
        bath = listing[2].to_s + "bath"
        if listing[6] =~ /Availability/
          create_apt_with_default_params("", listing[0], "The Belvedere", listing[4], "#{bed}/#{bath}", listing[3], "Available Now", url)
        end
      end
    # elsif name =~ //
    end
  end
end
