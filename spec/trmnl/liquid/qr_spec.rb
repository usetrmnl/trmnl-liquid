require 'trmnl/liquid'

describe TRMNL::Liquid::QR do
  let(:service) { Liquid::Template }
  let(:environment) { TRMNL::Liquid.build_environment }

  it 'renders an SVG when data is provided' do
    svg = service.parse('{{ "Hello World" | qr }}', environment: environment).render
    expect(svg).to be_a(String)
    expect(svg).to start_with('<?xml')
    expect(svg).to include('class="qr-code"')
    expect(svg).to end_with('</svg>')
  end
end
