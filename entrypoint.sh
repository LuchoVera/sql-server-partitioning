#!/bin/bash

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
sleep 30s

# Check if sqlcmd is available
which sqlcmd
if [ $? -ne 0 ]; then
    echo "Error: sqlcmd is not available in the PATH"
    echo "Current PATH: $PATH"
    exit 1
fi

# Execute the initialization script
echo "Executing SQL scripts..."
sqlcmd -S localhost -U sa -P $SA_PASSWORD -i /scripts/init.sql

# Keep the container running
tail -f /dev/null
