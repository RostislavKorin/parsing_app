module AmazonAPI
  ENDPOINT = 'webservices.amazon.com'
  REQUEST_URI = '/onca/xml'

  def by_keyword_and_category(keywords, category)
    params = {
    "Service" => "AWSECommerceService",
    "Operation" => "ItemSearch",
    "AWSAccessKeyId" => Rails.application.secrets.AWS_ACCESS_KEY_ID,
    "AssociateTag" => Rails.application.secrets.AWS_ASSOCIATES_TAG,
    "SearchIndex" => category,
    "ResponseGroup" => "Images,ItemAttributes,Offers",
    "Keywords" => keywords
  }
    url = generate_request_url(params)
    results = HTTParty.get(url).parsed_response
    item_hash = results["ItemSearchResponse"]["Items"]["Item"]
    [item_hash].flatten.each do |item|
      matching_product = Product.new_form_hash(item)
      matching_product.save
    end
  end

  def by_asin(asin)
    params = {
      "Service" => "AWSECommerceService",
      "Operation" => "ItemLookup",
      "AWSAccessKeyId" => Rails.application.secrets.AWS_ACCESS_KEY_ID,
      "AssociateTag" => Rails.application.secrets.AWS_ASSOCIATES_TAG,
      "ItemId" => asin,
      "IdType" => "ASIN",
      "ResponseGroup" => "Images,Offers,ItemAttributes",
      "Condition" => "New"
    }
    url = generate_request_url(params)
    results = HTTParty.get(url).parsed_response
    item_hash = results["ItemLookupResponse"]["Items"]["Item"]
    matching_product = Product.new_form_hash(item_hash)
  end

  def generate_request_url(params)
    params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")
    canonical_query_string = params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')
    string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), Rails.application.secrets.AWS_SECRET_KEY, string_to_sign)).strip()
    request_url = "http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  end
end
