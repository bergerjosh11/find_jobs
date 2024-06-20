require 'nokogiri'
require 'open-uri'
require 'date'
require 'mechanize'

def fetch_jobs_from_linkedin
  url = 'https://www.linkedin.com/jobs/ruby-on-rails-jobs'
  agent = Mechanize.new
  page = agent.get(url)
  jobs = []

  page.search('.job-result-card').each do |job|
    posted_date_text = job.at_css('.job-result-card__listdate').text.strip
    posted_date = parse_date(posted_date_text, 'linkedin')

    if posted_in_last_24_hours?(posted_date)
      job_title = job.at_css('.job-result-card__title').text.strip
      company = job.at_css('.job-result-card__subtitle').text.strip
      location = job.at_css('.job-result-card__location').text.strip
      job_url = job.at_css('.job-result-card__title a')['href']

      jobs << {
        title: job_title,
        company: company,
        location: location,
        url: job_url,
        posted_date: posted_date_text
      }
    end
  end

  jobs
end

def fetch_jobs_from_glassdoor
  url = 'https://www.glassdoor.com/Job/ruby-on-rails-jobs-SRCH_KO0,14.htm'
  doc = Nokogiri::HTML(URI.open(url))
  jobs = []

  doc.css('.jobContainer').each do |job|
    posted_date_text = job.at_css('.job-age').text.strip
    posted_date = parse_date(posted_date_text, 'glassdoor')

    if posted_in_last_24_hours?(posted_date)
      job_title = job.at_css('.jobLink').text.strip
      company = job.at_css('.companyName').text.strip
      location = job.at_css('.loc').text.strip
      job_url = "https://www.glassdoor.com" + job.at_css('.jobLink')['href']

      jobs << {
        title: job_title,
        company: company,
        location: location,
        url: job_url,
        posted_date: posted_date_text
      }
    end
  end

  jobs
end

def fetch_jobs_from_indeed
  url = 'https://www.indeed.com/jobs?q=ruby+on+rails&sort=date'
  doc = Nokogiri::HTML(URI.open(url))
  jobs = []

  doc.css('.jobsearch-SerpJobCard').each do |job|
    posted_date_text = job.at_css('.date').text.strip
    posted_date = parse_date(posted_date_text, 'indeed')

    if posted_in_last_24_hours?(posted_date)
      job_title = job.at_css('.title a').text.strip
      company = job.at_css('.company').text.strip
      location = job.at_css('.location').text.strip
      job_url = "https://www.indeed.com" + job.at_css('.title a')['href']

      jobs << {
        title: job_title,
        company: company,
        location: location,
        url: job_url,
        posted_date: posted_date_text
      }
    end
  end

  jobs
end

def parse_date(date_text, source)
  now = DateTime.now

  case source
  when 'linkedin'
    if date_text.include?('day')
      days_ago = date_text.match(/(\d+)/)[1].to_i
      now - days_ago
    elsif date_text.include?('hour')
      hours_ago = date_text.match(/(\d+)/)[1].to_i
      now - (hours_ago / 24.0)
    else
      now
    end
  when 'glassdoor'
    if date_text.include?('day')
      days_ago = date_text.match(/(\d+)/)[1].to_i
      now - days_ago
    elsif date_text.include?('hour')
      hours_ago = date_text.match(/(\d+)/)[1].to_i
      now - (hours_ago / 24.0)
    else
      now
    end
  when 'indeed'
    if date_text.include?('day')
      days_ago = date_text.match(/(\d+)/)[1].to_i
      now - days_ago
    elsif date_text.include?('hour')
      hours_ago = date_text.match(/(\d+)/)[1].to_i
      now - (hours_ago / 24.0)
    elsif date_text.include?('today')
      now
    else
      now
    end
  else
    now
  end
end

def posted_in_last_24_hours?(posted_date)
  now = DateTime.now
  time_difference = (now - posted_date) * 24
  time_difference <= 24
end

def main
  all_jobs = []
  all_jobs.concat(fetch_jobs_from_linkedin)
  all_jobs.concat(fetch_jobs_from_glassdoor)
  all_jobs.concat(fetch_jobs_from_indeed)

  all_jobs.each do |job|
    puts "Job Title: #{job[:title]}"
    puts "Company: #{job[:company]}"
    puts "Location: #{job[:location]}"
    puts "URL: #{job[:url]}"
    puts "Posted Date: #{job[:posted_date]}"
    puts "-" * 30
  end
end

main
