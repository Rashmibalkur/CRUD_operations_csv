require 'csv'

class ProductUpload
  def initialize
    @products = {}
    check_for_file_path
    upload_data(ARGV[0])
  end

  def check_for_file_path
    if ARGV.length == 0
      puts "Please provide csv file path. Ex: /home/user/Documents/products.csv"
      exit
    end
  end

  def upload_data(file_path)
    begin
      csv_file = File.read(file_path) 
      csv = CSV.parse(csv_file, :headers => true)
      status = check_mandatory_fields(csv.headers)
      if status
        csv.each do |row|
          @products[get_id] = Product.new(row.to_hash)
        end
        take_user_input
      else
        puts "Mandatory fiels are id,name,price."
        exit
      end
    rescue 
      puts "No File Found."
    end
  end

  def take_user_input
    puts 'Please enter number related to which operation u would like to perform: '
    puts "1. Insert"
    puts "2. Update"
    puts "3. Delete"
    puts "4. Search"
    input = $stdin.gets.chomp
    initiate_process(input)
  end

  def initiate_process(input)
    display_products
    case input
    when "1"
      create
    when "2"
      update_product
    when "3"
      delete_product
    when "4"
      search_product
    else
      take_user_input
    end
  end

  def create
    product = Product.new
    puts "Enter Unique ID."
    product.product_id = $stdin.gets.chomp
    pid = check_for_uniqueness(product.product_id)
    if pid.nil?
      puts "Enter Name."
      product.name = $stdin.gets.chomp
      puts "Enter Price."
      product.price = $stdin.gets.chomp
      @products[get_id] = product
      export_data(@products)
    else
      puts "Prodcut ID already exists!"
      take_user_input
    end
  end

  def export_data(data)
    file_name = "#{Dir.pwd}/"+"#{Time.now.strftime("%d%m%Y%H%M%S").to_s}.csv"
    CSV.open("#{file_name}","w") do |csv|
      header = ["Product ID","Name","Price"]
      csv << header
      data.each do |id,product|
        csv << [product.product_id,product.name,product.price]
      end
    end
    puts "PLease find the csv here - #{file_name}"
  end

  def update_product
    puts "Enter ID of a product to be updated!"
    input_id = $stdin.gets.chomp
    product = @products.map{|i,c| c if c.product_id == input_id}.compact.last
    if !product.nil?
      puts "Enter name to be changed."
      name = $stdin.gets.chomp
      puts "Enter price to be changed."
      price = $stdin.gets.chomp
      product.name = name if name != ""
      product.price = price if price != ""
    else
      puts "No product found for ID - #{input_id}."
      take_user_input
    end
    export_data(@products)
  end

  def delete_product
    puts "Enter Product ID to be deleted!"
    input_id = $stdin.gets.chomp
    product = @products.map{|i,c| c if c.product_id == input_id}.compact.last
    if !product.nil?
      @products.delete(input_id)
      export_data(@products)
    else
      puts "No product found for ID - #{input_id}."
      take_user_input
    end
  end

  def search_product
    puts "Enter search value to which products to be matched."
    search_key = $stdin.gets.chomp
    result_hash = {}
    @products.map{|i,p| result_hash[i] = [p.name,p.product_id,p.price]}
    final_result = result_hash.map{|x,v| x if (v.detect{|z| z.to_s =~ /#{search_key}/})}.compact
    @result = @products.select{|p| final_result.include?(p)}
    if @result.empty?
      puts "No Product Found."
    else
      export_data(@result)
    end
  end

  private

  def get_id
    id = (@products.to_a.length + 1).to_s
    return id
  end

  def check_for_uniqueness(product_id)
    pid = @products.map{|i,p| i if (i == product_id)}.compact.last
    return pid
  end

  def check_mandatory_fields(csv_headers)
    fields = ["id","name","price"]
    extra = fields - csv_headers
    if extra.empty?
      return true
    else
      return false
    end
  end

  def display_products
    puts "List of products are:"
    print @products.map{|i,p| puts "Product ID: #{p.product_id} : #{p.name}"}.flatten.compact
    puts ""
  end

end

# Product class
class Product
  attr_accessor :product_id, :name, :price, :id

  def initialize(row={})
    @product_id = row["id"]
    @name = row["name"]
    @price = row["price"]
  end

end

productUpload = ProductUpload.new