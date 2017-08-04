pipeline {
    agent {
        dockerfile {
            label 'DockerLinux'
        }
    }
    stages {
        stage('Setup') {
            steps {
                sh 'bundle install'
                sh 'echo "terraform-version: 0.10.0" > config/config.yml'
            }
        }
        stage('Test') {
            environment {
                AWS_REGION = 'eu-west-1'
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'terraform-modules-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh 'bundle exec rake preflight'
                }
            }
        }
    }
    post {
        always {
            script {
                // manually define GIT_COMMIT as git plugin is broken:
                // https://issues.jenkins-ci.org/browse/JENKINS-35230
                env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                env.RESULT = (currentBuild.currentResult == 'SUCCESS') ? 'success' : 'failure'
            }
            withCredentials([usernamePassword(
                credentialsId: 'terraform-modules-github',
                usernameVariable: 'GH_USER',
                passwordVariable: 'GH_PASSWORD')]) {

                sh """
                    curl -f --user $GH_USER:$GH_PASSWORD -H "Content-Type: application/json" \
                        -X POST -d '{"state": "$RESULT"}' \
                        https://api.github.com/repos/betabandido/TerraformModules/statuses/$GIT_COMMIT
                """
            }
            deleteDir()
        }
    }
}
