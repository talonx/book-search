class Book
        attr_accessor :title
        attr_accessor :author
        attr_accessor :img
        attr_accessor :price
        attr_accessor :url

        def initialize(title, author, img, price, url)
                @title = title
                @author = author
                @img = img
                @price = sanitize(price)
                @url = url
        end

        def htmlize()
 		"Title: <b> #{@title} </b> Author: #{@author} <br/> #{@price} <br/> <img src='#{@img}' /> <br/><a target='_blank' href='#{@url}'>#{@url}</a> </br>"
        end

	private
	def sanitize(price)
		price.gsub(/,/, '').gsub(/Rs\./, '').strip.to_i
	end
end
