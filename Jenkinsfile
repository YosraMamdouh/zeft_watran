pipeline {

    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'stg', 'prod'],
            description: 'Choose the Terraform environment'
        )
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        NOTIFY_EMAIL = "yousramamdouh1405@gmail.com"
        AWS_CRED_ID  = "aws-terraform-deploy" // اسم الـ Credentials المسجلة في Jenkins
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    set -o pipefail
                    terraform init \
                      -reconfigure \
                      2>&1 | tee terraform-init.log
                '''
            }
        }

        stage('Workspace Select') {
            steps {
                sh '''
                    terraform workspace select ${ENV} || terraform workspace new ${ENV}
                    terraform workspace show
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    set -o pipefail
                    terraform fmt -check -recursive
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([aws(credentialsId: env.AWS_CRED_ID, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        set -o pipefail

                        terraform plan \
                          -var-file=${ENV}.tfvars \
                          -out=tfplan \
                          2>&1 | tee terraform-plan.log
                    '''
                }
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: "Terraform plan is ready. Apply ${ENV}?",
                    ok: "Approve and Apply"
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([aws(credentialsId: env.AWS_CRED_ID, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        set -o pipefail

                        terraform apply \
                          -auto-approve \
                          tfplan \
                          2>&1 | tee terraform-apply.log
                    '''
                }
            }
        }
    }

    post {

        always {
            archiveArtifacts artifacts: 'terraform-*.log, tfplan', allowEmptyArchive: true
        }

        success {
            emailext(
                subject: "SUCCESS: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                body: """
Terraform deployment completed successfully.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Terraform Apply: SUCCESS

Jenkins:
${BUILD_URL}
""",
                to: "${NOTIFY_EMAIL}"
            )
        }

        failure {
            script {
                def reason = "Unknown failure"

                if (fileExists('terraform-apply.log')) {
                    reason = readFile('terraform-apply.log')
                }
                else if (fileExists('terraform-plan.log')) {
                    reason = readFile('terraform-plan.log')
                }
                else if (fileExists('terraform-init.log')) {
                    reason = readFile('terraform-init.log')
                }

                emailext(
                    subject: "FAILED: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                    body: """
Terraform deployment FAILED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Failure Reason:
${reason}

Check Jenkins Console:

${BUILD_URL}console
""",
                    to: "${NOTIFY_EMAIL}"
                )
            }
        }

        aborted {
            emailext(
                subject: "ABORTED: Terraform ${ENV} - Build #${BUILD_NUMBER}",
                body: """
Terraform deployment was ABORTED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

The deployment was stopped by the user before completion.

Jenkins:
${BUILD_URL}console
""",
                to: "${NOTIFY_EMAIL}"
            )
        }
    }
}