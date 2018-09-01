require 'test_helper'

class TestRdfTemplateMapper < Test::Unit::TestCase
  context "template mapper from RdfPageHelper" do
    setup do
      setup_jekyll "cases/pages"
    end

    should "create pages with the correct instance template" do
      file = File.read(File.join(@source, "_site/instance1.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("First Instance Template", content)

      file = File.read(File.join(@source, "_site/instance2.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Second Instance Template", content)
    end

    should "create pages with the correct class template" do
      file = File.read(File.join(@source, "_site/person.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("First Class Template", content)

      file = File.read(File.join(@source, "_site/classShow.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Second Class Template", content)
    end

    should "create pages with the default template if no template was found" do
      file = File.read(File.join(@source, "_site/resource.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Default", content)
    end
  end

  context "load_data form RdfPageHelper" do
    should "load data correctly into the file" do
      setup_jekyll "cases/showConfig"

      content = []
      file = File.read(File.join(@source, "_site/resource.html"))
      content = file[/\<div\s*class="instance"\>(.|\s)*\<\/div>/][22..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "http://example.org/instance/resource", content[0]
      assert content.include? "http://example.org/instance/resource#subResource1"
      assert content.include? "http://example.org/instance/resource#subResource2"
      assert content.include? "http://example.org/instance/resource#subResource3"
    end

    should "exit page generation if Jekyll did not load its mapped layout" do   #We can't recreate this case with MWE
      TestHelper::setErrOutput
      setup_jekyll "cases/pagesMissingTemplate"
      assert Jekyll.logger.messages.any?{|message| !!(message=~ /\s*Template .* was not loaded by Jekyll for .*\n\s*Skipping Page.\s*/)}, "missing error message: file not found: ****"
      TestHelper::resetErrOutput
    end
  end

  context "load_prefixes form RdfPageHelper" do
    should "should map prefixes from the file given through rdf_prefix_path in target templates frontmatter" do
      setup_jekyll "cases/prefixes"

      content = []
      file = File.read(File.join(@source, "_site/PrefixDemo.html"))
      content = file[/\<div\s*class="prefixes"\>(.|\s)*\<\/div\>/][22..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "eg: http://example.org/instance/_", content[0]
      assert_equal "rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#_", content[1]
      assert_equal "rdfs: http://www.w3.org/2000/01/rdf-schema#_", content[2]
      assert_equal "xsd: http://www.w3.org/2001/XMLSchema#_", content[3]
      assert_equal "foaf: http://xmlns.com/foaf/0.1/_", content[4]
    end

    should "raise an error if the given prefixfile is not accessible" do
      TestHelper::setErrOutput
      notFound = false
      begin
        setup_site_jekyll "cases/pagesFaultyPrefixAcess"
      rescue Errno::ENOENT => ex
        notFound = true
      end
      assert notFound, "Faulty.pref should not have been found since it doesn't exist."
      assert Jekyll.logger.messages.any?{|message| !!(message=~ /\s*file not found: .*\s*/)}, "missing error message: file not found: ****"
      TestHelper::resetErrOutput
    end
  end
end
