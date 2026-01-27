# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::Liquid::Filters do
  subject :renderer do
    -> template, data { Liquid::Template.parse(template, environment:).render data }
  end

  let :environment do
    Liquid::Environment.build do |environment|
      environment.error_mode = :strict
      environment.register_filter described_class
    end
  end

  describe "#append_random" do
    it "appends random number" do
      allow(SecureRandom).to receive(:hex).with(2).and_return("qW3r")
      content = renderer.call %({% assign chart_id = "chart-" | append_random %}{{ chart_id }}), {}

      expect(content).to eq("chart-qW3r")
    end
  end

  describe "#days_ago" do
    it "renders default format" do
      content = renderer.call "{{ 3 | days_ago }}", {}
      expect(content).to eq((Date.today - 3).to_s)
    end

    it "renders custom format" do
      content = renderer.call %({{ 5 | days_ago | date: "%b %d, %Y" }}), {}
      expect(content).to eq((Date.today - 5).strftime("%b %d, %Y"))
    end
  end

  describe "#group_by" do
    it "supports group_by" do
      content = renderer.call %({{ collection | group_by: 'age' }}),
                              {
                                "collection" => [
                                  {
                                    "name" => "Ryan",
                                    "age" => 35
                                  },
                                  {
                                    "name" => "Sara",
                                    "age" => 29
                                  },
                                  {
                                    "name" => "Jimbob",
                                    "age" => 29
                                  }
                                ]
                              }

      expect(content).to eq(
        '{35=>[{"name"=>"Ryan", "age"=>35}], 29=>[{"name"=>"Sara", "age"=>29}, {"name"=>"Jimbob", "age"=>29}]}'
      )
    end
  end

  describe "#find_by" do
    let :collection do
      [
        {
          "name" => "Ryan",
          "age" => 35
        },
        {
          "name" => "Sara",
          "age" => 29
        },
        {
          "name" => "Jimbob",
          "age" => 29
        }
      ]
    end

    it "finds by name" do
      content = renderer.call "{{ collection | find_by: 'name', 'Ryan' }}",
                              {"collection" => collection}
      expect(content).to eq('{"name"=>"Ryan", "age"=>35}')
    end

    it "answers fallback when not found" do
      content = renderer.call "{{ collection | find_by: 'name', 'ronak', 'Not Found' }}",
                              {"collection" => collection}

      expect(content).to eq("Not Found")
    end
  end

  describe "#markdown_to_html" do
    it "answers HTML" do
      markdown = "This is a *test* and [here's a {{ adjective }} link](https://test.io)."
      content = renderer.call markdown, {"adjective" => "test"}

      expect(content).to eq("This is a *test* and [here's a test link](https://test.io).")
    end

    it "answers empty string when given no content" do
      content = renderer.call nil, {}
      expect(content).to eq("")
    end
  end

  describe "#number_with_delimiter" do
    it "answers comma delimiter" do
      content = renderer.call "{{ 1234 | number_with_delimiter }}", {}
      expect(content).to eq("1,234")
    end

    it "answers period delimiter" do
      content = renderer.call %({{ 1234 | number_with_delimiter: "." }}), {}
      expect(content).to eq("1.234")
    end

    it "answers space and comma" do
      content = renderer.call %({{ 1234.57 | number_with_delimiter: " ", "," }}), {}
      expect(content).to eq("1 234,57")
    end
  end

  describe "#number_to_currency" do
    it "answers USD" do
      content = renderer.call "{{ 10420 | number_to_currency }}", {}
      expect(content).to eq("$10,420.00")
    end

    it "answers pounds" do
      content = renderer.call %({{ 152350.69 | number_to_currency: "£" }}), {}
      expect(content).to eq("£152,350.69")
    end

    it "answers pounds with period and comma" do
      content = renderer.call %({{ 1234.57 | number_to_currency: "£", ".", "," }}), {}
      expect(content).to eq("£1.234,57")
    end

    it "answers Krones" do
      content = renderer.call %({{ 567 | number_to_currency: "sv" }}), {}
      expect(content).to eq("567.00 kr")
    end

    it "answers custom format" do
      content = renderer.call %({{ 123 | number_to_currency: "tbd" }}), {}
      expect(content).to eq("tbd123.00")
    end
  end

  describe "#l_word" do
    it "answers Spanish translation" do
      content = renderer.call %({{ "today" | l_word: "es-ES" }}), {}
      expect(content).to eq("hoy")
    end

    it "answers Korean translation" do
      content = renderer.call %({{ "tomorrow" | l_word: "ko" }}), {}
      expect(content).to eq("내일")
    end
  end

  describe "#l_date" do
    it "answers day and short month" do
      content = renderer.call %({{ "2025-01-11" | l_date: "%y %b" }}), {}
      expect(content).to eq("25 Jan")
    end

    it "answers day and short month with Korean translation" do
      content = renderer.call %({{ "2025-01-11" | l_date: "%y %b", "ko" }}), {}
      expect(content).to eq("25 1월")
    end
  end

  describe "#map_to_i" do
    it "answers characters as zeros" do
      content = renderer.call(
        %({% assign nums = "a, b, c, d, e" | split: ", " | map_to_i %}{{ nums }}),
        {}
      )

      expect(content).to eq("00000")
    end

    it "answers numbers as numbers" do
      content = renderer.call(
        %({% assign nums = "5, 4, 3, 2, 1" | split: ", " | map_to_i %}{{ nums }}),
        {}
      )

      expect(content).to eq("54321")
    end
  end

  describe "#pluralize" do
    it "answers plural when count is zero" do
      content = renderer.call %({{ "book" | pluralize: 0 }}), {}
      expect(content).to eq("0 books")
    end

    it "answers singular when count is one" do
      content = renderer.call %({{ "book" | pluralize: 1 }}), {}
      expect(content).to eq("1 book")
    end

    it "answers plural when count is more than one" do
      content = renderer.call %({{ "book" | pluralize: 2 }}), {}
      expect(content).to eq("2 books")
    end

    it "answers plural for complex word" do
      content = renderer.call %({{ "octopus" | pluralize: 3 }}), {}
      expect(content).to eq("3 octopi")
    end

    it "answers singular for complex word" do
      content = renderer.call %({{ "person" | pluralize: 4 }}), {}
      expect(content).to eq("4 people")
    end

    it "answers plural for alternate pluralization" do
      content = renderer.call %({{ "person" | pluralize: 4, plural: "humans" }}), {}
      expect(content).to eq("4 humans")
    end
  end

  describe "#json" do
    it "answers JSON" do
      content = renderer.call "{{ data | json }}", {"data" => [{"a" => 1, "b" => "c"}, "d"]}
      expect(content).to eq('[{"a":1,"b":"c"},"d"]')
    end
  end

  describe "#parse_json" do
    it "answers JSON" do
      content = renderer.call "{% assign value = data | parse_json %}{{ value.a }}",
                              {"data" => '{"a":1,"b":"c"}'}
      expect(content).to eq("1")
    end
  end

  describe "#sample" do
    it "asnwers random number" do
      content = renderer.call %({{ data | split: "," | sample }}), {"data" => "1,2,3,4,5"}
      expect(content).to match(/\A(1|2|3|4|5)\Z/)
    end

    it "asnwers random word" do
      content = renderer.call %({{ data | split: "," | sample }}), {"data" => "one,two,three"}
      expect(content).to match(/\A(one|two|three)\Z/)
    end
  end

  describe "#where_exp" do
    it "answers orignal template when expression isn't applicable" do
      content = renderer.call %({{ "test" | where_exp: "la", "le" }}), {}
      expect(content).to eq("test")
    end

    it "answers content which matches equation" do
      template = <<~BODY
        {% assign nums = "1,2,3,4,5" | split: "," | map_to_i %}
        {{ nums | where_exp: "n", "n >= 3" }}
      BODY

      content = renderer.call template, {}
      expect(content.strip).to eq("345")
    end
  end

  describe "#ordinalize" do
    it "asnwers day (long), month, day (short), and year" do
      content = renderer.call %({{ "2025-10-02" | ordinalize: "%A, %B <<ordinal_day>>, %Y" }}), {}
      expect(content).to eq("Thursday, October 2nd, 2025")
    end

    it "asnwers day (long), month, and data (short)" do
      content = renderer.call %({{ "2025-12-31 16:50:38 -0400" | ordinalize: "%A, %b <<ordinal_day>>" }}),
                              {}
      expect(content).to eq("Wednesday, Dec 31st")
    end
  end

  describe "#qr_code" do
    it "answers SVG with defaults" do
      content = renderer.call %({{ "Test" | qr_code }}), {}
      expect(content).to match(%r(\A<\?xml.+class="qr-code".+</svg>\Z))
    end

    it "answers SVG for size and level" do
      content = renderer.call %({{ "Test" | qr_code: 11, "INVALID" }}), {}
      expect(content).to match(%r(\A<\?xml.+class="qr-code".+</svg>\Z))
    end
  end
end
