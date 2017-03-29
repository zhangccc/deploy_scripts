#!/bin/bash

cd /etc/yum.repos.d
rm ambari.repo
wget http://`hostname`:81/sugo_yum/AMBARI-2.2.2.0/centos6/2.2.2.0-0/ambari.repo
sed -i "s/192.168.0.200/`hostname -i`/" ambari.repo

yum install ambari-server -y

/usr/bin/expect <<-EOF
spawn ambari-server setup
expect {
        "*(n)?" { send "\r"
			expect "*(1):" { send "3\r"
				expect "JAVA_HOME:" {send "/usr/local/jdk18\r"
					expect "*(n)?" { send "\r" }
							}
						}
			expect "*(n)?" { send "/r"
				expect "*(n)?" { send "/r" }
			} 						
				}
		
		"(y)?" {send "\r"
			expect {
				"*(n)?" { send "\r"
					expect "*(1):" { send "3\r"
						expect "JAVA_HOME:" {send "/usr/local/jdk18\r"
							expect "*(n)?" { send "\r" }
											}
									}
					expect "*(n)?" { send "/r"
						expect "*(n)?" { send "/r" }
									} 						
						}
					}
				}
		}
expect "*]#*"
EOF

ambari-server start
