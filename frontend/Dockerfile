FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .
COPY webpack.config.js ./

EXPOSE 8000

CMD ["npm", "start"]
