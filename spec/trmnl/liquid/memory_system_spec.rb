# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::Liquid::MemorySystem do
  subject(:system) { described_class.new }

  describe "#register" do
    it "registers name and body" do
      expect(system.register("test", "A body.")).to eq("A body.")
    end
  end

  describe "#read_template_file" do
    it "reads template" do
      system.register "test", "A body."
      expect(system.read_template_file("test")).to eq("A body.")
    end

    it "fails with file system error when template can't be found" do
      expectation = proc { system.read_template_file :bogus }

      expect(&expectation).to raise_error(
        Liquid::FileSystemError,
        "Liquid error: Template not found: bogus."
      )
    end
  end
end
