# Joseph Pospichal Project 1
# University of California San Diego Cybersecurity Bookcamp
# Within Azure create a VNet of VMs for Ansible, Docker, DVWA & ELK
## Automated ELK Stack Deployment

Table of Contents
[TOC]
[ Decription fo the Topology ] (#desc)
[ Access Policies ] (#access)
[ Elk Configuration ] (#elkconfig)
[ Target Machines & Beats ] (#targetmch)
[ Using the Playbook for Filebeat ] (#usepbfb)
[ Verifying Filebeat Installation and Playbook ] (#fbver)
[ Using the Playbook for Metricbeat ] (#usepbmb)
[ Verifying Metricbeat Installation and Playbook ] (#mbver)
[ Things to Keep in Mind ] (#ttkim)
[ Additional Resources ] (#addresources)

The files in this repository were used to configure the network depicted below.

- [Project 1 Network Diagram.png](Images/Project 1 Network Diagram.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above or a portion. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

    install-elk.yml
    filebeat-playbook.yml
    metricbeat-playbook.yml

This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build

<a-name="desc"></a>
### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, also known as the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.

A load balancer will increase the availability of the Back End Pool (Web servers being balanced) by performing a health probe of each of the servers to determin its availability.

A jump box server is used to access and manage devices in the security zone.  Internal access to the web servers is thru the jump box.  The jump box also hosts Ansible.  Ansible is open-source software provisioning, configuration management, and application deployment tool.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the log files and system metrics.

  Filebeat collects and parses logs created by the system logging service.
  
  Metricbeat will monitor the metrics from the Docker server: cpu, diskio, healthcheck, info, memory, and network.


The configuration details of each machine may be found below:

| Name                 | Function | IP Address | Operating System     |
|----------------------|----------|------------|----------------------|
| Jump-Box-Provisioner | Gateway  | 10.1.0.4   | Linux (Ubuntu 18.04) |
| Web-1                | DVWA     | 10.1.0.8   | Linux (Ubuntu 18.04) |
| Web-2                | DVWA     | 10.1.0.9   | Linux (Ubuntu 18.04) |
| Web-3                | DVWA     | 10.1.0.10  | Linux (Ubuntu 18.04) |
| ELK-VM               | ELK      | 10.0.2.4   | Linux (Ubuntu 18.04) |

<a-name="access"></a>
### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump-Box-Provsioner machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:

  Local IP (and the internal 10.1.0.4)

Machines within the network can only be accessed by 10.1.0.4 (Jump-Box-Provisioner)
_

A summary of the access policies in place can be found in the table below.


| Name                 | Publicly Accessible | Allowed IP Addresses |
|----------------------|---------------------|----------------------|
| Jump-Box-Provisioner | Yes                 | Local IP             |
| Web-1                | No                  | 10.1.0.4             |
| Web-2                | No                  | 10.1.0.4             |
| Web-3                | No                  | 10.1.0.4             |
| ELK-VM               | Yes                 | Local IP             |

<a-name="elkconfig"></a>
### Elk Configuration

Ansible automates the configuration of the ELK machine. No configuration was performed manually, which is advantageous because the configuration management is automated in Ansible.   Time consuming, repetive tasks are accomplished using standardized playbooks.

The Ansible playbook for ELK implements the following tasks:

  - Install the docker.io (the deb package for Ubuntu)
  - Install Python
  - Increase virtual memory (to 262144)
  - Install the docker module
  - Download and launch an ELK docker container
  - Enable the docker service to start on boot

The ELK configuration file can be found here:
 - [install-elk.yml](Playbooks/install-elk.yml)

The Ansible `hosts` file contains the configuration for the VNet webservers and elkservers.
The Ansible configuration file can be found here:
- [hosts](Playbooks/hosts)

The `hosts` file should already have the following changes made:

- This list is Ansible's **inventory**, and is stored in the `hosts` text file:

	```
	# /etc/ansible/hosts
	[webservers]
	10.0.0.4 ansible_python_interpreter=/usr/bin/python3
	10.0.0.5 ansible_python_interpreter=/usr/bin/python3
  10.0.0.6 ansible_python_interpreter=/usr/bin/python3

	[elk]
	10.1.0.4 ansible_python_interpreter=/usr/bin/python3
	```


To run the ELK configuration:

  1) From a terminal ssh to the Jump-Box-Provisioner
  2) Start the Ansible container
    - `sudo docker start [container name]`
  3) Attach to the Ansible container
    - `sudo docker attach [container name]`
  4) Change directories to: /etc/ansible
    - `cd /etc/ansible`
  5) The ELK playbook `install-elk.yml`should be located in the `/etc/ansible` directory
  3) Run the ELK playbook:  
     - `ansible-playbook install-elk.yml`

Once the configuration of the ELK instance is complete, ssh to the ELK VM.
  - `ssh [id]@10.2.0.4`
Run the following command to ensure that the ELK install has been successful:
  -   `sudo docker ps`

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance:

  - [docker_ps_output.png](Images/docker_ps_output.png)


<a-name="targetmch"></a>
### Target Machines & Beats
This ELK server is configured to monitor the following virtual machines:

  - 10.1.0.8  (Web-1)
  - 10.1.0.9  (Web-2)
  - 10.1.0.10 (Web-3)

Each of the virutal machines have the following Beats installed:

  - Filebeat
  - Metricbeat

These Beats allow us to collect the following information from each machine:

  - Filebeat: An agent is installed on a server where Syslog data is then collected.  This data includes application logs.  The logs are monitored and sent to Logstash to processes the logs with metadata for simpler searching.  The logs are then sent to for Elasticsearch for indexing and storage.  Kibana is used to parse and display log queries.  Filebeat can for example capture SSH login attempts, Successful SSH logins, and SSH user of failed login attempts.

  - Metricbeat: Like Filebeat, Metricbeat utilizes Elasticsearch, Logstash and Kilbana. Metricbeat captures Docker metrics, which would show the status and health of the Docker containers.  Metrics include: Docker containers, Number of Containers (and status: Running, Paused, Stopped), CPU usage, Memory usage and Network IO.

<a-name="usepbfb"></a>
### Using the Playbook for Filebeat

These tasks are performed on the VMs that are specified within the Filebeat configuration file located within Ansible at /etc/ansible/files/filebeat-configuration.yml

These tasks are performed on the VMs that are specified within the Ansible `hosts` file.

In order to use the playbook, you will need to have an Ansible control node already configured and running. Assuming you have such a control node provisioned: 

Follow these steps to install Filebeat:

  1) From a terminal ssh to the Jump-Box-Provisioner
  2) Start the Ansible container
    - `sudo docker start [container name]`
  3) Attach to the Ansible container
    - `sudo docker attach [container name]`
  4) Change directories to: /etc/ansible
    - `cd /etc/ansible`
  5) Make sure the the ELK server container is up and running, ssh to the ELK VM.
    - `ssh [id]@10.2.0.4`
  6) Run `docker container list -a` to verify that that the container is on.
  7) If it isn', run `docker start elk`
  8) Return to Ansible `exit`
  9) The ready to use and already modified Filebeat configuration file can be found here:
    - [filebeat-configuration.yml](Playbooks/filebeat-configuration.yml)  
  
    - Or can be downloaded and modified:

    Use `curl` to download a copy of the Filebeat configuration file:
    - `curl https://gist.githubusercontent.com/slape/5cc350109583af6cbe577bbcc0710c93/raw/eca603b72586fbe148c11f9c87bf96a63cb25760/Filebeat > /etc/ansible/files/filebeat-configuration.yml`
 

 ```bash
root@be61a239baae:/etc/ansible# curl https://gist.githubusercontent.com/slape/5cc350109583af6cbe577bbcc0710c93/raw/eca603b72586fbe148c11f9c87bf96a63cb25760/Filebeat > filebeat-configuration.yml
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 73112  100 73112    0     0   964k      0 --:--:-- --:--:-- --:--:--  964k
 ```

  10) Edit the configuration file for VM specifics:
    -  `nano filebeat-configuration.yml`
  11) Scroll to line #1106 and replace the IP address with the IP address of the ELK machine.

```bash
output.elasticsearch:
hosts: ["10.2.0.4:9200"]
username: "elastic"
password: "changeme"
```

  12) Scroll to line #1806 and replace the IP address with the IP address of the ELK machine.

```
setup.kibana:
host: "10.2.0.4:5601"
```
  13) Save this file in  `/etc/ansible/files/filebeat-configuration.yml`.
  14) Create the `filebeat-playbook.yml`
  
  The ready to use and already modified Filebeat playbook file can be found here:
  - [filebeat-playbook.yml](Playbooks/filebeat-playbook.yml)

  - `cat filebeat-playbok.yml` to confirm the Ansible playbook for Filebeat implements the following tasks: 

    a) Download the `.deb` file from [artifacts.elastic.co](https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb).

    b) Install the `.deb` file using the `dpkg` command shown below:
    - `dpkg -i filebeat-7.4.0-amd64.deb`
    
    c) Copy the Filebeat configuration file from the Ansible container to each of the WebVM's where Filebeat has just been installed.
    
    d) Place the configuration file in a directory called `filebeat`.
    
    e) Run the `filebeat modules enable system` command.
    
    f) Run the `filebeat setup` command.
    
    g) Run the `service filebeat start` command.  
  
  15) The Filebeat playbook `filebeat-playbook.yml`should be located in the `/etc/ansible/roles` directory
  16) Run the `ansible-playbook filebeat-playbook.yml` command.
  

```bash
root@be61a239baae:/etc/ansible# ansible-playbook filebeat-playbook.yml

PLAY [installing and launching filebeat] *******************************************************

TASK [Gathering Facts] *************************************************************************
ok: [10.1.0.8]
ok: [10.1.0.9]
ok: [10.1.0.10]


TASK [download filebeat deb] *******************************************************************
[WARNING]: Consider using the get_url or uri module rather than running 'curl'.  If you need to
use command because get_url or uri is insufficient you can add 'warn: false' to this command
task or set 'command_warnings=False' in ansible.cfg to get rid of this message.

changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [install filebeat deb] ********************************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [drop in filebeat.yml] ********************************************************************
ok: [10.1.0.8]
ok: [10.1.0.9]
ok: [10.1.0.10]

TASK [enable and configure system module] ******************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [setup filebeat] **************************************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [start filebeat service] ******************************************************************
[WARNING]: Consider using the service module rather than running 'service'.  If you need to use
command because service is insufficient you can add 'warn: false' to this command task or set
'command_warnings=False' in ansible.cfg to get rid of this message.

changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

PLAY RECAP *************************************************************************************
10.1.0.8                  : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.1.0.9                  : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.1.0.10                   : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

<a-name="fbver"></a>
### Verifying Filebeat Installation and Playbook 

  1) Make sure that the ELK server container is up and running.
    - On the workstation, navigate to http://52.249.189.192:5601/app/kibana/home. 

    - Note that if you do not see the ELK server landing page, open a terminal on your computer and SSH into the ELK server.

    - Run `docker container list -a` to verify that the container is on.

    - If it is not, run `docker start elk`.

  2) Verify that the Filebeat playbook is completing the section `Using the Playbook for Filebeat`.

  3) Open the ELK server homepage.
    - Click on **Add Log Data**.
    - Choose **System Logs**.
    - Click on the **DEB** tab under **Getting Started** to view the correct Linux Filebeat installation instructions.
    - Sroll to **Module Status** and click **Check Data**.

  4) If the ELK stack was successfully receiving logs, you would see: 

    - [Filebeat_receiving.png](Images/Filebeat_receiving.png)


<a-name="usepbfb"></a>
### Using the Playbook for Metricbeat

These tasks are performed on the ELK server that is specified within the Metricbeat configuration file located within Ansible at /etc/ansible/files/metricbeat.yml

These tasks are performed on the VMs that are specified within the Ansible `hosts` file.

In order to use the playbook, you will need to have an Ansible control node already configured and running. Assuming you have such a control node provisioned: 

Follow these steps to install Metricbeat:

  1) From a terminal ssh to the Jump-Box-Provisioner
  2) Start the Ansible container
    - `sudo docker start [container name]`
  3) Attach to the Ansible container
    - `sudo docker attach [container name]`
  4) Change directories to: /etc/ansible
    - `cd /etc/ansible`
  5) Make sure the the ELK server container is up and running, ssh to the ELK VM.
    - `ssh [id]@10.2.0.4`
  6) Run `docker container list -a` to verify that that the container is on.
  7) If it is not, run `docker start elk`
  8) Return to Ansible `exit`
  9) The ready to use and already modified Metricbeat configuration file can be found here:
    - [metricbeat.yml](Playbooks/metricbeat.yml)  
  
  - Or can be downloaded and modified:
  
  Use `curl` to download a copy of the Metricbeat configuration file:
  - `curl https://gist.githubusercontent.com/slape/58541585cc1886d2e26cd8be557ce04c/raw/0ce2c7e744c54513616966affb5e9d96f5e12f73/metricbeat > /etc/ansible/files/metricbeat.yml`
 

 ```bash
root@be61a239baae:/etc/ansible# curl https://gist.githubusercontent.com/slape/58541585cc1886d2e26cd8be557ce04c/raw/0ce2c7e744c54513616966affb5e9d96f5e12f73/metricbeat > metric.yml
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6188  100  6188    0     0  24171      0 --:--:-- --:--:-- --:--:-- 24171
 ```

  10) Edit the configuration file for VM specifics:
    -  `nano metricbeat.yml`
  11) Scroll to `Elasticsearch output` and replace the IP address with the IP address of the ELK machine.

```bash
output.elasticsearch:
hosts: ["10.2.0.4:9200"]
username: "elastic"
password: "changeme"
```

  12) Scroll to `Logstash output` and replace the IP address with the IP address of the ELK machine.

```
setup.kibana:
host: "10.2.0.4:5601"
```
  13) Save this file in  `/etc/ansible/files/metricbeat.yml`.
  14) Create the `metricbeat-playbook.yml`
  
  The ready to use  and already modified Metricbeat playbook file can be found here:
    - [metricbeat-playbook.yml](Playbooks/metricbeat-playbook.yml)

    - `cat metricbeat-playbok.yml` to confirm the Ansible playbook for Metricbeat implements the following tasks: 

    a) Download the `.deb` file from [artifacts.elastic.co](https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb).
    
    b) Install the `.deb` file using the `dpkg` command shown below:
      - `dpkg -i metricbeat-7.6.1-amd64.deb`
    
    c) Place the configuration file in a directory called `metricbeat`.
    
    e) Run the `metricbeat modules enable docker` command.
    
    f) Run the `metricbeat setup` command.
    
    g) Run the `service metricbeat start` command.
  
  15) The Metricbeat playbook `metricbeat-playbook.yml`should be located in the `/etc/ansible/roles` directory
  16) Run the `ansible-playbook metricbeat-playbook.yml` command.


```bash
root@be61a239baae:/etc/ansible# ansible-playbook metricbeat-playbook.yml

PLAY [installing and launching Metricbeat] *******************************************************

TASK [Gathering Facts] *************************************************************************
ok: [10.1.0.8]
ok: [10.1.0.9]
ok: [10.1.0.10]


TASK [Download metricbeat deb] *******************************************************************
[WARNING]: Consider using the get_url or uri module rather than running 'curl'.  If you need to
use command because get_url or uri is insufficient you can add 'warn: false' to this command
task or set 'command_warnings=False' in ansible.cfg to get rid of this message.

changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [install metricbeat deb] ********************************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [drop in metricbeat.yml] ********************************************************************
ok: [10.1.0.8]
ok: [10.1.0.9]
ok: [10.1.0.10]

TASK [Enable and Configure System Module] ******************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [setup metricbeat] **************************************************************************
changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

TASK [start metricbeat service] ******************************************************************
[WARNING]: Consider using the service module rather than running 'service'.  If you need to use
command because service is insufficient you can add 'warn: false' to this command task or set
'command_warnings=False' in ansible.cfg to get rid of this message.

changed: [10.1.0.8]
changed: [10.1.0.9]
changed: [10.1.0.10]

PLAY RECAP *************************************************************************************
10.1.0.8                  : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.1.0.9                  : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.1.0.10                   : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

<a-name="mbver"></a>
### Verifying Metricbeat Installation and Playbook 

  1) Make sure that the ELK server container is up and running.
    - On the workstation, navigate to http://52.249.189.192:5601/app/kibana/home. 

    - Note that if you do not see the ELK server landing page, open a terminal on your computer and SSH into the ELK server.

    - Run `docker container list -a` to verify that the container is on.

    - If it is not, run `docker start elk`.

  2) Verify that the Metricbeat playbook is completing the section `Using the Playbook for Metricbeat`.

  3) Open the ELK server homepage.
    - Click on **Add Metric Data**.
    - Choose **Docker Metrics**.
    - Click on the **DEB** tab under **Getting Started** to view the correct Linux Metricbeat installation instructions.
    - Scroll to **Module Status** and click **Check Data**.

    - If the ELK stack was successfully receiving logs, you would see: 

    - [Metricbeat_receiving.png](Images/Metricbeat_receiving.png)

<a-name="ttkim"></a>
### Things to Keep in Mind
- For Filebeat: 
  - The filebeat-configuration.yml has been modified to replace the IP address with the IP address of the ELK machine. 
  - fil.ebeat-configuration.yml is the configuration file and is copied to /etc/filebeat/filebeat.yml on the VM
  - filebeat-playbook.yml is the playbook file and is not copied to the VM
  - The filebeat-playbook.yml will install and launch Filebeat, download Filebeat, install Filebeat .deb, copy the Filebeat configuration file, enable and configure the system module, setup Filebeat, and start the Filebeat service
  - After running the playbook, navigate to each WebVM to check that the installation worked as expected. 

- For Metricbeat: 
  metricbeat.yml is the configuration file and is copied to /etc/metricbeat/metricbeat.yml on the VM
  metricbeat-playbook.yml is the playbook file and is not copied to the VM
  - The metricbeat-yml has been modified to replace the IP address with the IP address of the ELK machine under `setup.kibana`, and `output.elasticsearch`.
  - metricbeat.yml is the configuration file and is copied to /etc/metricbeat/metricbeat.yml on the VM
  - metricbeat-playbook.yml is the playbook file and is not copied to the VM
  - The metricbeat-playbook.yml will install and launch Metricbeat, download Metricbeat .deb file, install Metricbeat .deb, copy the Metricbeat configuration file, enable and configure the system module, setup Metricbeat, and start the Metricbeat service
  - After running the playbook, navigate to each WebVM to check that the installation worked as expected.


- The `hosts` file is where the IPs of the `webservers` (where Filebeat and Metricbeat will be installed) and `elkservers` (where ELK will be installed) are defined.

- To check that the ELK server is running, navigate to http://52.249.189.192:5601/app/kibana/home
  - Click on **Add Metric Data**.
  - Choose **Docker Metrics**.
  - Click on the **DEB** tab under **Getting Started** to view the correct Linux Metricbeat installation instructions.
  - Scroll to **Module Status** and click **Check Data**.
  - If successful, message will display `Data succesfully received from this module`
  
- To download files:

  - Use `curl` to download a copy of the Filebeat configuration file:
  - `curl https://gist.githubusercontent.com/slape/5cc350109583af6cbe577bbcc0710c93/raw/eca603b72586fbe148c11f9c87bf96a63cb25760/Filebeat > /etc/ansible/files/filebeat-configuration.yml`
  - See `Using the Playbook for Filebeat` Step 10 for instructions on modifying filebeat-configuration.yml

  - Use `curl` to download a copy of the Metricbeat configuration file:
  - `curl https://gist.githubusercontent.com/slape/58541585cc1886d2e26cd8be557ce04c/raw/0ce2c7e744c54513616966affb5e9d96f5e12f73/metricbeat > /etc/ansible/files/metricbeat.yml`
  - See `Using the Playbook for Metricbeat` Step 10 for instructions on modifying metricbeat.yml


<a-name="addresources"></a>
#### Additional Resources
- [Ansible Documentation](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html)
- [`elk-docker` Container Documentation](https://elk-docker.readthedocs.io/)
- [Elastic.co: The Elastic Stack](https://www.elastic.co/elastic-stack)
- [Virtual Memory Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/vm-max-map-count.html#vm-max-map-count)
- [Docker Commands Cheatsheet](https://phoenixnap.com/kb/list-of-docker-commands-cheat-sheet)