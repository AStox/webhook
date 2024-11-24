# Use Node.js as the base image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all files to the container
COPY . .

# Compile TypeScript code to JavaScript
RUN npm run build

# Expose the app on port 3000
EXPOSE 3000

# Start the app
CMD ["node", "dist/index.js"]

