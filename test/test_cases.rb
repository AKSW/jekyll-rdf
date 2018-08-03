require 'test_helper'
require 'yaml'

class TestCases < Test::Unit::TestCase
  context "cases/sciMath" do
    setup do
      @source = File.join(File.dirname(__FILE__), "cases/sciMath")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      site.process
    end

    should "test different math filters on scinitfic notation" do
      content = []
      file = File.read("#{@source}/_site/math.html")
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert "7".eql?(content[1]), "expected: >7< was: >#{content[1]}<"
      assert "8.9".eql?(content[2]), "expected: >8.9< was: >#{content[2]}<"
      assert "4200000000".eql?(content[3]), "expected: >4200000000< was: >#{content[3]}<"
      assert "0.0200".eql?(content[4]), "expected: >0.020< was: >#{content[4]}<"
      assert "-7".eql?(content[5]), "expected: >-7< was: >#{content[5]}<"
      assert "-8.9".eql?(content[6]), "expected: >-8.9< was: >#{content[6]}<"
      assert "-4200000000".eql?(content[7]), "expected: >-4200000000< was: >#{content[7]}<"
      assert "-0.0200".eql?(content[8]), "expected: >-0.020< was: >#{content[8]}<"

      assert "7".eql?(content[10]), "expected: >7< was: >#{content[10]}<"
      assert "8.9".eql?(content[11]), "expected: >8.9< was: >#{content[11]}<"
      assert "4200000000".eql?(content[12]), "expected: >4200000000< was: >#{content[12]}<"
      assert "0.02".eql?(content[13]), "expected: >0.02< was: >#{content[13]}<"
      assert "-7".eql?(content[14]), "expected: >-7< was: >#{content[14]}<"
      assert "-8.9".eql?(content[15]), "expected: >-8.9< was: >#{content[15]}<"
      assert "-4200000000".eql?(content[16]), "expected: >-4200000000< was: >#{content[16]}<"
      assert "-0.02".eql?(content[17]), "expected: >-0.02< was: >#{content[17]}<"

      assert "12".eql?(content[19]), "expected: >12< was: >#{content[19]}<"
      assert "2".eql?(content[20]), "expected: >2< was: >#{content[20]}<"
      assert "35".eql?(content[21]), "expected: >35< was: >#{content[21]}<"
      assert "2".eql?(content[22]), "expected: >2< was: >#{content[22]}<"
      assert "2".eql?(content[23]), "expected: >2< was: >#{content[23]}<"
      assert "1".eql?(content[24]), "expected: >1< was: >#{content[24]}<"
      assert "7".eql?(content[25]), "expected: >7< was: >#{content[25]}<"
      assert "7".eql?(content[26]), "expected: >7< was: >#{content[26]}<"
      assert "7".eql?(content[27]), "expected: >7< was: >#{content[27]}<"
   #   assert "7".eql?(content[28]), "expected: >7< was: >#{content[28]}<"
   #   assert "7".eql?(content[29]), "expected: >7< was: >#{content[29]}<"
   #   assert "7".eql?(content[30]), "expected: >7< was: >#{content[30]}<"
   #   assert "7".eql?(content[31]), "expected: >7< was: >#{content[31]}<"
      assert "7".eql?(content[32]), "expected: >7< was: >#{content[32]}<"

      assert "13.9".eql?(content[34]), "expected: >13,9< was: >#{content[34]}<"
      assert "3.9".eql?(content[35]), "expected: >3.9< was: >#{content[35]}<"
      assert "44.5".eql?(content[36]), "expected: >44.5< was: >#{content[36]}<"
      assert "2.966666666666667".eql?(content[37]), "expected: >2.966666666666667< was: >#{content[37]}<"
      assert "3.9".eql?(content[38]), "expected: >3.9< was: >#{content[38]}<"
      assert "2.9".eql?(content[39]), "expected: >2.9< was: >#{content[39]}<"
      assert "9".eql?(content[40]), "expected: >9< was: >#{content[40]}<"
      assert "9".eql?(content[41]), "expected: >9< was: >#{content[41]}<"
      assert "8".eql?(content[42]), "expected: >8< was: >#{content[42]}<"
   #   assert "8.9".eql?(content[43]), "expected: >8.9< was: >#{content[43]}<"
   #   assert "8.9".eql?(content[44]), "expected: >8.9< was: >#{content[44]}<"
   #   assert "8.9".eql?(content[45]), "expected: >8.9< was: >#{content[45]}<"
   #   assert "8.9".eql?(content[46]), "expected: >8.9< was: >#{content[46]}<"
      assert "8.9".eql?(content[47]), "expected: >8.9< was: >#{content[47]}<"

      assert "4200000005".eql?(content[49]), "expected: >4200000005< was: >#{content[49]}<"
      assert "4199999995".eql?(content[50]), "expected: >4199999995< was: >#{content[50]}<"
      assert "21000000000".eql?(content[51]), "expected: >21000000000< was: >#{content[51]}<"
      assert "1400000000".eql?(content[52]), "expected: >1400000000< was: >#{content[52]}<"
      assert "0".eql?(content[53]), "expected: >0< was: >#{content[53]}<"
      assert "0".eql?(content[54]), "expected: >0< was: >#{content[54]}<"
      assert "4200000000".eql?(content[55]), "expected: >4200000000< was: >#{content[55]}<"
      assert "4200000000".eql?(content[56]), "expected: >4200000000< was: >#{content[56]}<"
      assert "4200000000".eql?(content[57]), "expected: >4200000000< was: >#{content[57]}<"
   #   assert "4200000000".eql?(content[58]), "expected: >4200000000< was: >#{content[58]}<"
   #   assert "4200000000".eql?(content[59]), "expected: >4200000000< was: >#{content[59]}<"
   #   assert "4200000000".eql?(content[60]), "expected: >4200000000< was: >#{content[60]}<"
   #   assert "4200000000".eql?(content[61]), "expected: >4200000000< was: >#{content[61]}<"
      assert "4200000000".eql?(content[62]), "expected: >4200000000< was: >#{content[62]}<"

      assert "5.02".eql?(content[64]), "expected: >5.02< was: >#{content[64]}<"
      assert "-4.98".eql?(content[65]), "expected: >-4.98< was: >#{content[65]}<"
      assert "0.1".eql?(content[66]), "expected: >0.1< was: >#{content[66]}<"
      assert "0.006666666666666667".eql?(content[67]), "expected: >0.006666666666666667< was: >#{content[67]}<"
      assert "0.02".eql?(content[68]), "expected: >0.02< was: >#{content[68]}<"
      assert "0.02".eql?(content[69]), "expected: >0.02< was: >#{content[69]}<"
      assert "0".eql?(content[70]), "expected: >0< was: >#{content[70]}<"
      assert "1".eql?(content[71]), "expected: >1< was: >#{content[71]}<"
      assert "0".eql?(content[72]), "expected: >0< was: >#{content[72]}<"
   #   assert "4200000000".eql?(content[73]), "expected: >12< was: >#{content[73]}<"
   #   assert "4200000000".eql?(content[74]), "expected: >12< was: >#{content[74]}<"
   #   assert "4200000000".eql?(content[75]), "expected: >12< was: >#{content[75]}<"
   #   assert "4200000000".eql?(content[76]), "expected: >12< was: >#{content[76]}<"
      assert "0.02".eql?(content[77]), "expected: >0.02< was: >#{content[77]}<"

      assert "-2".eql?(content[79]), "expected: >-12< was: >#{content[79]}<"
      assert "-12".eql?(content[80]), "expected: >-2< was: >#{content[80]}<"
      assert "-35".eql?(content[81]), "expected: >-35< was: >#{content[81]}<"
      assert "-3".eql?(content[82]), "expected: >-3< was: >#{content[82]}<"
      assert "3".eql?(content[83]), "expected: >3< was: >#{content[83]}<"
      assert "2".eql?(content[84]), "expected: >2< was: >#{content[84]}<"
      assert "-7".eql?(content[85]), "expected: >-7< was: >#{content[85]}<"
      assert "-7".eql?(content[86]), "expected: >-7< was: >#{content[86]}<"
      assert "-7".eql?(content[87]), "expected: >-7< was: >#{content[87]}<"
   #   assert "-7".eql?(content[88]), "expected: >-7< was: >#{content[88]}<"
   #   assert "-7".eql?(content[89]), "expected: >-7< was: >#{content[89]}<"
   #   assert "-7".eql?(content[90]), "expected: >-7< was: >#{content[90]}<"
   #   assert "-7".eql?(content[91]), "expected: >-7< was: >#{content[91]}<"
      assert "7".eql?(content[92]), "expected: >-7< was: >#{content[92]}<"

      assert "-3.9".eql?(content[94]), "expected: >-3.9< was: >#{content[94]}<"
      assert "-13.9".eql?(content[95]), "expected: >-13.9< was: >#{content[95]}<"
      assert "-44.5".eql?(content[96]), "expected: >-44.5< was: >#{content[96]}<"
      assert "-2.966666666666667".eql?(content[97]), "expected: >-2.966666666666667< was: >#{content[97]}<"
      assert "1.1".eql?(content[98]), "expected: >-3.9< was: >#{content[98]}<"
      assert "0.1".eql?(content[99]), "expected: >-2.9< was: >#{content[99]}<"
      assert "-9".eql?(content[100]), "expected: >-9< was: >#{content[100]}<"
      assert "-8".eql?(content[101]), "expected: >-9< was: >#{content[101]}<"
      assert "-9".eql?(content[102]), "expected: >-8< was: >#{content[102]}<"
   #   assert "-8.9".eql?(content[103]), "expected: >-8.9< was: >#{content[103]}<"
   #   assert "-8.9".eql?(content[104]), "expected: >-8.9< was: >#{content[104]}<"
   #   assert "-8.9".eql?(content[105]), "expected: >-8.9< was: >#{content[105]}<"
   #   assert "-8.9".eql?(content[106]), "expected: >-8.9< was: >#{content[106]}<"
      assert "8.9".eql?(content[107]), "expected: >-8.9< was: >#{content[107]}<"

      assert "-4199999995".eql?(content[109]), "expected: >-4200000005< was: >#{content[109]}<"
      assert "-4200000005".eql?(content[110]), "expected: >-4199999995< was: >#{content[110]}<"
      assert "-21000000000".eql?(content[111]), "expected: >-21000000000< was: >#{content[111]}<"
      assert "-1400000000".eql?(content[112]), "expected: >-1400000000< was: >#{content[112]}<"
      assert "0".eql?(content[113]), "expected: >-0< was: >#{content[113]}<"
      assert "0".eql?(content[114]), "expected: >-0< was: >#{content[114]}<"
      assert "-4200000000".eql?(content[115]), "expected: >-4200000000< was: >#{content[115]}<"
      assert "-4200000000".eql?(content[116]), "expected: >-4200000000< was: >#{content[116]}<"
      assert "-4200000000".eql?(content[117]), "expected: >-4200000000< was: >#{content[117]}<"
   #   assert "-4200000000".eql?(content[118]), "expected: >-4200000000< was: >#{content[118]}<"
   #   assert "-4200000000".eql?(content[119]), "expected: >-4200000000< was: >#{content[119]}<"
   #   assert "-4200000000".eql?(content[120]), "expected: >-4200000000< was: >#{content[120]}<"
   #   assert "-4200000000".eql?(content[121]), "expected: >-4200000000< was: >#{content[121]}<"
      assert "4200000000".eql?(content[122]), "expected: >-4200000000< was: >#{content[122]}<"

      assert "4.98".eql?(content[124]), "expected: >-5.02< was: >#{content[124]}<"
      assert "-5.02".eql?(content[125]), "expected: >-4.98< was: >#{content[125]}<"
      assert "-0.1".eql?(content[126]), "expected: >-0.1< was: >#{content[126]}<"
      assert "-0.006666666666666667".eql?(content[127]), "expected: >-0.006666666666666667< was: >#{content[127]}<"
      assert "4.98".eql?(content[128]), "expected: >-0.02< was: >#{content[128]}<"
      assert "2.98".eql?(content[129]), "expected: >-0.02< was: >#{content[129]}<"
      assert "0".eql?(content[130]), "expected: >-0< was: >#{content[130]}<"
      assert "0".eql?(content[131]), "expected: >-1< was: >#{content[131]}<"
      assert "-1".eql?(content[132]), "expected: >-0< was: >#{content[132]}<"
   #   assert "-4200000000".eql?(content[133]), "expected: >12< was: >#{content[133]}<"
   #   assert "-4200000000".eql?(content[134]), "expected: >12< was: >#{content[134]}<"
   #   assert "-4200000000".eql?(content[135]), "expected: >12< was: >#{content[135]}<"
   #   assert "-4200000000".eql?(content[136]), "expected: >12< was: >#{content[136]}<"
      assert "0.02".eql?(content[137]), "expected: >0.02< was: >#{content[137]}<"
    end
  end

  context "cases/types" do
    setup do
      @source = File.join(File.dirname(__FILE__), "cases/types")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      class Replace
        @@class_uri = "http://example.org/instance/replace"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.gsub(".", "--")
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end

      class Revert
        @@class_uri = "http://example.org/instance/revert"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.reverse
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end

      class Uppercase
        @@class_uri = "http://example.org/instance/uppercase"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.upcase
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end
      Jekyll::JekyllRdf::Helper::Types::register Replace
      Jekyll::JekyllRdf::Helper::Types::register Revert
      Jekyll::JekyllRdf::Helper::Types::register Uppercase
      site.process
    end

    should "evalueate different types" do
      content = []
      file = File.read("#{@source}/_site/types.html")
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "28--07--2018", content[1]
      assert_equal "reverted", content[3]
      assert_equal "THIS WAS ALL LOWER CASE", content[5]
    end
  end
end
