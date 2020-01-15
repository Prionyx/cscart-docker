docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-build:
	docker-compose up --build -d

perm:
ifdef n
	sudo chmod -R 777 $(n)
else
	@echo 'Нужно указать имя магазина'
endif

perm-docker:
	sudo chmod -R 777 docker

cscart-project:
ifdef n
ifdef v
	make cscart-install v=$(v) n=$(n) && make cscart-symlinks n=$(n)
else
	@echo 'Нужно указать версию CS-Cart'
endif

else
	@echo 'Нужно указать имя магазина'
endif

cscart-symlinks:
ifdef n
	docker exec cscart_docker_web_1 sh -c 'for x in $$(ls html/bit/$(n)); do php html/bit/$(n)/$$x/_tools/create_symlinks.php html/$(n); done;'
endif

cscart-install:
ifdef n
ifdef v
	docker exec cscart_docker_web_1 sh -c "cd html && make docker-cscart-install v=$(v) n=$(n)"
	google-chrome-stable "http://localhost/$(n)/admin.php"
else
	@echo 'Нужно указать версию CS-Cart'
endif

else
	@echo 'Нужно указать имя магазина'
endif

cscart-delete:
ifdef n
	docker exec cscart_docker_web_1 sh -c "cd html && make docker-cscart-delete n=$(n)"
else
	@echo 'Нужно указать имя магазина'
endif

docker-cscart-install:
ifdef n
ifdef v
	mkdir ./$(n)
	mysql -uroot -proot --host mysql -e "CREATE DATABASE $(n);"
	cp ./carts/$(v).tgz ./$(n)/
	tar -xvf ./$(n)/$(v).tgz -C ./$(n)
	chmod 666 ./$(n)/config.local.php
	chmod -R 777 ./$(n)/design ./$(n)/images ./$(n)/var
	find ./$(n)/design -type f -print0 | xargs -0 chmod 666
	find ./$(n)/images -type f -print0 | xargs -0 chmod 666
	find ./$(n)/var -type f -print0 | xargs -0 chmod 666
	chmod 644 ./$(n)/design/.htaccess ./$(n)/images/.htaccess ./$(n)/var/.htaccess ./$(n)/var/themes_repository/.htaccess
	chmod 644 ./$(n)/design/index.php ./$(n)/images/index.php ./$(n)/var/index.php ./$(n)/var/themes_repository/index.php
	sed -i "s/.*'en', 'da', 'de', 'es', 'fr', 'el', 'it', 'nl', 'ro', 'ru', 'bg', 'no', 'sl',.*/'en', 'ru',/g" ./$(n)/install/config.php
	sed -i "s/.*'host' => 'localhost',.*/'host' => 'mysql',/g" ./$(n)/install/config.php
	sed -i "s/.*'name' => '%DB_NAME%',.*/'name' => '$(n)',/g" ./$(n)/install/config.php
	sed -i "s/.*'user' => '%DB_USER%',.*/'user' => 'root',/g" ./$(n)/install/config.php
	sed -i "s/.*'password' => '%DB_PASS%',.*/'password' => 'root',/g" ./$(n)/install/config.php
	sed -i "s/.*'http_host' => '%HTTP_HOST%',.*/'http_host' => 'localhost',/g" ./$(n)/install/config.php
	sed -i "s/.*'http_path' => '',.*/'http_path' => '\/$(n)',/g" ./$(n)/install/config.php
	sed -i "s/.*'https_host' => '%HTTP_HOST%',*/'https_host' => 'localhost',/g" ./$(n)/install/config.php
	sed -i "s/.*'https_path' => '',.*/'https_path' => '\/$(n)',/g" ./$(n)/install/config.php
	php ./$(n)/install/index.php
	cp ./carts/local_conf.php ./$(n)/
else
	@echo 'Нужно указать версию CS-Cart'
endif

else
	@echo 'Нужно указать имя магазина'
endif

test:
	-mysql -uroot -proot --host mysql

docker-cscart-delete:
ifdef n
	-mysql -uroot -proot --host mysql -e "DROP DATABASE $(n);"
	rm -rf ./$(n)
else
	@echo 'Нужно указать имя магазина'
endif

# Makefile last line
.PHONY: install delete
