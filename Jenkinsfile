pipeline {
  agent {
    docker {
      image 'ghcr.io/heschmat/jenkins-sonar-argocd-eks'
      // Mount Docker socket for Docker commands inside container
      // Mount Jenkins workspace directory to same path inside container to persist repo and files between stages
      // Set working directory inside container to workspace, so all commands run in the checked-out repo folder
      #args '--user root -v /var/run/docker.sock:/var/run/docker.sock -v $WORKSPACE:$WORKSPACE -w $WORKSPACE'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  environment {
    GH_USERNAME = "gesatessa"
    GH_REPO = "jenkins-sonar-argocd-eks"
    DOCKER_IMAGE = "ghcr.io/${GH_USERNAME}/${GH_REPO}:${BUILD_NUMBER}"
    REGISTRY_CREDENTIALS = credentials('GH_PAT')
    SONAR_URL = "http://44.200.107.11:9000"
  }
  stages {
    stage('Checkout') {
      steps {
        // Checkout the code from GitHub to the Jenkins workspace
        git branch: 'main', url: "https://github.com/${GH_USERNAME}/${GH_REPO}.git"
      }
    }

    stage('Build and Test') {
      steps {
        // Run Maven build
        sh 'mvn clean package'
      }
    }

    stage('Static Code Analysis') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_AUTH_TOKEN')]) {
          // Run SonarQube analysis with token and server URL
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=$SONAR_URL'
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        withCredentials([string(credentialsId: 'GH_PAT', variable: 'GITHUB_TOKEN')]) {
          // Login to GitHub Container Registry and build/push Docker image
          sh '''
            echo $GITHUB_TOKEN | docker login ghcr.io -u ${GH_USERNAME} --password-stdin
            docker build -t ${DOCKER_IMAGE} .
            docker push ${DOCKER_IMAGE}
          '''
        }
      }
    }

    stage('Update Deployment Manifest') {
      steps {
        withCredentials([string(credentialsId: 'GH_PAT', variable: 'GITHUB_TOKEN')]) {
          // Update Kubernetes deployment manifest with new image tag and push changes
          // This runs inside the checked-out git repo because workspace is mounted and working dir is set
          sh '''
            git config user.name "$GH_USERNAME"
            git config user.email "info@me.com"
            sed -i 's|\\(image: ghcr.io/.*/.*:\\).*|\\1${BUILD_NUMBER}|' k8s/app.yml
            git add k8s/app.yml
            git commit -m "Update image tag to $BUILD_NUMBER"
            git push https://${GITHUB_TOKEN}@github.com/$GH_USERNAME/$GH_REPO HEAD:main
          '''
        }
      }
    }
  }
}
