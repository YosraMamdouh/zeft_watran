```groovy
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
                sh '''
                    set -o pipefail

                    # Remove previous Terraform initialization
                    # to avoid backend configuration conflicts
                    rm -rf .terraform

                    terraform init -reconfigure 2>&1 | tee terraform-init.log
                '''
            }
        }

        stage('Workspace Select') {
            steps {
                sh '''
                    set -e

                    terraform workspace select "${ENV}" || \
                    terraform workspace new "${ENV}"

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
                sh '''
                    set -o pipefail

                    terraform plan \
                      -var-file="${ENV}.tfvars" \
                      -out=tfplan \
                      2>&1 | tee terraform-plan.log
                '''
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: "Terraform plan for VPC is ready. Do you want to Apply to ${ENV}?",
                    ok: "Approve and Apply",
                    submitterParameter: 'APPROVER'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
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

    post {

        always {
            archiveArtifacts(
                artifacts: 'terraform-*.log, tfplan',
                allowEmptyArchive: true
            )
        }

        success {
            emailext(
                subject: "SUCCESS: Terraform VPC ${ENV} - Build #${BUILD_NUMBER}",
                body: """
VPC deployment completed successfully.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Jenkins: ${BUILD_URL}
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
                    subject: "FAILED: Terraform VPC ${ENV} - Build #${BUILD_NUMBER}",
                    body: """
Terraform VPC deployment FAILED.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
Job: ${JOB_NAME}

Failure Details & Reason:
----------------------------------------
${reason}
----------------------------------------

Console URL: ${BUILD_URL}console
""",
                    to: "${NOTIFY_EMAIL}"
                )
            }
        }

        aborted {
            emailext(
                subject: "ABORTED: Terraform VPC ${ENV} - Build #${BUILD_NUMBER}",
                body: """
Terraform deployment was ABORTED by user.

Environment: ${ENV}
Build Number: ${BUILD_NUMBER}
""",
                to: "${NOTIFY_EMAIL}"
            )
        }
    }
}
```

### The main fix

I added:

```bash
rm -rf .terraform
terraform init -reconfigure
```

This forces Jenkins to remove the old Terraform initialization and initialize the backend again, which addresses the:

```text
Backend initialization required
Reason: Unsetting the previously set backend "local"
```

error.

I also changed:

```bash
terraform workspace select ${ENV}
```

to:

```bash
terraform workspace select "${ENV}"
```

and similarly quoted the `.tfvars` filename for safer shell handling.

After replacing the Jenkinsfile, run the pipeline and select **`dev`**.
