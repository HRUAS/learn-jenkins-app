FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm cache clean --force
RUN rm -rf node_modules package-lock.json
RUN npm install netlify-cli node-jq