class Result

	attr_accessor :books
	attr_accessor :storename

	def initialize(storename, books)
		@storename = storename
		@books = sort(books)
	end

	private
	def sort(books)
		books.sort_by { |b| b.price }
	end
end
