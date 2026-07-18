def hasChanges = false
def applyConfirmed = false

pipeline {
    agent {
        label 'terraform-executor'
    }
    environment {
            APPLY_CONFIRMED = 'false'
            HAS_CHANGES = 'false'
        }
    stages {
        stage('Terraform init') {
            steps {
                sh 'pwd'
                sh 'terraform version'
                sh 'terraform init'
            }
        }
        stage('Terraform plan') {
//             environment {
//                 PROXMOX_API_TOKEN = credentials('my-predefined-ssh-creds')
//             }
            steps {
                script {
                    def exitCode = sh(script: 'terraform plan -detailed-exitcode -out=tfplan', returnStatus: true)
                    if (exitCode == 0) {
                        echo "No changes detected. Skipping Apply."
                    } else if (exitCode == 2) {
                        echo "Changes detected! Proceeding to apply."
                        hasChanges = true
                        timeout(time: 15, unit: 'MINUTES') {
                            input(
                                message: 'Do you want to apply? By applying I confirm I have read the plan.',
                                ok: 'Apply',
                            )
                        }
                        applyConfirmed = true
                    } else {
                        error "Terraform plan failed with error code ${exitCode}"
                    }
                }
            }
        }
        stage('Terraform apply') {
            when {
//                 branch 'master'
                expression { hasChanges && applyConfirmed  }
            }
            steps {
                echo 'Applying terraform changes...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}