# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::Liquid::TemplateTag do
  subject :renderer do
    -> template, data { Liquid::Template.parse(template, environment:).render data }
  end

  let(:environment) { TRMNL::Liquid.new }

  describe "#render" do
    it "answers content for registered template" do
      template = <<~LIQUID
        {% template my_template %}Hello, {{ name }}{% endtemplate %}
        {% render 'my_template', name: 'world' %}
        {% render 'my_template', name: name %}
      LIQUID

      content = renderer.call template, {"name" => "George"}

      expect(content.strip).to eq("Hello, world\nHello, George")
    end

    it "answers content with template contents stripped" do
      template = "abc {% template my_template %}Hello, {{ name }}{% endtemplate %} 123"
      content = renderer.call template, {}

      expect(content).to eq("abc  123")
    end

    ["{%endtemplate%}", "{%  endtemplate  %}", "{%\nendtemplate\n%}", "{%- endtemplate -%}"]
      .each do |end_tag|
        it "answers content when end tag is #{end_tag.inspect}" do
          template = "{% template my_template %}Hello#{end_tag}{% render 'my_template' %}!"
          content = renderer.call template, {}

          expect(content).to eq("Hello!")
        end
      end

    it "answers content with whitespace after end tag trimmed" do
      template = "{% template my_template %}Hi{% endtemplate -%}\n  {% render 'my_template' %}"
      content = renderer.call template, {}

      expect(content).to eq("Hi")
    end

    it "fails when end tag is missing" do
      expectation = proc { renderer.call "{% template my_template %}Hello", {} }
      expect(&expectation).to raise_error(Liquid::SyntaxError, /'template' tag was never closed/)
    end

    it "answers error with invalid template name" do
      content = renderer.call "{% template Danger! %}Hello, world!{% endtemplate %}", {}

      expect(content).to eq(
        %(Liquid error: invalid template name "Danger!" - template names must contain only ) +
        %(letters, numbers, underscores, and slashes)
      )
    end

    it "answers error for undefined template" do
      content = renderer.call %({% render "bogus" %}), {}
      expect(content).to eq("Liquid error: Template not found: bogus.")
    end
  end
end
