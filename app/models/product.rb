class Product < ApplicationRecord

  def self.new_form_hash(item_hash)
    product = Product.new do |p|
      p.brand = item_hash["ItemAttributes"]["Brand"]
      p.name = item_hash["ItemAttributes"]["Title"]
      p.price = item_hash["OfferSummary"]["LowestNewPrice"]["FormattedPrice"]
      p.url = item_hash["DetailPageURL"]
      p.image = item_hash["LargeImage"]["URL"]
      p.asin = item_hash["ASIN"]
    end
  end
end
