#!/bin/bash
set -e

# This script runs AFTER schema.sql to fix password hashes

echo "Generating proper bcrypt hashes for seeded users..."

# Generate bcrypt hash for password "123456"
HASH=$(node -e "const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('123456', 10));")

echo "Updating user passwords with proper bcrypt hashes..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Update all seeded users with proper password hash
    UPDATE users SET password = '$HASH' 
    WHERE email IN (
        'admin@ecommerce.com',
        'john@example.com',
        'jane@example.com',
        'bob@example.com',
        'alice@example.com'
    );
    
    -- Verify users were created
    SELECT email, first_name, last_name, role FROM users ORDER BY id;
EOSQL

echo "✅ Password hashes updated successfully!"
