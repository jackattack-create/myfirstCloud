
FROM node

WORKDIR /app/dockerprac 
COPY dockerprac/package.json ./
RUN npm install
COPY . /dockerprac
EXPOSE 3000

CMD ["npm", "run", "start"]
