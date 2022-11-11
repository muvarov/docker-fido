sudo docker run  -v `pwd`/share:/share \
	--cap-add=NET_ADMIN \
	-p 8080:8080/tcp \
	-p 8081:8081/tcp \
	-p 8082:8082/tcp \
	-p 8083:8083/tcp \
	-it a0f41ec686ed /bin/bash
