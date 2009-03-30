module Zama

  module SDB

    class Model
      attr_writer :name

      def initialize(raw)
        @raw = raw
      end

      def self.domain(d=nil)
        @@domains ||= {}
        if d
          @@domains[self] = d
        end
        @@domains[self]
      end

      def self.all(token=nil)
        self.select("select * from #{domain}",token)
      end

      def self.select(qstr,token=nil)
        res = ModelEnum.select(qstr,token)
        res.instance_klass = self
        res
      end

      def self.find(name)
        params = {
          "Action" => "GetAttributes",
          "DomainName" => domain.to_s,
          "ItemName" => name
        }
        raw_item = Results.get(params).raw.search("//GetAttributesResult")
        if raw_item && !raw_item.empty?
          res = self.new(raw_item.first)
          res.name = name
          return res
        end
        return nil
      end

      def self.create(name,values,replace=true)
        values["object_type"] = self.to_s
        put(name,values,replace)
      end

      def self.put(name,values,replace=true)
        Results.put_attributes(name,domain,values,replace)
      end

      def self.destroy(name)
        Results.delete_attributes(name,domain)
      end

      def self.delete_attributes(name,attributes)
        Results.delete_attributes(name,domain,attributes)
      end
      
      def self.update(*args); self.put(*args); end;
      def self.create_or_update(*args); self.create(*args); end;      
      
      def update(*args); put(*args); end;
      def create_or_update(*args); create(*args); end;                  

      def create(values,replace=true)
        values["object_type"] = self.class.to_s
        put(value,replace)
      end

      def put(values,replace=true)
        Results.put_attributes(name,domain,values,replace)
      end

      def destroy
        Results.delete_attributes(name,domain)
      end

      def domain()
        self.class.domain
      end

      def name()
        @name || @raw.at("Name").inner_text
      end

      def [](attr_name)
        res = get_attr_values(attr_name)
        return nil if res.empty?
        return res.first if res.size == 1
        return res
      end

      def get_attr_values(attr_name)
        res = []

        @raw.search("//Attribute[Name:contains('#{attr_name}')]").each do |attr|
          if attr.at("Name").inner_text == attr_name
            res << attr.at("Value").inner_html
          end
        end
        return res
      end

      def method_missing(meth_sym,*args)
        return super.method_missing(meth_sym,*args) unless args.nil? || args.empty?
        res = get_attr_values(meth_sym.to_s)
        return super.method_missing(meth_sym,*args) if res.empty?
        return res.first if res.size == 1
        res
      end

    end

  end

end
