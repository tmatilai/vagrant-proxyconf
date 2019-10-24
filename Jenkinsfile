pipeline {

  agent { label 'virtualbox' }

  options {
    disableConcurrentBuilds()
  }

  parameters {

    string(
      name: 'VAGRANT_TEST_ISSUE',
      defaultValue: '180',
      description: 'The test/issues/# where "#" refers to the test environment to invoke'
    )

    string(
      name: 'DEFAULT_RVM_RUBY',
      defaultValue: '2.4.4',
      description: 'The default ruby to use for RVM'
    )

  }

  stages {

    stage('test') {

      environment {
        VAGRANT_TEST_ISSUE = "${params.VAGRANT_TEST_ISSUE}"
        DEFAULT_RVM_RUBY = "${params.DEFAULT_RVM_RUBY}"
      }

      steps {
        timestamps {
          ansiColor('xterm') {

            dir("${WORKSPACE}") {

              sh '''#!/usr/bin/env bash -l

                set +x
                tty
                . jenkins/helper_functions

                setup_test_env

                set -e
                run_all_tests

              '''
            }
          }
        }
      }
    }

  } // stages

}
