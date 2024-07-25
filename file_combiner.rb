require 'csv'

class FileCombiner

  HEADERS = ["jobseeker_id", "jobseeker_name", "job_id", "job_title", "matching_skill_count", "matching_skill_percent"]

  def self.call(job_file: 'jobs.csv', jobseeker_file: 'jobseekers.csv', output_file: 'results.csv')
    new(job_file:, jobseeker_file:, output_file:).call
  end

  def initialize(job_file:, jobseeker_file:, output_file:)
    @jobs = CSV.read(job_file, headers: true)
    @jobseekers = CSV.read(jobseeker_file, headers: true)
    @output_file = output_file
  end

  def call
    CSV.open(output_file,'w', write_headers: true, headers: HEADERS) do |row|
      jobseekers.each do |jobseeker|
        jobs.each do |job|
          matching_skill_count = calculate_matching_skill_count(jobseeker, job)
          next if matching_skill_count.zero?

          row << [
            jobseeker['id'],
            jobseeker['name'],
            job['id'],
            job['title'],
            matching_skill_count,
            matching_skill_percent(matching_skill_count, job)
          ]
        end
      end
    end
  end

  private

  attr_reader :jobs, :jobseekers, :output_file

  def calculate_matching_skill_count(jobseeker, job)
    (jobseeker['skills'].split(', ') & job['required_skills'].split(', ')).count
  end

  def matching_skill_percent(matching_skill_count, job)
    ((matching_skill_count.to_f / job['required_skills'].split(', ').count) * 100).round
  end
end


FileCombiner.call

