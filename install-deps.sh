#!/bin/bash

echo "Installing dependencies for all services..."

# Backend services
for service in model-service calculation-engine user-management collaboration-service integration-service analytics-service export-service; do
  echo "Installing dependencies for $service..."
  cd services/$service
  npm install
  cd ../..
done

# Frontend
echo "Installing dependencies for frontend..."
cd frontend
npm install
cd ..

echo "All dependencies installed!"
