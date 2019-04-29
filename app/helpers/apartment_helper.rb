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
    if name =~ /Lex and Leo/
      apts = get_apts(url)
      apts.each do |listing|
        create_apt_with_default_params(listing[0].split(' | ')[0].strip, listing[1], listing[2], listing[3], listing[4], listing[5], listing[6], url)
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
