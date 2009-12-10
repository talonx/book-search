require 'hpricot'
require 'net/http'

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
		@price = price
		@url = url
	end

	#Implement tags
	def htmlize()
		return "Title: #{@title} Author: #{@author} #{@price} #{@url}"
	end
end

def fetch_infibeam(host, url)
	h = Net::HTTP.new(host)
	resp, data = h.get(url, nil)
	data = data.gsub(/\r|\n/, '')
#	p data

	#Handle cases where there are no results
	# sort by price :D
	doc = Hpricot(data)
	lis = doc.search("/html/body/div/div[3]/div/div/div/div[2]/ul/li");
	
	books = []
	
	lis.each do |li|
		img = li.search("div[@class='img']/a/img").first
		author = li.search("span/a/text()").first
		atag = li.search("span[@class='title']/h2/a").first
		url = "http://" + host + atag.attributes['href']
		title = atag.search("text()").to_s
		price = "Rs. " + li.search("div[@class='price']/b/text()")
		b = Book.new(title, author, img, price, url)
		books << b
	end

	puts books
end



if __FILE__ == $0
	fetch_infibeam(ARGV[0], ARGV[1])
end