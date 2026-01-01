require 'trmnl/liquid'

describe TRMNL::Liquid::Filters do
  let(:service) { Liquid::Template }
  let(:environment) { TRMNL::Liquid.build_environment }

  def expect_render(input, output, vars = {})
    expect(service.parse(input, environment: environment).render(vars)).to eq(output)
  end

  it 'supports append_random' do
    allow(SecureRandom).to receive(:hex).with(2).and_return('qW3r')
    expect_render('{% assign chart_id = "chart-" | append_random %}{{ chart_id }}', 'chart-qW3r')
  end

  it 'supports days_ago' do
    expect_render('{{ 3 | days_ago }}', (Date.today - 3).to_s)
    expect_render('{{ 5 | days_ago | date: "%b %d, %Y" }}', (Date.today - 5).strftime('%b %d, %Y'))
  end

  it 'supports find_by' do
    collection = [{ 'name' => 'Ryan', 'age' => 35 }, { 'name' => 'Sara', 'age' => 29 },
                  { 'name' => 'Jimbob', 'age' => 29 }]
    expected = '{"name"=>"Ryan", "age"=>35}'
    expect_render("{{ collection | find_by: 'name', 'Ryan' }}", expected, { 'collection' => collection })

    # with optional fallback parameter
    expect_render("{{ collection | find_by: 'name', 'ronak', 'Not Found' }}", 'Not Found',
                  { 'collection' => collection })
  end

  it 'supports group_by' do
    collection = [{ 'name' => 'Ryan', 'age' => 35 }, { 'name' => 'Sara', 'age' => 29 },
                  { 'name' => 'Jimbob', 'age' => 29 }]
    expected = '{35=>[{"name"=>"Ryan", "age"=>35}], 29=>[{"name"=>"Sara", "age"=>29}, {"name"=>"Jimbob", "age"=>29}]}'
    expect_render("{{ collection | group_by: 'age' }}", expected, { 'collection' => collection })
  end

  it 'supports markdown_to_html' do
    # TODO: Fix this test!! Check for HTML
    markdown = "This is *bongos*, indeed and [here's a {{ adjective }} link](https://somewhere.com)."
    html_output = "This is *bongos*, indeed and [here's a silly link](https://somewhere.com)."
    expect_render(markdown, html_output, { 'adjective' => 'silly' })

    # in case input is undefined, prevent error
    expect_render(nil, '')
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

  it 'supports map_to_i' do
    expect_render('{% assign nums = "a, b, c, d, e" | split: ", " | map_to_i %}{{ nums }}', '00000')
    expect_render('{% assign nums = "5, 4, 3, 2, 1" | split: ", " | map_to_i %}{{ nums }}', '54321')
  end

  it 'supports pluralize' do
    expect_render('{{ "book" | pluralize: 0 }}', '0 books')
    expect_render('{{ "book" | pluralize: 1 }}', '1 book')
    expect_render('{{ "book" | pluralize: 2 }}', '2 books')
    expect_render('{{ "octopus" | pluralize: 3 }}', '3 octopi')
    expect_render('{{ "person" | pluralize: 4 }}', '4 people')
    expect_render('{{ "person" | pluralize: 4, plural: "humans" }}', '4 humans')
  end

  it 'supports json' do
    expect_render('{{ data | json }}', '[{"a":1,"b":"c"},"d"]', 'data' => [{ 'a' => 1, 'b' => 'c' }, 'd'])
  end

  it 'supports parse_json' do
    expect_render('{% assign parsed = data | parse_json %}{{ parsed.a }}', '1',
                  'data' => %q|{"a":1,"b":"c"}|)
  end

  it 'supports sample' do
    expect(%w[1 2 3 4 5].any? do |str|
      str == service.parse('{{ data | split: "," | sample }}').render({ 'data' => '1,2,3,4,5' })
    end)
    expect(%w[cat dog].any? do |str|
      str == service.parse('{{ data | split: "," | sample }}').render({ 'data' => 'cat,dog' })
    end)
  end

  it 'supports where_exp' do
    expect_render('{{ "just a string" | where_exp: "la", "le" }}', 'just a string')
    expect_render('{% assign nums = "1, 2, 3, 4, 5" | split: ", " | map_to_i %}{{ nums | where_exp: "n", "n >= 3" }}',
                  '345')
  end

  it 'supports ordinalize' do
    expect_render('{{ "2025-10-02" | ordinalize: "%A, %B <<ordinal_day>>, %Y" }}', 'Thursday, October 2nd, 2025')
    expect_render('{{ "2025-12-31 16:50:38 -0400" | ordinalize: "%A, %b <<ordinal_day>>" }}', 'Wednesday, Dec 31st')
  end

  it 'renders an SVG when data is provided' do
    svg = service.parse('{{ "Hello World" | qr_code }}', environment: environment).render

    expect(svg).to be_a(String)
    expect(svg).to start_with('<?xml')
    expect(svg).to include('class="qr-code"')
    expect(svg).to end_with('</svg>')

    invalid_level_svg = service.parse('{{ "Hello World" | qr_code: 11, "INVALID" }}', environment: environment).render
    expect(svg).to eql(invalid_level_svg)
  end

  describe 'relative_time' do
    it 'returns just now for recent timestamps' do
      now = DateTime.parse('2025-12-31 12:00:00')
      allow(DateTime).to receive(:now).and_return(now)
      
      expect_render('{{ "2025-12-31 11:59:30" | relative_time }}', 'just now')
    end
    
    it 'shows time ago for past dates' do
      now = DateTime.parse('2025-12-31 12:00:00')
      allow(DateTime).to receive(:now).and_return(now)
      
      expect_render('{{ "2025-12-31 11:00:00" | relative_time }}', '1 hour ago')
      expect_render('{{ "2025-12-31 10:00:00" | relative_time }}', '2 hours ago')
      expect_render('{{ "2025-12-30 12:00:00" | relative_time }}', '1 day ago')
      expect_render('{{ "2025-12-24 12:00:00" | relative_time }}', '1 week ago')
    end
    
    it 'returns relative time for future dates' do
      now = DateTime.parse('2025-12-31 12:00:00')
      allow(DateTime).to receive(:now).and_return(now)
      
      expect_render('{{ "2025-12-31 13:30:00" | relative_time }}', 'in 1 hour')
      expect_render('{{ "2026-01-01 12:00:00" | relative_time }}', 'in 1 day')
      expect_render('{{ "2026-01-07 12:00:00" | relative_time }}', 'in 1 week')
    end
    
    it 'works with custom base date time' do
      expect_render('{{ "2025-12-25 12:00:00" | relative_time: "2025-12-31 12:00:00" }}', '6 days ago')
    end
    
    it 'handles months and years' do
      now = DateTime.parse('2025-12-31 12:00:00')
      allow(DateTime).to receive(:now).and_return(now)
      
      expect_render('{{ "2024-12-31 12:00:00" | relative_time }}', '1 year ago')
      expect_render('{{ "2025-11-30 12:00:00" | relative_time }}', '1 month ago')
    end
    
    it 'supports i18n when translations are available' do
      skip 'I18n not available' unless defined?(::I18n)
      
      now = DateTime.parse('2025-12-31 12:00:00')
      allow(DateTime).to receive(:now).and_return(now)
      
      # Mock Spanish translations
      allow(I18n).to receive(:t).with('datetime.distance_in_words.ago', locale: 'es', default: 'ago').and_return('hace')
      allow(I18n).to receive(:t).with('datetime.distance_in_words.in', locale: 'es', default: 'in').and_return('en')
      allow(I18n).to receive(:t).with('datetime.distance_in_words.just_now', locale: 'es', default: 'just now').and_return('ahora mismo')
      
      expect_render('{{ "2025-12-30 12:00:00" | relative_time: nil, "es" }}', '1 day hace')
      expect_render('{{ "2026-01-01 12:00:00" | relative_time: nil, "es" }}', 'en 1 day')
      expect_render('{{ "2025-12-31 11:59:30" | relative_time: nil, "es" }}', 'ahora mismo')
    end
    
    it 'falls back to English when i18n is not available' do
      # Temporarily hide I18n constant if it exists
      if defined?(::I18n)
        i18n_backup = ::I18n
        Object.send(:remove_const, :I18n)
      end
      
      begin
        now = DateTime.parse('2025-12-31 12:00:00')
        allow(DateTime).to receive(:now).and_return(now)
        
        # Should use English fallbacks when I18n is not defined
        expect_render('{{ "2025-12-30 12:00:00" | relative_time: nil, "es" }}', '1 day ago')
        expect_render('{{ "2026-01-01 12:00:00" | relative_time: nil, "fr" }}', 'in 1 day')
        expect_render('{{ "2025-12-31 11:59:30" | relative_time: nil, "de" }}', 'just now')
      ensure
        # Restore I18n constant if it was removed
        if i18n_backup
          ::I18n = i18n_backup
        end
      end
    end
  end



end