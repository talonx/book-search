require 'rubygems'
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
		return "Title: <b> #{@title} </b> Author: #{@author} <br/> #{@price} <br/> <img src='#{@img}' /> <br/><a target='_blank' href='#{@url}'>#{@url}</a> </br>"
	end
end

def fetch_flipkart(booktitle)
	host = "www.flipkart.com"
	puts "Searching Flipkart..."
	doc = get_doc(host, "/search-books/" + booktitle)
	lis = doc.search("/html/body/div/div/div[3]/div[@class='search_result_list']/div[@class='search_result_item']")
	books = []
	lis.each do |li|
		img = li.search("div[@class='search_result_image']/a/img[@class='search_page_image']").first.attributes['src']
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
	puts "Searching Infibeam..."
	doc = get_doc(host, "/Books/search?q=" + booktitle)
	lis = doc.search("/html/body/div[@id='custom-doc']/div[@id='bd']/div/div/div/div[@id='search_result']/ul[@class='search_result']/li")
	
	#Handle cases where there are no results
	# sort by price :D
	books = []
	
	lis.each do |li|
		img = li.search("div[@class='img']/a/img").first.attributes['src']
		author = li.search("span/a/text()").first
		atag = li.search("h2[@class='simple']/a").first
		if atag == nil
			atag = li.search("span[@class='title']/h2[@class='simple']/a").first
		end
		url = "http://" + host + atag.attributes['href']
		title = atag.search("text()").to_s
		price = "Rs." + li.search("div[@class='price']/b/text()").to_s
		b = Book.new(title, author, img, price, url)
		books << b
	end
	return books
end

def fetch_bookadda(booktitle)
	host = "www.bookadda.com"
	puts "Searching Bookadda..."
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

def fetch_indiaplaza(booktitle)
	host = "www.indiaplaza.in"
	puts "Searching Indiaplaza..."
	doc = get_doc(host, "/search.aspx?catname=Books&srchkey=title&srchVal=" + booktitle)
	
	lis = doc.search("/html/body/form[@name='aspnetForm']/div[@id='ctl00_mPageMaster']/div/table/tr[2]/td[4]/div[@id='ctl00_CPMiddle_srchItemsDiv']/span[@id='ctl00_CPMiddle_BookItems_Datalis1']/span/div[@class='bline']/table/tr")
	
	books = []
	lis.each do |li|
		img = li.search("td/a/img").first.attributes['src']
		atag = li.search("td[2]/div/h1[@class='h5copy']/a").first
		url = "http://" + host + atag.attributes['href']
		title = atag.search("strong/text()")
		authors = li.search("td/div/div/span[@class='copy']/div/span[@class='copy']/h1[@class='h5copy']/a")
		author = ""
		authors.each do |a|
			author << a.inner_text << ","
		end
		price = li.search("td[3]/div/span[@class='detailcaps']/span[@class='copy']/strong/text()")
		b = Book.new(title, author, img, price, url)
		books << b
	end
	return books
end

def fetch_storez(booktitle)
	host = "www.thestorez.com"
	puts "Searching TheStorez..."
	doc = get_doc(host, "/catalogsearch/result/?q=" + booktitle)
	
	#The listing-item class name has a trailing space
	lis = doc.search("/html/body/div[2]/div/div/div[@class='listing-type-list catalog-listing']/div[@class='listing-item ']")
	
	books = []
	lis.each do |li|
		img = li.search("table/tr/td[2]/div[@class='product-image']/a/img").first.attributes['src']
		atag = li.search("table/tr/td[3]/div[@class='product-shop']/table/tr/td/h5/a").first
		url = atag.attributes['href']
		title = atag.search("/text()")
		authors = li.search("table/tr/td[3]/div[@class='product-shop']/table/tr[2]/td/b[1]/text()")
		price = li.search("table/tr/td[3]/div/table/tr[2]/td[2]/div[@class='price-box']/span[@class='special-price']/span[@class=''price]/span[@class='nobr']/text()")
		b = Book.new(title, authors, img, price, url)
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

def write(mes, f)
	f.write(mes)
end

def display(bookstore, booktitle, results, file)
	write(bookstore, file)
	results.each do |f|
		write( "----------------------------------------<br/>", file)
		write( f.htmlize, file)
	end
end

if __FILE__ == $0
	title = ARGV[0]
	if title == nil
		puts "Usage: ruby book-search.rb booktitle  (Enclose in quotes if spaces present)"
		exit
	end

	puts "Searching for #{title}..."
	booktitle = title.gsub(/ /, '+').downcase
	
	file = File.open("search.html", "w")	

	flip = fetch_flipkart(booktitle)
	display("<h2>Flipkart.com</h2>", booktitle, flip, file)

	infi = fetch_infibeam(booktitle)
	display("<h2>Infibeam.com</h2>", booktitle, infi, file)

	adda = fetch_bookadda(booktitle)
	display("<h2>Bookadda.com</h2>", booktitle, adda, file)

	storez = fetch_storez(booktitle)
	display("<h2>TheStorez.com</h2>", booktitle, storez, file)

#	indi = fetch_indiaplaza(booktitle)
#	display("<h2>Indiaplaza.in</h2>", booktitle, indi, file)
	
	write( "----------------------------------------<br/>", file)

	puts "Results saved in search.html"
	
	file.close()
end