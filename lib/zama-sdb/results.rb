module Zama
  module SDB
    class Results
      
      attr_accessor :raw
      
      def initialize(xml)
        @raw = (xml.is_a? String) ? Hpricot.XML(xml) : xml
      end      
      
      def self.prepare_url(params)
        params = Zama::SDB.opts.merge(params)
        params["Timestamp"] = Time.now.gmtime.iso8601
        secret_key = params.delete("AWSSecretAccessKey")
        url = params.delete(:url)
        qs = []
        data = ""

        params.keys.sort_by{|k| k.to_s.upcase}.each do |k|
          v = params[k]
          next unless v
          v = v.join(",") if v.is_a?(Array)
          qs << "&#{k}=#{CGI::escape(v.to_s)}"
          data << "#{k}#{v.to_s}"
        end

        digest = OpenSSL::Digest::Digest.new("sha1")
        hmac = OpenSSL::HMAC.digest(digest,secret_key,data)
        signature = Base64.encode64(hmac).strip

        url = "#{url}?Signature=#{CGI::escape(signature)}#{qs}"
        puts "Zama::SDB querying: #{url}"
        url
      end

      def self.get(params,headers={})
        self.new(RestClient.get(prepare_url(params),headers))
      end

      def self.post(params,payload,headers={})
        self.new(RestClient.post(prepare_url(params),payload,headers))
      end
      
      def self.delete(params,headers={})
        self.new(RestClient.delete(prepare_url(params),headers))
      end

      def self.put(params,payload,headers={})
        self.new(RestClient.put(prepare_url(params),payload,headers))
      end      
      
      def self.put_attributes(name,domain,values,replace=true)
        params = {
          "Action" => "PutAttributes",
          "DomainName" => domain.to_s,
          "ItemName" => name
        }
        index = 0
        values.each do |k,values|
          ([] << values).flatten.each do |v|
            params["Attribute.#{index}.Name"] = k.to_s
            params["Attribute.#{index}.Value"] = v.to_s
            params["Attribute.#{index}.Replace"] = replace
            index+=1
          end
        end
        self.put(params,values)
      end

      def self.delete_attributes(name,domain,values={})
        params = {
          "Action" => "DeleteAttributes",
          "DomainName" => domain.to_s,
          "ItemName" => name
        }
        index = 0
        values.each do |k,values|
          ([] << values).flatten.each do |v|
            params["Attribute.#{index}.Name"] = k.to_s
            params["Attribute.#{index}.Value"] = v.to_s
            index+=1
          end
        end
        self.delete(params,values)
      end      
      
      def self.select(qstr,token=nil)
        #         qstr = qstr.to_a.compact
        #         qstr << "[ 'object-type' = '#{my_class_name}' ]"
        #         params = {
        #           "Action" => "QueryWithAttributes",
        #           "QueryExpression" => qstr.join(" intersection "),
        #           "DomainName" => domain
        #         }
        #         params["MaxNumberOfItems"] = max if max
        
        params = {
          "Action" => "Select",
          "SelectExpression" => qstr,
          "NextToken" => token
        }
        
        self.get(params)
      end      
      
    end
  end
end
