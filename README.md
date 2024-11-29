# APImock

A lightweight Sinatra-based mock API server that serves static responses based on request path, method, and content-type. Very useful for prototyping APIs and frontend applications.

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Run the server:
```bash
ruby apimock.rb <responses_directory>
```

## Response Directory Structure

Responses are stored in the `responses` directory with the following structure:
```
responses/
  application-json/              # Content-type directory
    api/
      users/
        GET                     # Response body for GET /api/users in JSON
        GET.header              # Headers for GET /api/users
        POST                    # Response body for POST /api/users in JSON
        POST.header            # Headers for POST /api/users
        search/
          max/
            10/
              q/
                alessio/
                  GET          # Response for GET /api/users/search?max=10&q=alessio in JSON
                  GET.header
  application-xml/
    weather/
      forecast/
        93101/
          today/
            GET          # Response for GET /weather/forecast/93101/today in XML
            GET.header
          tomorrow/
            GET          # Response for GET /weather/forecast/93101/tomorrow in XML
            GET.header
```

## Header Files

Header files are optional YAML files that specify response headers and status codes:

```yaml
status: 201
headers:
  X-Custom-Header: some-value
  Cache-Control: no-cache
```

## Features

- Content-type based routing
- Support for all HTTP methods
- Query parameter handling (sorted and lowercased)
- Custom headers and status codes via YAML files
- CORS support
- Returns 404 for missing responses
