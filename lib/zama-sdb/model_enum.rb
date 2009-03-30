module Zama

  module SDB

    class ModelEnum < Results
      include Enumerable
      attr_accessor :instance_klass

      def each
        @raw.search("//Item").each do |raw_item|
          yield((instance_klass || Results).new(raw_item))
        end
      end

      def next_token
        @raw.search("//NextToken").inner_text
      end
      
      def last
        return (instance_klass || Results).new(@raw.search("//Item").last)
      end
      
      def size
        @raw.search("//Item").size
      end

    end

  end
end
