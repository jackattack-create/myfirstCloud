FROM node

# Set up the Jenkins agent working directory
ARG AGENT_WORK_DIR=../agent
ENV HOME ${AGENT_WORK_DIR}

# Install Jenkins agent dependencies
ARG VERSION=4.10
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl git openjdk-11-jdk && \
    curl https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar --create-dirs -sLo /opt/remoting.jar && \
    chmod 755 /opt/remoting.jar && \
    ln -sf /opt/remoting.jar /opt/remoting && \
    mkdir -p ${AGENT_WORK_DIR}

# Set up the Jenkins user and working directory
RUN useradd -c "Jenkins agent" -d $HOME -m jenkins && \
    chown -R jenkins:jenkins ${AGENT_WORK_DIR} && \
    chmod 775 ${AGENT_WORK_DIR}
USER jenkins
WORKDIR ${AGENT_WORK_DIR}

# Switch back to root user to install Docker
USER root

# Install Docker for Jenkins agent
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

WORKDIR /app/dockerprac 
COPY dockerprac/package.json ./
RUN npm install
COPY . /dockerprac
EXPOSE 3000

# Set the entrypoint for the Jenkins agent
ENTRYPOINT ["java", "-jar", "/opt/remoting.jar"]

CMD ["npm", "run", "start"]
