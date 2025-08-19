require 'trmnl/liquid'

describe TRMNL::Liquid::TemplateTag do
  let(:service) { ::Liquid::Template }
  let(:environment) { TRMNL::Liquid.build_environment }
  let(:vars) { {} }

  context 'with an invalid template name' do
    let(:content) { '{% template omg!!! %}Hello, world!{% endtemplate %}' }

    it 'renders an error message' do
      expect_render('Liquid error: invalid template name "omg!!!" - template names must contain only letters, numbers, underscores, and slashes')
    end
  end

  context 'with a valid template' do
    let(:content) { 'abc {% template my_template %}Hello, {{ name }}{% endtemplate %} 123' }

    it 'strips out template contents' do
      expect_render('abc  123')
    end
  end

  context 'calling an undefined template' do
    let(:content) { '{% render "oh_no" %}' }

    it 'renders an error message' do
      expect_render('Liquid error: Template not found: oh_no')
    end
  end

  context 'calling a defined template' do
    let(:vars) { { 'name' => 'George' } }
    let(:content) do
      <<~LIQUID
        {% template my_template %}Hello, {{ name }}{% endtemplate %}
        {% render 'my_template', name: 'world' %}
        {% render 'my_template', name: name %}
      LIQUID
    end

    it 'renders the template' do
      expect_render("Hello, world\nHello, George")
    end
  end

  def expect_render(output)
    expect(service.parse(content, environment: environment).render(vars).strip).to eq(output.strip)
  end
end
