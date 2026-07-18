pipeline {
    agent {
        label 'terraform-executor'
    }
    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform version'
            }
        }
        stage('Init') {
            steps {
                sh 'pwd'
                sh 'ls -al'
            }
        }
    }
}