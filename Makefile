preview:
	docker-compose up

docker_network:
	docker network create otus-social-network

fix_rights_users_db:
	sudo chmod 777 -R service-users/database/master
	sudo chmod 0444  service-users/database/master/conf.d/master.cnf

fix_rights_chat_db:
	sudo chmod 777 -R service-chat/database/shard1/data
	sudo chmod 777 -R service-chat/database/shard1/logs
	sudo chmod 777 -R service-chat/database/cfg/data
	sudo chmod 777 -R service-chat/database/cfg/logs

fix_rights: fix_rights_users_db fix_rights_chat_db

chat_db_clear:
	@echo '------shard1------'
	sudo rm -rf service-chat/database/shard1/data/*
	touch service-chat/database/shard1/data/.gitkeep
	sudo rm -rf service-chat/database/shard1/logs/*
	touch service-chat/database/shard1/logs/.gitkeep
	@echo '-------cfg-------'
	sudo rm -rf service-chat/database/cfg/data/*
	touch service-chat/database/cfg/data/.gitkeep
	sudo rm -rf service-chat/database/cfg/logs/*
	touch service-chat/database/cfg/logs/.gitkeep

force_recreate:
	docker-compose up --build --force-recreate $(n)

users_db_init:
	docker exec -i -t osn__users_mysql-master sh -c "mysql -uroot -pmysql dbase < /init_sql/initdb.sql"
	docker exec -i -t osn__users_mysql-master sh -c "mysql -uroot -pmysql dbase < /init_sql/mock_users.sql"

chat_db_init:
	docker exec -i -t osn__chat_mongocfg sh -c "mongo < /init/cfg"
	docker exec -i -t osn__chat_mongo_shard1  sh -c "mongo < /init/shard1"
	@echo "we need to wait 10-15 sec till mongos will get update from config"
	sleep 15
	docker exec -i -t osn__chat_mongos  sh -c "mongo < /init/mongos"
	docker exec -i -t osn__chat_mongos  sh -c "mongo < /init/mongos_sharding_init"

db_init: users_db_init chat_db_init


