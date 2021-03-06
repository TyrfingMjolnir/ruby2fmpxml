class FileMakerXMLMaker

  attr_reader :caller_object

  def initialize(caller_object)
    @caller_object = caller_object
  end

  def to_fmpxml
    metadata_fields = ["Input", "TEXT", "Result", "TEXT"]
    builder = generate_metadata(metadata_fields) do |xml|
      xml.RESULTSET(FOUND: 1) do
        xml.ROW(MODID: "0", RECORDID: "0") do
          xml.COL do
            xml.DATA @caller_object.to_s
          end
        end
      end
    end
    builder.to_xml
  end

  private

  def generate_metadata(metadata_fields, &block)
    builder = headers do |xml|
      xml.METADATA do
        metadata_fields.each_slice(2) do |value_type|
          xml.FIELD(EMPTYOK: "YES", MAXREPEAT: "1", NAME: value_type[0], TYPE: value_type[1])
        end
      end
      yield(xml) if block_given?
    end
  end

  def headers(&block)
    Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.FMPXMLRESULT(xmlns:"http://www.filemaker.com/fmpxmlresult") do
        xml.ERRORCODE 0
        xml.PRODUCT(BUILD: "03-21-2013", NAME: "FileMaker", VERSION: "ProAdvanced 12.0v4")
        xml.DATABASE(DATEFORMAT: "D/m/yyyy", LAYOUT: "", NAME: "Database.fmp12", RECORDS: 1, TIMEFORMAT: "h:mm:ss a")
        yield(xml) if block_given?
      end
    end
  end
end
