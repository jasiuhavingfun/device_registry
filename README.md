# Device Registry

A Ruby on Rails API application for tracking devices assigned to users within an organization. The application provides endpoints for assigning and returning devices while enforcing business rules around device ownership and assignment history.


## Features

- **Device Assignment**: Users can assign devices to themselves
- **Device Return**: Users can return devices they own
- **Assignment History**: Track complete assignment history with timestamps
- **Authorization**: Secure API with token-based authentication
- **Business Rule Enforcement**: Prevent unauthorized assignments and returns

## Business Rules

1. **Self-Assignment Only**: Users can only assign devices to themselves
2. **No Double Assignment**: Devices cannot be assigned if already assigned to another user
3. **Owner-Only Returns**: Only the user who assigned a device can return it
4. **One-Time Usage**: Users cannot re-assign devices they previously returned

## Requirements

- **Ruby**: 3.2.3
- **Rails**: 7.1.3+
- **Database**: SQLite3 (development)
- **Bundler**: Latest version

## Installation

### 1. Clone the Repository

```
git clone https://github.com/jasiuhavingfun/device_registry
cd device_registry
```

### 2. Install Dependencies

```
# Install Ruby dependencies
bundle install
```

### 3. Database Setup

```
# Create and migrate the database
bin/rails db:prepare

# Or run individually:
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Optional: load sample data
```

## Configuration

### Database Configuration

The application uses SQLite3 for development and testing. Configuration is in `config/database.yml`:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3

test:
  adapter: sqlite3
  database: storage/test.sqlite3
```

### Authentication

The application uses API key-based authentication:
- API keys are stored in the `api_keys` table
- Keys are associated with users through a polymorphic `bearer` relationship
- Include the token in the session: `session: { token: 'your-api-token' }`

## Running the Application

### Development Server

```
# Start the Rails server
bin/rails server

# Or use the setup script
bin/setup
```

The application will be available at `http://localhost:3000`

## Testing

### Running Tests

```
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/services/assign_device_to_user_spec.rb
bundle exec rspec spec/controllers/devices_controller_spec.rb

# Run with verbose output
bundle exec rspec --format documentation
```

## License

This project is for educational/interview purposes.
