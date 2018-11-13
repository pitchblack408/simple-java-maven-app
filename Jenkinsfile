pipeline {
    agent {
        docker {
            image 'maven:3-alpine'
            args '-v /root/.m2:/root/.m2'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Git-Release') {
            steps {
              withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'github-api-personal', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                  sh 'echo user:$USERNAME token:$PASSWORD > text.txt'
              }
            }
        }
       
    }
}
