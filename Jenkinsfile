pipeline {
  agent any

  environment {
    TF_IN_AUTOMATION = "true"
    TF_DIR = "Sandbox_dev"
  }

  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'github-login', url: 'https://github.com/Malikwaqas162/Terraform-IAC-Infrastructure-Assessment.git'
      }
    }

    stage('Terraform Init') {
      steps {
        dir("${env.TF_DIR}") {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir("${env.TF_DIR}") {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("${env.TF_DIR}") {
          sh 'terraform plan -out=tfplan'
        }
      }
    }
  }

  post {
    failure {
      echo 'Build failed during Terraform execution.'
    }
  }
}
