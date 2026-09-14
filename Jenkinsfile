pipeline {

    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'stg', 'prod'],
            description: 'Choose environment'
        )
    }

    environment {
        NOTIFY_EMAIL = 'yousramamdouh1405@gmail.com'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -reconfigure'
            }
        }

        stage('Terraform Workspace') {
            steps {
                sh '''
                    terraform workspace select ${ENV} || terraform workspace new ${ENV}
                    terraform workspace show
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -var-file=${ENV}.tfvars -out=tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: "Apply Terraform to ${ENV}?", ok: "Apply"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {

        success {
            emailext(
                subject: "SUCCESS: Terraform ${ENV}",
                body: """
Terraform deployment completed successfully.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Jenkins URL:
${BUILD_URL}
""",
                to: "${NOTIFY_EMAIL}"
            )
        }

        failure {
            emailext(
                subject: "FAILED: Terraform ${ENV}",
                body: """
Terraform deployment FAILED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Check the Jenkins console for the error:

${BUILD_URL}console
""",
                to: "${NOTIFY_EMAIL}"
            )
        }

        aborted {
            emailext(
                subject: "ABORTED: Terraform ${ENV}",
                body: """
Terraform deployment was ABORTED.

This usually happens when the approval step was rejected or the build was
manually cancelled.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Jenkins URL:
${BUILD_URL}
""",
                to: "${NOTIFY_EMAIL}"
            )
        }
    }
}
