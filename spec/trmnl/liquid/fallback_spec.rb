require 'trmnl/liquid'

describe TRMNL::Liquid::Fallback do
  let(:fallback) { TRMNL::Liquid::Fallback }

  it 'supports number_with_delimiter' do
    # numbers
    expect(fallback.number_with_delimiter(1234, ',', '.')).to eq('1,234')
    expect(fallback.number_with_delimiter(1234.567, ',', '.')).to eq('1,234.567')
    expect(fallback.number_with_delimiter(1234.567, '.', ',')).to eq('1.234,567')
    expect(fallback.number_with_delimiter('1234.567', ',', '.')).to eq('1,234.567')

    # edge cases
    expect(fallback.number_with_delimiter(nil, ',', '.')).to eq('')
    expect(fallback.number_with_delimiter('asdf', ',', '.')).to eq('asdf')
  end
  
  it 'supports number_to_currency' do
    expect(fallback.number_to_currency(10420, '$', ',', '.', 2)).to eq('$10,420.00')
    expect(fallback.number_to_currency(10420, '$', ',', '.', 0)).to eq('$10,420')
    expect(fallback.number_to_currency(10420, '$', ',', '.', 4)).to eq('$10,420.0000')
    expect(fallback.number_to_currency(1234.57, '£', '.', ',', 2)).to eq('£1.234,57')
  end
  
  it 'supports ordinalize' do
    expect(fallback.ordinalize(0)).to eq('0th')
    expect(fallback.ordinalize(1)).to eq('1st')
    expect(fallback.ordinalize(2)).to eq('2nd')
    expect(fallback.ordinalize(3)).to eq('3rd')
    expect(fallback.ordinalize(4)).to eq('4th')
    expect(fallback.ordinalize(10)).to eq('10th')
    expect(fallback.ordinalize(11)).to eq('11th')
    expect(fallback.ordinalize(12)).to eq('12th')
    expect(fallback.ordinalize(13)).to eq('13th')
    expect(fallback.ordinalize(20)).to eq('20th')
    expect(fallback.ordinalize(21)).to eq('21st')
    expect(fallback.ordinalize(22)).to eq('22nd')
    expect(fallback.ordinalize(23)).to eq('23rd')
    expect(fallback.ordinalize(110)).to eq('110th')
    expect(fallback.ordinalize(111)).to eq('111th')
    expect(fallback.ordinalize(112)).to eq('112th')
    expect(fallback.ordinalize(113)).to eq('113th')
  end
  it 'supports pluralize' do
    expect(fallback.pluralize(0, 'cow', 'cows')).to eq('0 cows')
    expect(fallback.pluralize(1, 'cow', 'cows')).to eq('1 cow')
    expect(fallback.pluralize(2, 'cow', 'cows')).to eq('2 cows')
    expect(fallback.pluralize(2, 'cow', nil)).to eq('2 cows')
  end
end