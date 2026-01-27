# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::Liquid::Fallback do
  let(:fallback) { described_class }

  describe "#number_with_delimiter" do
    it "answers thousands" do
      expect(fallback.number_with_delimiter(1234, ",", ".")).to eq("1,234")
    end

    it "answers millions" do
      expect(fallback.number_with_delimiter(1234.567, ",", ".")).to eq("1,234.567")
    end

    it "answers millions with dot and comma notation" do
      expect(fallback.number_with_delimiter(1234.567, ".", ",")).to eq("1.234,567")
    end

    it "answers string as number" do
      expect(fallback.number_with_delimiter("1234.567", ",", ".")).to eq("1,234.567")
    end

    it "answers nil as empty string" do
      expect(fallback.number_with_delimiter(nil, ",", ".")).to eq("")
    end

    it "answers identical string when not a number" do
      expect(fallback.number_with_delimiter("asdf", ",", ".")).to eq("asdf")
    end
  end

  describe "#number_to_currency" do
    it "answers USD with two digit cents" do
      expect(fallback.number_to_currency(10420, "$", ",", ".", 2)).to eq("$10,420.00")
    end

    it "answers USD without cents" do
      expect(fallback.number_to_currency(10420, "$", ",", ".", 0)).to eq("$10,420")
    end

    it "answers USD with four digit cents" do
      expect(fallback.number_to_currency(10420, "$", ",", ".", 4)).to eq("$10,420.0000")
    end

    it "answers pounds with two digit cents" do
      expect(fallback.number_to_currency(1234.57, "£", ".", ",", 2)).to eq("£1.234,57")
    end
  end

  describe "#ordinalize" do
    it "answers zeroth" do
      expect(fallback.ordinalize(0)).to eq("0th")
    end

    it "answers first" do
      expect(fallback.ordinalize(1)).to eq("1st")
    end

    it "answers tenth" do
      expect(fallback.ordinalize(10)).to eq("10th")
    end

    it "answers one hundredth" do
      expect(fallback.ordinalize(100)).to eq("100th")
    end
  end

  describe "#pluralize" do
    it "answers zero as plural" do
      expect(fallback.pluralize(0, "cow", "cows")).to eq("0 cows")
    end

    it "answers one as singular" do
      expect(fallback.pluralize(1, "cow", "cows")).to eq("1 cow")
    end

    it "answers multiple (with no replacement) as plural" do
      expect(fallback.pluralize(2, "cow", nil)).to eq("2 cows")
    end
  end
end
