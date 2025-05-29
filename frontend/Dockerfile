FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY ./src ./src/
COPY webpack.config.js ./

EXPOSE 8000

CMD ["npm", "start"]
