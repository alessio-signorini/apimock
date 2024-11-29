#!/usr/bin/env ruby

require 'sinatra'
require 'yaml'

PROGRAM_NAME = "APImock"
VERSION = "1.0.0"
AUTHOR = "Alessio Signorini <alessio@signorini.us>"

if ARGV.empty?
  puts "#{PROGRAM_NAME} v#{VERSION} - #{AUTHOR}"
  puts "   Usage: ruby apimock.rb <responses_directory>"
  exit 1
end

RESPONSES_DIR = ARGV[0]
unless Dir.exist?(RESPONSES_DIR)
  puts "Error: Directory '#{RESPONSES_DIR}' does not exist"
  exit 1
end

# Enable CORS
before do
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
end

# Handle OPTIONS requests for CORS
options '*' do
  200
end

def find_response_file(request)
  content_type = request.content_type || 'application/json'
  # Sanitize content type for directory name
  content_dir = content_type.downcase.gsub('/', '-')
  
  # Get path and query parameters
  path = request.path_info
  params = request.params.transform_keys(&:downcase)
  
  # Build the path with sorted query parameters
  param_path = params.sort.map { |k, v| "#{k}/#{v.downcase}" }.join('/')
  param_path = "/#{param_path}" unless param_path.empty?
  
  # Construct the base path for both response and header files
  base_path = File.join(RESPONSES_DIR, content_dir, path.sub(/^\//, ''))
  base_path = "#{base_path}#{param_path}/#{request.request_method}"
  
  response_path = base_path
  header_path = "#{base_path}.header"
  
  [response_path, header_path]
end

def load_headers(header_file)
  return nil unless File.exist?(header_file)
  
  begin
    YAML.load_file(header_file)
  rescue => e
    puts "Error loading header file: #{e.message}"
    nil
  end
end

def handle_request(request)
  response_file, header_file = find_response_file(request)
  
  headers = {'Content-Type' => (request.content_type || 'application/json')}
  status = 200
  
  # Load headers if they exist
  if File.exist?(header_file)
    header_data = load_headers(header_file)
    if header_data
      headers.merge!(header_data['headers'] || {})
      status = header_data['status'] if header_data['status']
    end
  end
  
  # Return just headers if no response file but headers exist
  return [status, headers, ''] if (!File.exist?(response_file)) && File.exist?(header_file)
  
  # Return 404 if neither file exists
  return [404, headers, 'Not Found'] unless File.exist?(response_file)
  
  # Return response with headers
  [status, headers, File.read(response_file)]
end

# Catch-all route for all methods
%w(get post put delete patch).each do |method|
  send(method, '*') do
    status, headers, body = handle_request(request)
    headers.each { |k, v| response.headers[k] = v }
    status status
    body
  end
end
