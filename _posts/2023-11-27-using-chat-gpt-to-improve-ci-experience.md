---
layout: post
title: Improving CI/CD experience with ChatGPT
categories:
- software
tags:
- chatgpt
- jenkins
- pipeline
- "CI/CD"
---


* content
{:toc}

## Background

At my current company, before I joined, we had a build system based on [Jenkins](https://en.wikipedia.org/wiki/Jenkins_(software)).
I love Jenkins. It's powerful, extensible, open-source and self-hosted.

But great power comes with significant responsibilities. Jenkins allows you to make _bad_ decisions easily.

In our case, Jenkins' Jobs were fully defined in UI. Why is it wrong? Well:

* It's impossible to track it in [Version Control System](https://en.wikipedia.org/wiki/Version_control) such as git.
* It's easy to screw up. If you accidentally change a step in UI, you can only spot it through your naked eyes.
* It's hard to get a whole picture. In our case, it required to scroll a screen 4-6 times to see a whole file.
* It's hard to reuse code. (Still possible tho)
* Restarting the pipeline from the beginning or specific stage is [impossible](https://issues.jenkins.io/browse/JENKINS-45455).

I decided to address all the mentioned problems.
This article will tell you how I moved to pipelines defined by [Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) with the help of ChatGPT.

## Reasons to use AI

There are no particular reasons to do it.

It's an easy but tedious task to structure Jenkinsfile.

Due to my laziness, I was seeking the most effortless approach. Since I'm paying for ChatGPT, I said, "_OK, AI is not so bad at summarizing texts_". In this case, the problem is summarizing: UI is a wordy source, and Jenkisfile is a short summary.


## Source of input

When I was implementing the migration, it was impossible to send pics to ChatGPT. Even if possible, I wonder if I can treat it as good input.
Jenkins jobs we defined in UI are stored somewhere, so I started searching for the source of the job's definitions.

I was lucky to quickly find the exact question on [StackOverflow](https://stackoverflow.com/questions/71504138/how-to-view-jenkins-job-configuration-as-xml-in-the-browser).
The proposed request to the HTTP handler didn't work for some reason, so I just ran `find <jenkins_dir> -name config.xml -type f ` and immediately found the configuration for the pipeline defined in XML.

We've got a source! It's not perfect since it's a colossal XML, but who cares? Let's feed it now into GPT!

## Results

After some back and forth, ChatGPT was able to generate something that I wanted.
It didn't go deep, but I didn't ask it for. I wanted some skeleton or boilerplate code that I could then extend.

Of course, I had to go through every command and thoroughly read the documentation to understand what was happening in this script.
But the cool thing is that I know what to search for.

In my case, it was a perfect example of using ChatGPT. I already had a working job that I wanted to get. The thing that I should have in the end should be a drop-in replacement.

Few more bonuses:
* It allows me to ask about specific parts or share the names of the plugins it used.
* I can feed other XML files.
* It takes less mental power for me to edit something rather than to create from scratch.

Here is the reduced, high-level script I've got from ChatGPT so you can see that there is nothing specific, just boilerplate lines:

```groovy
pipeline {
    agent { label 'built-in' }
    parameters {
        string(name: 'NAME', defaultValue: '',
               description: 'Feature name')
        booleanParam(name: 'UPLOAD_BUILD', defaultValue: false,
                     description: 'Upload build to cloud')
        string(name: 'BRANCH', defaultValue: 'feature_build',
               description: 'Git branch to build')
    }

    environment {
        GIT_URL = 'git@github.com:...'
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: "${params.BRANCH}"]],
                          doGenerateSubmoduleConfigurations: false,
                          extensions: [],
                          submoduleCfg: [],
                          userRemoteConfigs: [[url: "${env.GIT_URL}"]]])
            }
        }

        stage('Run Versions Script') {
            steps {
                script {
                    ...
                }
            }
        }

        stage('Trigger Builds') {
            steps {
                script {
                    build(job: '...', parameters: [string(name: 'VERSION',
                          value: "${env.VERSION}")], wait: false)
                    build(job: '...', parameters: [string(name: 'VERSION',
                          value: "${env.VERSION}")], wait: false)
                    build(job: '...', parameters: [string(name: 'VERSION',
                          value: "${env.VERSION}")], wait: false)
                }
            }
        }

        stage('Copy Artifacts') {
            steps {
                script {
                    copyArtifacts(projectName: '...', filter: '...',
                                  target: '/builds/')
                }
            }
        }

        stage('Run Post-Build Operations') {
            steps {
                script {
                    if (fileExists('./post_build.sh')) {
                        sh './post_build.sh'
                    }

                    if(params.UPLOAD_BUILD) {
                        ...
                    }
                }
            }
        }
    }
}
```
