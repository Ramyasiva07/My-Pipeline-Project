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
                sh 'kubectl config use-context minikube'
            }
        }

        stage('Call Script to Update NGINX Version') {
            steps {
                sh 'chmod +x update-version.sh'
                sh './update-version.sh'
            }
        }

        stage('Verify Update') {
            steps {
                sh 'helm list -n default'
                sh 'helm get values my-nginx -n default'
                sh 'kubectl get pods -n default -o wide'
            }
        }
    }
}
