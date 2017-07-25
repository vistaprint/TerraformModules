pipeline {
    agent {
        label 'DockerLinux'
    }
    stages {
        stage('Setup') {
            steps {
                sh 'bundle install'
                sh 'echo terraform-version: 0.9.101 > config/config.yml'
                sh 'wget -P bin https://s3-eu-west-1.amazonaws.com/mpus-integration/terraform/terraform'
                sh 'chmod +x ./bin/terraform'
                sh './bin/terraform --version'
            }
        }
        stage('Test') {
            agent {
                dockerfile {
                    reuseNode true
                }
            }
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
                env.RESULT = 'failure'
                if (currentBuild.currentResult == 'SUCCESS') {
                    env.RESULT = 'success'
                }
            }
            withCredentials([usernamePassword(
                credentialsId: 'terraform-modules-github',
                usernameVariable: 'GH_USER',
                passwordVariable: 'GH_PASSWORD')]) {

                sh """
                    curl -f --user $GH_USER:$GH_PASSWORD -H "Content-Type: application/json" \
                        -X POST -d '{"state": "$RESULT"}' \
                        https://api.github.com/repos/betabandido/JenkinsIntegrationTest/statuses/$GIT_COMMIT
                """
            }
            deleteDir()
        }
    }
}
