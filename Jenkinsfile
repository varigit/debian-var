pipeline {
  agent {
    label 'linuxKernel'
  }
  stages {
    stage('Deploy') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh './make_var_mx6ul_dart_debian.sh -c deploy -u $USERNAME -p $PASSWORD'
        }

      }
    }
    stage('Update') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh './make_var_mx6ul_dart_debian.sh -c update'
        }

      }
    }
    stage('Build Kernel and package') {
      steps {
        sh 'sudo ./make_var_mx6ul_dart_debian.sh -c package'
      }
    }
    stage('Save Artifacts') {
      steps {
        archiveArtifacts(artifacts: 'output/*.deb', onlyIfSuccessful: true)
      }
    }
    stage('Cleanup') {
      steps {
        sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
      }
    }
  }
}

