require 'test_helper'

class TestJekyllRdf < Test::Unit::TestCase
  include RSpec::Matchers

  config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
  site = Jekyll::Site.new(config)
  site.process
  pagearray = site.pages.select{|p|
    p.name == "INF3580/simpsons/#/Homer/index.html".gsub(TestHelper::BASE_URL, '')
  } # creates an array
  homer_page = pagearray[0] # select first entry of selection

  context "Generating a site with RDF data" do
    should "create a file which mentions 'Lisa Simpson'" do
      s = File.read("#{TestHelper::DEST_DIR}/INF3580/simpsons/#/Lisa/index.html") # read static file
      expect(s).to include 'Lisa Simpson'
    end
  end

  context "Generate a page from RDF data" do
    should "have rdf data" do
      assert_not_nil(homer_page.data['rdf'])
    end
    should "contain correct age of Homer Simpson" do
      plain_statements =  homer_page.data['rdf'].statements.map{|statement| [statement.subject.to_s, statement.predicate.to_s, statement.object.to_s]}
      assert plain_statements.include?(['Homer Simpson','http://xmlns.com/foaf/0.1/age','36'])
    end
  end

end
#test
