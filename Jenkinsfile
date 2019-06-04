pipeline {
  agent {
    label 'linuxKernel'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '2'))
  }

  environment {
    PRODUCT_AVENTURA = 'twonav-aventura-2018'
    PRODUCT_TRAIL = 'twonav-trail-2018'
    AVENTURA_OUTPUT_DIR = 'output-aventura'
    TRAIL_OUTPUT_DIR = 'output-trail'
  }

  stages {
    stage('Deploy') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh "./make_var_mx6ul_dart_debian.sh -c deploy -u $USERNAME -p $PASSWORD"
        }
      }
    }

    stage('Update') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh "./make_var_mx6ul_dart_debian.sh -c update -u $USERNAME -p $PASSWORD"
        }

      }
    }

    stage('Build Kernel and package') {
      stages {
        stage('Building Aventura') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_AVENTURA} -o ${WORKSPACE}/${AVENTURA_OUTPUT_DIR}"
          }
        }
        stage('Building Trail') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_TRAIL} -o ${WORKSPACE}/${TRAIL_OUTPUT_DIR}"
          }
        }
      }
    }

    stage('Fixing file permissions') {
      /* In order for ${USER} to be able to execute a script/binary using sudo without the necessity for a password,
         the following file has to be created /etc/sudoers.d/${USER} with the following contents
         ${USER} ALL = NOPASSWD: /path/to/script, /bin/chown
         listing all the commands that won't need credentials. In the above example ${USER} will be able to execure 'sudo chown'
         without beiing asked for password. 
         The following steps are necessary because Jenkins executes some commands with a user different than root on files that belong to user root,
         thus permissions have to be fixed, otherwise the pipeline fails.
      */
      steps {
        sh 'printenv'
        sh "echo ${USER}"
        sh "sudo chown -R ${USER}:${USER} rootfs"
        sh "sudo chown -R ${USER}:${USER} tmp"
        sh "sudo chown -R ${USER}:${USER} ${AVENTURA_OUTPUT_DIR}"
        sh "sudo chown -R ${USER}:${USER} ${TRAIL_OUTPUT_DIR}"
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished.'
    }

    success {
      echo 'Saving Artifacts'
      archiveArtifacts artifacts: "${AVENTURA_OUTPUT_DIR}/*deb,${TRAIL_OUTPUT_DIR}/*deb", onlyIfSuccessful: true
    }
  }
}
