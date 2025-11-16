rust
```
cargo new db-app
cargo run
```

docker
```
docker-compose up -d

# tableを事前に作成
docker exec -it simple_postgres_db psql -U user app_db
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

redis
```
docker exec -it simple_redis_cache redis-cli
KEYS *
127.0.0.1:6379> GET user01
"{\"id\":4,\"username\":\"user01\",\"created_at\":\"2025-11-02T01:43:23.038598Z\"}"
127.0.0.1:6379> GET user02
(nil)
```