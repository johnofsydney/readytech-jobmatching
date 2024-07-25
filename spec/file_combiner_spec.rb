require 'csv'
require_relative '../file_combiner'
require 'rspec'

RSpec.describe FileCombiner do
  let(:job_file) { 'spec/fixtures/jobs.csv' }
  let(:jobseeker_file) { 'spec/fixtures/jobseekers.csv' }
  let(:output_file) { 'spec/fixtures/results.csv' }

  subject(:combiner) { described_class.new(job_file:, jobseeker_file:, output_file:) }

  after do
    File.delete(output_file) if File.exist?(output_file)
  end

  describe '.call' do
    before do
      allow(described_class).to receive(:new)
                            .and_return(combiner)

      allow(combiner).to receive(:call)
    end

    let(:combiner) { instance_double(FileCombiner) }

    it 'creates a new instance of the class and calls the #call method' do
      described_class.call

      expect(combiner).to have_received(:call)
    end
  end

  describe '#initialize' do
    it 'reads the jobseeker and job CSV files' do
      expect(CSV).to receive(:read).with(job_file, headers: true).and_call_original
      expect(CSV).to receive(:read).with(jobseeker_file, headers: true).and_call_original

      described_class.new(job_file:, jobseeker_file:, output_file:)
    end

    it 'assigns the instance variables' do
      expect(combiner.instance_variable_get(:@jobs)).to be_a(CSV::Table)
      expect(combiner.instance_variable_get(:@jobseekers)).to be_a(CSV::Table)
      expect(combiner.instance_variable_get(:@output_file)).to eq(output_file)
    end
  end

  describe '#call' do
    it 'correctly generates the results.csv file' do
      combiner.call

      expect(File.exist?(output_file)).to be true
    end

    it 'has the correct headers and number of rows' do
      combiner.call
      csv = CSV.read(output_file, headers: true)

      expect(csv.headers).to eq(["jobseeker_id", "jobseeker_name", "job_id", "job_title", "matching_skill_count", "matching_skill_percent"])
      expect(csv.count).to eq(5)
    end

    describe 'matching_skill_count and percentage columns' do
      it 'calculates the correct matching_skill_count', :aggregate_failures do
        combiner.call
        csv = CSV.read(output_file, headers: true)

        expect(csv[0]['matching_skill_count']).to eq('3') # Alice / Ruby Developer
        expect(csv[1]['matching_skill_count']).to eq('2') # Alice / Backend Developer
        expect(csv[2]['matching_skill_count']).to eq('3') # Bob / Frontend Developer
        expect(csv[3]['matching_skill_count']).to eq('2') # Charlie / Ruby Developer
        expect(csv[4]['matching_skill_count']).to eq('3') # Charlie / Backend Developer
      end

      it 'calculates the correct matching_skill_percent' do
        combiner.call
        csv = CSV.read(output_file, headers: true)

        expect(csv[0]['matching_skill_percent']).to eq('100') # Alice / Ruby Developer
        expect(csv[1]['matching_skill_percent']).to eq('50')  # Alice / Backend Developer
        expect(csv[2]['matching_skill_percent']).to eq('75')  # Bob / Frontend Developer
        expect(csv[3]['matching_skill_percent']).to eq('67')  # Charlie / Ruby Developer
        expect(csv[4]['matching_skill_percent']).to eq('75')  # Charlie / Backend Developer
      end
    end
  end
end