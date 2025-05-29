FROM node:18-alpine
#workdir in container
WORKDIR /app
#copy package files.
COPY package*.json ./

RUN npm install 

#copy source code
COPY src/ ./src/

ENV PORT=9000

EXPOSE 9000

CMD ["node", "start"]

