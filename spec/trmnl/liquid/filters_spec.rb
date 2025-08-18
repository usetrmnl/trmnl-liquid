require 'trmnl/liquid'

describe TRMNL::Liquid::Filters do
  before(:all) { TRMNL::Liquid.register_all }

  let(:service) { Liquid::Template }

  def expect_render(input, output, vars = {})
    expect(service.parse(input).render(vars)).to eq(output)
  end

  it 'supports append_random' do
    allow(SecureRandom).to receive(:hex).with(2).and_return('qW3r')
    expect_render('{% assign chart_id = "chart-" | append_random %}{{ chart_id }}', 'chart-qW3r')
  end

  it 'supports days_ago' do
    expect_render('{{ 3 | days_ago }}', (Date.today - 3).to_s)
    expect_render('{{ 5 | days_ago | date: "%b %d, %Y" }}', (Date.today - 5).strftime("%b %d, %Y"))
  end

  it 'supports find_by' do
    collection = [{ "name" => "Ryan", "age" => 35 }, { "name" => "Sara", "age" => 29 }, { "name" => "Jimbob", "age" => 29 }]
    expect_render("{{ collection | find_by: 'name', 'Ryan' }}", collection.find { |obj| obj['name'] == 'Ryan' }.to_s, { "collection" => collection })

    # with optional fallback parameter
    expect_render("{{ collection | find_by: 'name', 'ronak', 'Not Found' }}", 'Not Found', { "collection" => collection })
  end

  it 'supports group_by' do
    collection = [{ "name" => "Ryan", "age" => 35 }, { "name" => "Sara", "age" => 29 }, { "name" => "Jimbob", "age" => 29 }]
    expect_render("{{ collection | group_by: 'age' }}", collection.group_by { |obj| obj['age'] }.to_s, { "collection" => collection })
  end

  it 'supports markdown_to_html' do
    # TODO: Fix this test!! Check for HTML
    markdown = "This is *bongos*, indeed and [here's a {{ adjective }} link](https://somewhere.com)."
    html_output = "This is *bongos*, indeed and [here's a silly link](https://somewhere.com)."
    expect_render(markdown, html_output, { 'adjective' => 'silly' })

    # in case input is undefined, prevent error
    expect_render(nil, "")
  end

  it 'supports number_with_delimiter' do
    expect_render('{{ 1234 | number_with_delimiter }}', '1,234')
    expect_render("{{ 1234 | number_with_delimiter: '.' }}", '1.234')
    expect_render("{{ 1234.57 | number_with_delimiter: ' ', ',' }}", '1 234,57')
  end

  it 'supports number_to_currency' do
    expect_render('{{ 10420 | number_to_currency }}', '$10,420.00')
    expect_render("{{ 152350.69 | number_to_currency: '£' }}", '£152,350.69')
    expect_render("{{ 1234.57 | number_to_currency: '£', '.', ',' }}", '£1.234,57')
    expect_render("{{ 567 | number_to_currency: 'sv' }}", '567.00 kr')
    expect_render("{{ 123 | number_to_currency: 'tbd' }}", 'tbd123.00')
  end

  it 'supports l_word' do
    expect_render('{{ "today" | l_word: "es-ES" }}', 'hoy')
    expect_render('{{ "tomorrow" | l_word: "ko" }}', '내일')
  end

  it 'supports l_date' do
    expect_render("{{ '2025-01-11' | l_date: '%y %b' }}", '25 Jan')
    expect_render("{{ '2025-01-11' | l_date: '%y %b', 'ko' }}", '25 1월')
    expect_render("{{ '2025-01-11' | l_date: '%y %b', 'ko' }}", '25 1월')
  end

  it 'supports pluralize' do
    expect_render('{{ "book" | pluralize: 1 }}', '1 book')
    expect_render('{{ "book" | pluralize: 2 }}', '2 books')
    expect_render('{{ "octopus" | pluralize: 3 }}', '3 octopi')
    expect_render('{{ "person" | pluralize: 4 }}', '4 people')
  end

  it 'supports json' do
    expect_render('{{ data | json }}', '[{"a":1,"b":"c"},"d"]', 'data' => [{ 'a' => 1, 'b' => 'c' }, 'd'])
  end

  it 'supports sample' do
    expect(["1", "2", "3", "4", "5"].any? { |str| str == service.parse('{{ data | split: "," | sample }}').render({ "data" => "1,2,3,4,5" }) })
    expect(["cat", "dog"].any? { |str| str == service.parse('{{ data | split: "," | sample }}').render({ "data" => "cat,dog" }) })
  end

end