require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'
require 'book.rb'
require 'result.rb'

class BookSearch
	
#	attr_accessor: @booktitle

	def initialize(booktitle)
		@booktitle = booktitle
	end

	def searchbooks
		flip = Result.new('flipkart', fetch_flipkart(@booktitle))
		infi = Result.new('infibeam', fetch_infibeam(@booktitle))
		adda = Result.new('bookadda', fetch_bookadda(@booktitle))
		storez = Result.new('thestorez', fetch_storez(@booktitle))
		return [flip, infi, adda, storez]
#		return [flip]
	end

	private
	def fetch_flipkart(otitle)
		booktitle = otitle.gsub(/ /, '+').downcase
		host = "www.flipkart.com"
		puts "Searching Flipkart..."
		doc = get_doc(host, "/search-books/" + booktitle)
		lis = doc.search("/html/body/div/div/div[3]/div[@class='search_result_list']/div[@class='search_result_item']")
		books = []
		lis.each do |li|
			img = li.search("div[@class='search_result_image']/a/img[@class='search_page_image']").first.attributes['src']
			atag = li.search("div[@class='search_result_title']/a").first
			url = "http://" + host + atag.attributes['href']
			title = li.search("div[@class='search_result_title']/h2/b/text()").to_s
			if (title.downcase.index(otitle) == nil)
				next
			end
			price = li.search("div[@class='search_result_item_summary']/div[@class='search_result_item_info']/span[@class='search_results_price']/font/b/text()").first.to_s
			author = li.search("div[@class='search_result_title']/span[@class='search_page_title_author']/a/b/text()")
			b = Book.new(title, author, img, price, url)
			books << b
		end
		return books
	end

	def fetch_infibeam(otitle)
		booktitle = otitle.gsub(/ /, '+').downcase
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
			if (title.downcase.index(otitle) == nil)
				next
			end
			price = li.search("div[@class='price']/b/text()").first.to_s
			b = Book.new(title, author, img, price, url)
			books << b
		end
		return books
	end

	def fetch_bookadda(otitle)
		booktitle = otitle.gsub(/ /, '+').downcase
		host = "www.bookadda.com"
		puts "Searching Bookadda..."
		doc = get_doc(host, "/search/" + booktitle)
		lis = doc.search("/html/body/form/div/div[3]/div[2]/div[@class='searchresultcontainer']")
		
		books = []
		lis.each do |li|
			img = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='img']/a/img").first.attributes['src']
			atag = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='searchpagecontentcol']/div[@class='searchpagebooktitle']/a").first
			url = atag.attributes['href']
			title = atag.search("h2/text()").to_s
	                if (title.downcase.index(otitle) == nil)
                                next
                        end
			authors = li.search("div[@class='searchresulthorizontal-leftcol']/div[@class='searchpagecontentcol']/div[@class='searchbookauthor']/span[@class='underline']")
			author = ""
			authors.each do |a|
				author << a.search("a/text()").to_s << ","
			end
			price = li.search("div[@class='searchresulthorizontal-rightcol']/ul/li/span[@class='boldtext ourpriceredtext']/text()").first.to_s
			b = Book.new(title, author, img, price, url)
			books << b
		end
		return books
	end

	def fetch_indiaplaza(otitle)
		booktitle = otitle.gsub(/ /, '+').downcase
		host = "www.indiaplaza.in"
		puts "Searching Indiaplaza..."
		doc = get_doc(host, "/search.aspx?catname=Books&srchkey=title&srchVal=" + booktitle)
		
		lis = doc.search("/html/body/form[@name='aspnetForm']/div[@id='ctl00_mPageMaster']/div/table/tr[2]/td[4]/div[@id='ctl00_CPMiddle_srchItemsDiv']/span[@id='ctl00_CPMiddle_BookItems_Datalis1']/span/div[@class='bline']/table/tr")
		
		books = []
		lis.each do |li|
			img = li.search("td/a/img").first.attributes['src']
			atag = li.search("td[2]/div/h1[@class='h5copy']/a").first
			url = "http://" + host + atag.attributes['href']
			title = atag.search("strong/text()").to_s
	                if (title.downcase.index(otitle) == nil)
                                next
                        end

			authors = li.search("td/div/div/span[@class='copy']/div/span[@class='copy']/h1[@class='h5copy']/a")
			author = ""
			authors.each do |a|
				author << a.inner_text << ","
			end
			price = li.search("td[3]/div/span[@class='detailcaps']/span[@class='copy']/strong/text()").first.to_s
			b = Book.new(title, author, img, price, url)
			books << b
		end
		return books
	end

	def fetch_storez(otitle)
		booktitle = otitle.gsub(/ /, '+').downcase
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
			title = atag.search("/text()").to_s
	                if (title.downcase.index(otitle) == nil)
                                next
                        end

			authors = li.search("table/tr/td[3]/div[@class='product-shop']/table/tr[2]/td/b[1]/text()")
			price = li.search("table/tr/td[3]/div/table/tr[2]/td[2]/div[@class='price-box']/span[@class='special-price']/span[@class=''price]/span[@class='nobr']/text()").first.to_s
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
end

def write(mes, f)
	f.write(mes)
end

if __FILE__ == $0
	title = ARGV[0]
	if title == nil
		puts "Usage: ruby book-search.rb booktitle  (Enclose in quotes if spaces present)"
		exit
	end

	puts "Searching for #{title}..."

	bs = BookSearch.new(title)
	res = bs.searchbooks()
	
	file = File.open("search.html", "w")	

	res.each do |r|
		storename = r.storename
		write(storename, file)
		write( "<br/>----------------------------------------<br/>", file)
		results = r.books
		results.each do |f|
	                write( f.htmlize, file)
			write('<br/>', file)
		end
		write( "<br/>----------------------------------------<br/>", file)
	end
	
	puts "Results saved in search.html"
	
	file.close()
end
