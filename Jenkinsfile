pipeline {
    agent any

    stages {
        stage('terraform check version') {
            steps {
                sh 'pwd'
                sh 'terraform --version'
            }
        }
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}