pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Point kubectl to Minikube') {
            steps {
                bat 'kubectl config use-context minikube'
            }
        }

        stage('Call Script to Update NGINX Version') {
            steps {
                               bat '"C:\\Program Files\\Git\\bin\\bash.exe" -c "./Update-Version.sh"'
            }
        }

        stage('Verify Update') {
            steps {
                bat 'helm list -n default'
                bat 'helm get values my-nginx -n default'
                bat 'kubectl get pods -n default -o wide'
            }
        }
    }
}
