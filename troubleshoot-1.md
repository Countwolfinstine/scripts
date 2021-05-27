# Question:

Using the IP and ssh credentials, install apache2 binary in the server which has been misconfigured.You are supposed to find, document and fix any issues in the server so that the apache2 ubuntu default page is accessible on the server from the internet.
When you've verified the host is functional, please provide documentation of what you found, how you found it, and what you did to resolve the problems.


# Solution:
1. We tried to install using `sudo apt-get install apache2`. 
2. This failed due to the server unable to resolve the DNS entries. After checking the /etc/resolve.conf file we found that the nameserver entry was missing. To fix this we added an entry `nameserver 8.8.8.8`. This makes the resolver point to Google DNS.
3. On retrying to install we saw that the DNS resolution was fixed but the server was unable to connect to external servers. On doing a curl we found that we could not connect to HTTP but HTTPS was working, this made us check the iptables, we saw a rule which denied HTTP connections. To fix this we flushed the iptable using the following command `sudo iptables -F OUTPUT` 
4. After this, the apache server was downloaded and installed successfully. 
5. But the process failed to start as some other process was using port 80. Using `netstat -tnlp` we found that a rouge nc process was using port 80. We killed that and restarted the apache server `systemctl restart apache2.service`. 
