# Challenge 11: The Zero-Cost Load Balancer (HAProxy)

Scenario: We are moving toward High Availability (HA). Instead of using a $20/month AWS ALB, we will build our own load balancer using HAProxy on a Free Tier instance.

Task Requirements:

Orchestration (Bucket B): Install HAProxy on your Linux instance.

Linux Admin (Bucket A): Configure HAProxy to listen on Port 80.

It should load balance traffic between two local "backend" services.

To simulate this, run two separate Nginx processes on different ports (e.g., Port 8081 and 8082).

Observability (Bucket D):

Enable the HAProxy Stats Page.

Protect the stats page with a username/password.

Shell Logic (Bucket C):

Write a script switch_traffic.sh.

This script should modify the HAProxy config to "drain" traffic from one backend (8081) and shift everything to the other (8082), then reload the service. This simulates a Blue/Green deployment.


# Solution

## Loadbalancing

In this challenge I am being asked to create two processes in nginx and load balance them using haproxy, I did it using following steps

1. First I installed nginx and created a new config named lb.conf inside conf.d folder in /etc/nginx directory
2. inside the lb config I have created 2 processes which nginx will server one on port 8008 and other on port 8009 using the following config

```conf
server{
    listen 8008;
    server_name _;
    root /var/www/html/lb1;
    index index.html;
}



server{
    listen 8009;
    server_name _;
    root /var/www/html/lb2;
    index index.html;
}
```

3. After that I have installed haproxy
4. And created added the follwing frontend config inside the haproxy.conf file in /etc/haproxy directory

```conf
frontend http_web 
    bind *:80
    mode http
    default_backend rgw
    stats enable
    stats uri /stat
    stats refresh 10s
    stats auth admin:admin
```

what this config does is that it tell haproxy to do following
- send all of the traffic it gets on port 80 to backend rgw
- enable stats page to see the stats of backends
- the url stat is localhost/stat
- and to access stat page we need to enter username and password as admin and admin

5. After that I have added the following backend config 

```conf


backend rgw
    balance roundrobin
    mode http
    server rgw1 127.0.0.1:8008 check
    server rgw2 127.0.0.1:8009 check
```

which tells haproxy to load balance in roundrobin manner in 2 server endpoints and enable health check for the server endpoints

6. One more config change which we can do to enable runtime api is adding tghe below config

```
 stats socket /var/lib/haproxy/stats mode 660 level admin
```

which tell haproxy to create a socket file with 660 permission and the reason we are creating this socket file so that we can make config changes in realtime without reloading and restarting the haproxy


## Switching traffic

Right now our haproxy load balance between both the endpoints now suppose if we have green blue deployment and we want to switch traffic from one server endpoint to another without restarting haproxy we can do it using following command

`echo "set server rgw/rgw1 state drain" | sudo socat /var/lib/haproxy/stats`


it tell haproxy to stop receiving any more new traffic on rgw1 server and let the exiting one close and route all of the traffic to other servers.

after sometime when all of the connections are closed then we can set the state of rgw1 to maintanence(maint) so that it does not receive any traffic and later when we want to switch back the traffic completely to this server while stopping on the other one we can do the following

enable traffic to rgw1 
`echo "set server rgw/rgw1 state ready" | sudo socat /var/lib/haproxy/stats`

and set rgw2 to drain state

`echo "set server rgw/rgw2 state drain" | sudo socat /var/lib/haproxy/stats`

by using realtime api with the above commands we donot have to reload the haproxy