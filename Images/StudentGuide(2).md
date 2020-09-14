## 13.1-13.3 Student Guide: ELK Stack Project Week

### Overview

This week, you will set up a cloud monitoring system by configuring an ELK stack server.

### Week Objectives

You will use the following skills and knowledge to complete the following project steps:

- Deploying containers using Ansible and Docker.
- Deploying Filebeat using Ansible.
- Deploying the ELK stack on a server.
- Diagramming networks and creating a README.

**Note:** While you must complete your projects individually, you can work through problems together, and should ask instructional staff for help if you get stuck.

**Important:** Due to Azure Free account limitations, students can only utilize 4vCPUs per region in Azure. Because of this, we will need to create a _new_ vNet in another region for our ELK server.

### Week Overview

#### Day 1: Configuring an ELK Server
On Day 1, we will:
  - Review the overall project and suggested milestones for each day.
    - Note that these milestones are only suggested. If you need extra time on the project, you can continue your work during the second project week in the course.

  - Complete Day 1 activities:
    1. Create a new vNet in Azure in a different region, within the same resource group.
		2. Create a peer-to-peer network connection between their vNets.
        2. Create a new VM in the new vNet that has 2vCPUs and a minimum of 4GiB of memory.
        2. Add the new VM to Ansible’s `hosts` file in their provisioner VM.
    3. Create an Ansible playbook that installs Docker and configures an ELK container.
    4. Run the playbook to launch the container.
    5. Restrict access to the ELK VM.

#### Day 2: Filebeat
On Day 2, we will:
   - Briefly discuss Filebeat before starting activities.

- Complete Day 2 activities:
    1. Navigate to the ELK server’s GUI to view Filebeat installation instructions.
    2. Create a Filebeat configuration file.
    3. Create an Ansible playbook that copies this configuration file to the DVWA VMs and then installs Filebeat.
    4. Run the playbook to install Filebeat.
    5. Confirm that the ELK stack is receiving logs.
    6. Install Metricbeat as a bonus activity.

#### Day 3: Exploration and Diagramming
On Day 3, we will:
- Continue and complete the Filebeat activity, draft a network diagram, and complete a README.

### Lab Environment

You will continue using your personal Azure account and build upon your existing Azure VMs. You will **not** be using your cyberxsecurity accounts.

### Additional Resources
- [Ansible Documentation](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html)
- [`elk-docker` Documentation](https://elk-docker.readthedocs.io/#Elasticsearch-logstash-kibana-elk-docker-image-documentation)
- [Virtual Memory Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)
- ELK Server URL: http://your-IP:5601/app/kibana#/home?_g=()
- [Docker Commands Cheatsheet](https://phoenixnap.com/kb/list-of-docker-commands-cheat-sheet)

### Slideshow

The slideshow to this week is located on Google Drive here: [ELK Stack Project Week (13) Slides](https://docs.google.com/presentation/d/1b0jbp5L_ws2iCFuOSnU7BfoXb6oSiWccqmwXKk8yJ0w/edit#slide=id.g4789b2c72f_0_6)


---
## Day 1: Configuring an ELK Server

### Project Week Overview  

- The purpose of project week is to provide an opportunity to combine everything you've learned in order to create and deploy a live security solution.

- The course includes three projects in total. Two more will come later, in which you will expand on what you create this week, building an increasingly sophisticated skill-set and portfolio.

This week, you will deploy an ELK monitoring stack within your virtual networks. This will allow you to monitor the performance of their Web server that is running DVWA.

In particular, the ELK stack allows analysts to:
- Easily collect logs from multiple machines into a single database.

- Quickly execute complex searches, such as: _Find the 12 internal IP addresses that sent the most HTTP traffic to my gateway between 4 a.m. and 8 a.m. in April 2019._

- Build graphs, charts, and other visualizations from network data.

At the end of the week, you will have a fully functional monitoring solution, live on the cloud.

This will be a major achievement for a few reasons:
- Deploying, configuring, and using an ELK stack is a common task for network engineers, SOC analysts, and other security professionals. Completing this project will be proof of your skills, which you can present to hiring managers.

- The ELK stack is very commonly used in production. You will likely work for organizations that use either ELK or Splunk, covered later in the course. Experience with both is a great addition to a job application.

- You can expand this network with additional machines on your own time to generate a lot of interesting log information. This sort of independent research is useful for learning, and hiring managers love to see it.

Finally, the amount you have learned in order to complete this project, including systems administration, configuration as code, virtualization, and cloud deployment, is substantial. Congratulations on making it this far.

#### Deliverables
As you work through the project, you will develop the following "deliverables" that you can take with you and discuss at job interviews:

- **Network diagram**: This document is an architecture diagram describing the topology of your network.

- **Technical brief**: Answers to a series of questions explaining the important features of the suite, completed after deploying the stack.

- **GitHub repository**: (This is optional and instructions are provided in this week's optional homework.) After completing the project, you will save your work to a database, called a Git repository, along with an in-depth description of the project. This will make it easy for you to redeploy your work in the future, as well as share it with others.

### Introduction to ELK

We'll cover what the ELK stack can do and how it works before you begin deploying it. You should be familiar with ELK from previous units.  

ELK is an acronym. Each letter stands for the name of a different open-source technology:
- **Elasticsearch**: Search and analytics engine.

- **Logstash**: Server‑side data processing pipeline that sends data to Elasticsearch.

- **Kibana**: Tool for visualizing Elasticsearch data with charts and graphs.

ELK started with Elasticsearch. Elasticsearch is a powerful tool for security teams because it was initially designed to handle _any_ kind of information. This means that logs and arbitrary file formats, such as PCAPs, can be easily stored and saved.

- After Elasticsearch became popular for logging, Logstash was added to make it easier to save logs from different machines into the Elasticsearch database. It also processes logs before saving them, to ensure data from multiple sources has the same format before it is added to the database.

- Since Elasticsearch can store so much data, analysts often use visualizations to better understand the data at a glance. Kibana is designed to make it easy to visualize massive amounts of data in Elasticsearch, and it is well known for its complex dashboards.

In summary:
- Elasticsearch is a special database for storing log data.
- Logstash is a tool that makes it easy to collect logs from any machine.
- Kibana allows analysts to easily visualize their data in complex ways.

Together, these three tools provide security specialists with everything you need to monitor traffic in any network.

#### The Beats Family

The ELK stack works by storing log data in Elasticsearch with the help of Logstash.

Traditionally, administrators would configure servers to collect logs using a built-in tool, like `auditd` or `syslog`. They would then configure Logstash to send these logs to Elasticsearch.

- While functional, this approach is not ideal because it requires administrators to collect all of the data reported by tools like `syslog`, even if they only need a small portion of it.

  - For example, administrators often need to monitor changes to specific files, such as `/etc/passwd`, or track specific information, such as a machine's uptime. In cases like this, it is wasteful to collect all of the machine's log data in order to only inspect a fraction of it.

Recently, ELK addressed this issue by adding an additional tool to its data collection suite called **Beats**.

- Beats are special-purpose data collection modules. Rather than collecting all of a machine's log data, Beats allow you to collect only the very specific pieces you are interested in.

ELK officially supports eight Beats. You will use two of them in this project:
- **Filebeat** collects data about the file system.
- **Metricbeat** collects machine metrics, such as uptime.

  - A **metric** is simply a measurement about an aspect of a system that tells analysts how "healthy" it is. Common metrics include:
    - **CPU usage**: The heavier the load on a machine's CPU, the more likely it is to fail. Analysts often receive alerts when CPU usage gets too high.

    - **Uptime**: Uptime is a measure of how long a machine has been on. Servers are generally expected to be available for a certain percentage of the time, so analysts typically track uptime to ensure their deployments meet service-level agreements (SLAs).

 Metricbeat makes it easy to collect specific information about the machines in the network. Filebeat enables analysts to monitor files for suspicious changes.

You can find documentation about the other Beats at the official Elastic.co site: [Getting Started with Beats](https://www.elastic.co/guide/en/beats/libbeat/current/getting-started.html).

### Project Setup
 The goal of this project is to add an instance of the ELK stack to a new virtual network in another region in Azure and configure their 3 Web VM's to send logs to it.

- Make sure that you are logged into your personal Azure accounts and not cyberxsecurity. You will be using the VMs you created during the week on cloud security.

Since you will be building off of that week, let's take a moment to review the network architecture built in that unit.

![Cloud Network](Images/Finished-Cloud-Diagram.png)

This network contains:

- A gateway. This is the jump box configured during the cloud security week.

- Three additional virtual machines, one of which is used to configure the others, and two of which function as load-balanced web servers.

 Due to Azure Free account limitations, students can only utilize 4vCPUs per region in Azure. Because of this, we will need to create a new vNet in another region in Azure for our ELK server.

 - By the end of the project, we will have an ELK server deployed and receiving logs from web machines in the first vNet.

 **Important:** Azure may run out of available VM's for you to create a particular region. _IF_ this happens, You will need to do one of 2 things:
 1. You can open a support ticket with Azure support using [these instructions](https://docs.microsoft.com/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request). Azure support is generally very quick to resolve issues.
 2. You can create another vNet in another region and attempt to create the ELK sever in that region.


In order to set this up, you will perform the following steps:
1. Create a new vNet in a new region (but same resource group).
2. Create a peer-to-peer network connection between their two vNets.
3. Create a new VM within the new network that has a minimum of 4GiB of memory, 8GiB is preferred.
4. Download and configure an ELK stack Docker container on the new VM.
5. Install Metricbeat and Filebeat on the web-DVWA-VMs in their first vNet.

You will use Ansible to automate each configuration step.

At the end of the project, you will be able to use Kibana to view dashboards visualizing the activity of your first vNet.

![Cloud Network with ELK](Images/finished-elk-diagram.png)

You will install an ELK container on the new VM, rather than setting up each individual application separately.

- **Important:** The VM for the ELK server **_MUST_** have at least 4GiB of memory for the ELK container to run properly. Azure has VM options that have `3.5 GiB` of memory, but _DO NOT USE THEM._ They will not properly run the ELK container because they do not have enough memory.
- If a VM that has 4GiB of memory is not available, the ELK VM will need to be deployed in a different region that has a VM with 4GiB available.

- Before containers, we would not have been able to do this. We would have had to separately configure an Elasticsearch database, a Logstash server, and a Kibana server, wire them together, and then integrate them into the existing network. This would require at least three VMs, and definitely many more in a production deployment.

- Instead, now you can leverage Docker to install and configure everything all at once. This is considered best practice and is one of the major advantages of containers.

Remember, you took a similar approach when creating an Ansible control node within the network. You installed an Ansible container rather than installing Ansible directly. This project uses the same simplifying principle, but to even greater effect.

#### References

- More information about ELK can be found at [Elastic: The Elastic Stack](https://www.elastic.co/elastic-stack).
- More information about Filebeat can be found at [Elastic: Filebeat](https://www.elastic.co/beats/filebeat).
- To set up the ELK stack, we will be using a Docker container. Documentation can be found at [elk-docker.io](https://elk-docker.readthedocs.io/).

### Day 1 Activity: ELK Installation


#### Troubleshooting Theory

Please read the [Split-Half Search](https://www.peachpit.com/articles/article.aspx?p=420908&seqNum=3)

* This is an extremely effective troubleshooting methodology that can be applied to _any_ technical issue to find a solution quickly.

* The general procedure states that you should remove _Half_ of the variables that could be causing a problem and re-test.
  * If the issue is resolved, you know that your problem resides in the variables that you removed.
  * If the problem is still present you know your problem resides in the variables that you did not remove.
  * Next, take the set of variables where you know the problem resides.
  * Remove half of them again and retest. Repeat this process until you find the problem.

In the context of this project, removing half of your variables could mean:
- Logging into the Elk server and running the commands from your Ansible script manually.
	- This removes your Ansible script from the equation and you can determine if the problem is with your Ansible Script, OR the problem is on the ELK Server.
	- You can manually launch the ELK container with: `sudo docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk:761`

- Downloading and running a different container on the ELK server.
	- This removes the ELK container from the equation and you can determine if the issue may be with Docker or it may be with the ELK container.

- Removing half of the commands of your Ansible script (or just comment them out).
	- This removes half of the commands you are trying to run and you can see which part of the script is failing.

Another effective strategy is to change _ONE_ thing and only _ONE_ thing before your retest. This is especially helpful when troubleshooting code. If you change several things before you re-test, you will not know if any one of those things has helped the situation or made it worse.


- [Day 1 Activity File: ELK Installation](Activities/Stu_Day_1/Unsolved/ReadMe.md)
- [Day 1 Resources](Activities/Stu_Day_1/Unsolved/Resources/)

#### References
- Peer networking in Azure How-To: [Global vNet Peering](https://azure.microsoft.com/en-ca/blog/global-vnet-peering-now-generally-available/)
- If Microsoft Support is needed: [How to open a support ticket](https://docs.microsoft.com/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request)
- [Split-Half Search](https://www.peachpit.com/articles/article.aspx?p=420908&seqNum=3)

---

## Day  2: Filebeat

### Filebeat Overview

On Day 2, you will continue working the installation of the ELK server. At this point, you have completed the installation of the ELK server, and will now move onto installing **Filebeat**.

Remember, Filebeat helps generate and organize log files to send to Logstash and Elasticsearch. Specifically, it logs information about the file system, including when and which files have changed.

- Filebeat is often used to collect log files from very specific files, such as those generated by Apache, Microsoft Azure tools, the Nginx web server, and MySQl databases.

- Since Filebeat is built to collect data about specific files on remote machines, it must be installed on the VMs that you want to monitor.

- You will install Filebeat on your Web VMs, which will provide a rich source of logs when your deployment is complete.

After installing Filebeat, you will install Metricbeat.

- Installing Filebeat is required. If you run out of time, you can skip Metricbeat.

**Note**: Visit the [Elastic website ](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-modules.html) for information on Filebeat modules.

### Day 2 Activity: Filebeat Installation

- [Day 2 Activity File: Filebeat Installation](Activities/Stu_Day_2/Unsolved/ReadMe.md)
- [Day 2 Resources](Activities/Stu_Day_2/Unsolved/Resources/)

**Note:** The Resources folder includes an `ansible.cfg` file. You don't need to do anything with this file. It's included in case you accidentally edit or delete your configuration file.

---

## Day 3: Exploration and Diagramming

On Day 3, if you need more time installing Filebeat on your DVWA machines, you can continue this work. If you have finished the Filebeat installation, you can move on to create your network diagrams and project READMEs.

### Day 3 Activity: Network Diagramming and README

- [Day 3 Activity File: Network Diagramming and README](Activities/Stu_Day_3/Unsolved/ReadMe.md)

- If you would like additional challenges, we have created optional Kibana activities
  - [Optional Kibana Activities](/Activities/Kibana-Optional)
    - [Linux Stress Optional Activity](Activities/Kibana-Optional/Linux-Stress/Unsolved)
    - [SSH Barrage Optional Activity](Activities/Kibana-Optional/SSH-Barage/Unsolved)
    - [Web Request Dos Optional Activity](Activities/Kibana-Optional/wget-DoS/Unsolved)
---

## Congratulations!

Congratulations on making it to the end of the first project week, and on all the work you've done for the past 13 weeks.

You should make sure your projects are complete, professionally presentable, and free of errors. You can use these resources as proof of knowledge and experience in the hiring process.

---
© 2020 Trilogy Education Services, a 2U, Inc. brand. All Rights Reserved.  
