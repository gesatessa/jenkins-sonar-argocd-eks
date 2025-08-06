pipeline {
  agent {
    docker {
      image 'ghcr.io/heschmat/jenkins-sonar-argocd-eks'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  environment {
    GH_USERNAME = "heschmat"
    GH_REPO = "jenkins-sonar-argocd-eks"
    DOCKER_IMAGE = "ghcr.io/${GH_USERNAME}/${GH_REPO}:${BUILD_NUMBER}"
    REGISTRY_CREDENTIALS = credentials('GH_PAT')  // Must be GitHub PAT
    SONAR_URL = "http://3.237.36.54:9000"
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: "https://github.com/${GH_USERNAME}/${GH_REPO}.git"
      }
    }

    stage('Build and Test') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Static Code Analysis') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=$SONAR_URL'
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        script {
          def dockerImage = docker.build("${DOCKER_IMAGE}")
          docker.withRegistry('https://ghcr.io', 'GH_PAT') {
            dockerImage.push()
          }
        }
      }
    }

    stage('Update Deployment Manifest') {
      steps {
        withCredentials([string(credentialsId: 'GH_PAT', variable: 'GITHUB_TOKEN')]) {
          sh '''
            git config user.name "$GH_USERNAME"
            git config user.email "info@me.com"
            sed -i "s/replaceImageTag/$BUILD_NUMBER/g" k8s/app.yml
            git add k8s/app.yml
            git commit -m "Update image tag to $BUILD_NUMBER"
            git push https://${GITHUB_TOKEN}@github.com/$GH_USERNAME/$GH_REPO HEAD:main
          '''
        }
      }
    }
  }
}
