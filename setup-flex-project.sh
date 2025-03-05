#!/bin/bash

# Create the main project directory
mkdir -p flex
cd flex

# Create the documentation directory
mkdir -p docs/architecture docs/api docs/database

# Create the backend services directories
mkdir -p services/model-service/{src,tests,config}
mkdir -p services/calculation-engine/{src,tests,config}
mkdir -p services/user-management/{src,tests,config}
mkdir -p services/integration-service/{src,tests,config}
mkdir -p services/collaboration-service/{src,tests,config}
mkdir -p services/analytics-service/{src,tests,config}
mkdir -p services/export-service/{src,tests,config}

# Create the frontend directory
mkdir -p frontend/{src,public,tests}
mkdir -p frontend/src/{components,pages,services,utils,hooks,contexts,assets}
mkdir -p frontend/src/components/{common,model-builder,dashboard,settings}

# Create the infrastructure directory
mkdir -p infrastructure/{terraform,kubernetes,docker}
mkdir -p infrastructure/docker/dev infrastructure/docker/prod

# Create the common libraries directory
mkdir -p libraries/financial-dsl/{src,tests}
mkdir -p libraries/ui-components/{src,tests}
mkdir -p libraries/data-models/{src,tests}

# Create CI/CD directories
mkdir -p .github/workflows

# Create configuration files
touch .gitignore
touch README.md
touch docker-compose.yml
touch .env.example

# Create backend service base files
for service in model-service calculation-engine user-management integration-service collaboration-service analytics-service export-service; do
  # Create package.json files
  echo '{
  "name": "'$service'",
  "version": "0.1.0",
  "description": "'$service' for FinanceForge platform",
  "main": "src/index.ts",
  "scripts": {
    "start": "ts-node src/index.ts",
    "dev": "nodemon --exec ts-node src/index.ts",
    "build": "tsc",
    "test": "jest"
  }
}' > services/$service/package.json

  # Create basic TypeScript config
  echo '{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}' > services/$service/tsconfig.json

  # Create basic index.ts file
  echo 'import express from "express";
import { ApolloServer } from "apollo-server-express";
import { typeDefs } from "./schema";
import { resolvers } from "./resolvers";

const app = express();
const PORT = process.env.PORT || 4000;

async function startServer() {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
  });

  await server.start();
  server.applyMiddleware({ app });

  app.listen(PORT, () => {
    console.log(`'$service' running at http://localhost:${PORT}${server.graphqlPath}`);
  });
}

startServer();
' > services/$service/src/index.ts

  # Create placeholder schema file
  echo 'import { gql } from "apollo-server-express";

export const typeDefs = gql`
  type Query {
    healthCheck: String
  }
`;
' > services/$service/src/schema.ts

  # Create placeholder resolvers file
  echo 'export const resolvers = {
  Query: {
    healthCheck: () => "Service is healthy"
  }
};
' > services/$service/src/resolvers.ts
done

# Create frontend base files
echo '{
  "name": "financeforge-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.10.0",
    "apollo-client": "^2.6.10",
    "graphql": "^16.6.0",
    "@apollo/client": "^3.7.10",
    "recharts": "^2.5.0",
    "react-flow-renderer": "^10.3.17",
    "d3": "^7.8.2",
    "formik": "^2.2.9",
    "yup": "^1.0.2"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  }
}' > frontend/package.json

# Create React app entry point
echo 'import React from "react";
import ReactDOM from "react-dom/client";
import { ApolloClient, InMemoryCache, ApolloProvider } from "@apollo/client";
import App from "./App";

const client = new ApolloClient({
  uri: "http://localhost:4000/graphql",
  cache: new InMemoryCache()
});

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>
);
' > frontend/src/index.tsx

# Create App component
echo 'import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import ModelBuilder from "./pages/ModelBuilder";
import Settings from "./pages/Settings";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/model-builder" element={<ModelBuilder />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Router>
  );
}

export default App;
' > frontend/src/App.tsx

# Create placeholder page components
mkdir -p frontend/src/pages
echo 'import React from "react";

function Dashboard() {
  return (
    <div>
      <h1>FinanceForge Dashboard</h1>
    </div>
  );
}

export default Dashboard;
' > frontend/src/pages/Dashboard.tsx

echo 'import React from "react";

function ModelBuilder() {
  return (
    <div>
      <h1>Financial Model Builder</h1>
    </div>
  );
}

export default ModelBuilder;
' > frontend/src/pages/ModelBuilder.tsx

echo 'import React from "react";

function Settings() {
  return (
    <div>
      <h1>Settings</h1>
    </div>
  );
}

export default Settings;
' > frontend/src/pages/Settings.tsx

# Create Docker Compose file
echo 'version: "3.8"

services:
  # Backend services
  model-service:
    build:
      context: ./services/model-service
      dockerfile: ../../infrastructure/docker/dev/Dockerfile.node
    volumes:
      - ./services/model-service:/app
    ports:
      - "4001:4000"
    depends_on:
      - postgres
      - redis
    environment:
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/financeforge
      - REDIS_URL=redis://redis:6379
      - NODE_ENV=development

  calculation-engine:
    build:
      context: ./services/calculation-engine
      dockerfile: ../../infrastructure/docker/dev/Dockerfile.node
    volumes:
      - ./services/calculation-engine:/app
    ports:
      - "4002:4000"
    depends_on:
      - postgres
      - clickhouse
    environment:
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/financeforge
      - CLICKHOUSE_URL=clickhouse://clickhouse:9000/default
      - NODE_ENV=development

  user-management:
    build:
      context: ./services/user-management
      dockerfile: ../../infrastructure/docker/dev/Dockerfile.node
    volumes:
      - ./services/user-management:/app
    ports:
      - "4003:4000"
    depends_on:
      - postgres
      - redis
    environment:
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/financeforge
      - REDIS_URL=redis://redis:6379
      - NODE_ENV=development

  # Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: ../infrastructure/docker/dev/Dockerfile.react
    volumes:
      - ./frontend:/app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development

  # Databases
  postgres:
    image: postgres:14
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_DB=financeforge
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=mongo
      - MONGO_INITDB_ROOT_PASSWORD=mongo
    volumes:
      - mongo-data:/data/db

  clickhouse:
    image: clickhouse/clickhouse-server
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - clickhouse-data:/var/lib/clickhouse

volumes:
  postgres-data:
  redis-data:
  mongo-data:
  clickhouse-data:
' > docker-compose.yml

# Create development Dockerfiles
mkdir -p infrastructure/docker/dev
echo 'FROM node:16

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "dev"]
' > infrastructure/docker/dev/Dockerfile.node

echo 'FROM node:16

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
' > infrastructure/docker/dev/Dockerfile.react

# Create .gitignore
echo 'node_modules/
dist/
build/
.env
*.log
.DS_Store
coverage/
.idea/
.vscode/
' > .gitignore

# Create README
echo '# FinanceForge (Flex) Platform

FinanceForge is a next-generation financial modeling platform that emphasizes intuitive from-scratch model building rather than relying on templates.

## Project Structure
- `/services` - Backend microservices
- `/frontend` - React-based frontend application
- `/libraries` - Shared libraries and utilities
- `/infrastructure` - Deployment and infrastructure configuration
- `/docs` - Project documentation

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Node.js (v16+)
- npm or yarn

### Development Setup
1. Clone the repository
2. Copy `.env.example` to `.env` and update with your local configuration
3. Run `docker-compose up` to start all services
4. Access the application at http://localhost:3000

## Architecture

FinanceForge uses a microservices architecture with the following components:
- Model Service
- Calculation Engine
- User Management Service
- Integration Service
- Collaboration Service
- Analytics Service
- Export Service

For more details, see the architecture documentation in the `/docs` directory.
' > README.md

echo '.env
.env.local
.env.development.local
.env.test.local
.env.production.local
node_modules/
dist/
build/
coverage/
.DS_Store
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.idea/
.vscode/
' > .gitignore

echo 'Project structure created successfully!'