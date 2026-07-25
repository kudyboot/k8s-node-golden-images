def hasChanges = false
def applyConfirmed = false



pipeline {
    agent {
        label 'executor'
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
            environment {
                TF_VAR_ssh_user = "${env.NODE_SSH_USER}"
                TF_VAR_ssh_public_key = "${env.NODE_SSH_PUBLIC_KEY}"
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'proxmox', usernameVariable: 'TF_VAR_proxmox_user', passwordVariable: 'TF_VAR_proxmox_password')])
                    {
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