#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({ _id : "config_server", configsvr: true, members: [ { _id : 0, host : "configSrv:27017" } ] });
exit();
EOF

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({ _id : "shard1", members: [ { _id : 0, host : "shard1:27018" },{ _id : 1, host : "shard1_slave1:27019" },{ _id : 2, host : "shard1_slave2:27020" } ] });
exit();
EOF

docker compose exec -T shard2 mongosh --port 27021 --quiet <<EOF
rs.initiate({ _id : "shard2", members: [ { _id : 3, host : "shard2:27021" },{ _id : 4, host : "shard2_slave1:27022" },{ _id : 5, host : "shard2_slave2:27023" } ] });
exit();
EOF

docker compose exec -T mongos_router mongosh --port 27024 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27021");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

use somedb;
var total = db.helloDoc.countDocuments();
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});
db.helloDoc.countDocuments();
exit();
EOF

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
console.log('shard1 count');
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

docker compose exec -T shard2 mongosh --port 27021 --quiet <<EOF
console.log('shard2 count');
use somedb;
db.helloDoc.countDocuments();
exit();
EOF