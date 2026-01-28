# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::Liquid do
  describe ".build_environment" do
    it "builds with defaults" do
      expect(described_class.build_environment).to have_attributes(
        file_system: be_a(TRMNL::Liquid::FileSystem),
        error_mode: :lax,
        tags: hash_including("template" => TRMNL::Liquid::TemplateTag)
      )
    end

    it "applies custom error mode" do
      environment = described_class.build_environment error_mode: :strict
      expect(environment.error_mode).to eq(:strict)
    end

    it "applies custom file system" do
      file_system = Class.new
      environment = described_class.build_environment(file_system:)

      expect(environment.file_system).to eq(file_system)
    end

    it "yields to block" do
      capture = described_class.build_environment { capture = it }
      expect(capture).to be_a(Liquid::Environment)
    end
  end
end
