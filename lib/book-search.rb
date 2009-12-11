require 'hpricot'
require 'net/http'
require 'uri'

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
		return "Title: #{@title} Author: #{@author} #{@price} #{@url} #{@img}"
	end
end

def fetch_flipkart(booktitle)
	host = "www.flipkart.com"
	doc = get_doc(host, "/search-books/" + booktitle)
	lis = doc.search("/html/body/div/div/div[3]/div[@class='search_result_list']/div[@class='search_result_item']")
	books = []
	lis.each do |li|
		img = li.search("div[@class='search_result_image']/a/img[@class='search_page_image']").to_s
		atag = li.search("div[@class='search_result_title']/a").first
		url = "http://" + host + atag.attributes['href']
		title = atag.search("h2/b/text()")
		price = li.search("div[@class='search_result_item_summary']/div[@class='search_result_item_info']/span[@class='search_results_price']/font/b/text()")
		author = li.search("div[@class='search_result_title']/span[@class='search_page_title_author']/a/b/text()")
		b = Book.new(title, author, img, price, url)
		books << b
	end
	return books
end

def fetch_infibeam(booktitle)
	host = "www.infibeam.com"
	doc = get_doc(host, "/Books/search?q=" + booktitle)
	lis = doc.search("/html/body/div/div[3]/div/div/div/div[2]/ul/li")
	
	#Handle cases where there are no results
	# sort by price :D
	books = []
	
	lis.each do |li|
		img = li.search("div[@class='img']/a/img").first.attributes['src']
		author = li.search("span/a/text()").first
		atag = li.search("span[@class='title']/h2/a").first
		url = "http://" + host + atag.attributes['href']
		title = atag.search("text()").to_s
		price = "Rs." + li.search("div[@class='price']/b/text()").to_s
		b = Book.new(title, author, img, price, url)
		#puts b.htmlize
		books << b
	end
	return books
end

def fetch_bookadda(booktitle)
	host = "www.bookadda.com"
	doc = get_doc(host, "/search/" + booktitle)
	lis = doc.search("/html/body/form/div/div[3]/div[2]/div[@class='searchresultcontainer']")
	
	books = []
	lis.each do |li|
		img = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='img']/a/img").first.attributes['src']
		atag = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='searchpagecontentcol']/div[@class='searchpagebooktitle']/a").first
		url = atag.attributes['href']
		title = atag.search("h2/text()")
		authors = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='searchpagecontentcol']/div[@class='searchbookauthor']/span[@class='underline']")
		author = ""
		authors.each do |a|
			author << a.search("a/text()").to_s << ","
		end
		price = li.search("div[@class='searchresulthorizontal-rightcol']/ul/li/span[@class='boldtext ourpriceredtext']/text()")
		b = Book.new(title, author, img, price, url)
		books << b
	end
	return books
end

def get_doc(host, path)
	#Handle redirects here
	h = Net::HTTP.new(host)
	resp, data = h.get(path, nil)
	
	data = data.gsub(/\r|\n/, '')
	return Hpricot(data)
end

if __FILE__ == $0
	booktitle = ARGV[0].gsub(/ /, '+').downcase
	puts "Searching for #{booktitle}..."

	puts "Flipkart.com"
	flip = fetch_flipkart(booktitle)
	flip.each do |f|
		puts f.htmlize
	end

	puts "Bookadda.com"
	adda = fetch_bookadda(booktitle)
	adda.each do |f|
		puts f.htmlize
	end

	puts "Infibeam.com"
	infi = fetch_infibeam(booktitle)
	infi.each do |f|
		puts f.htmlize
	end
end